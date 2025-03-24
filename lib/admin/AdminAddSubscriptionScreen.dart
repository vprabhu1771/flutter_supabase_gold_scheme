import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/GoldScheme.dart';
import '../models/Customer.dart';


class AdminAddSubscriptionScreen extends StatefulWidget {
  final String title;

  const AdminAddSubscriptionScreen({super.key, required this.title});

  @override
  _AdminAddSubscriptionScreenState createState() =>
      _AdminAddSubscriptionScreenState();
}

class _AdminAddSubscriptionScreenState
    extends State<AdminAddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;

  String? customerId;
  String? schemeId;
  DateTime? startDate;
  String status = 'Active';
  TextEditingController totalPaidController =
  TextEditingController(text: '0.00');
  TextEditingController installmentAmountController =
  TextEditingController(text: '0.00');
  List<GoldScheme> goldSchemes = [];
  List<Customer> customers = [];

  @override
  void initState() {
    super.initState();
    _fetchGoldSchemes();
    _fetchCustomers();
  }

  Future<void> _fetchGoldSchemes() async {
    final response = await supabase.from('gold_schemes').select();
    if (response.isNotEmpty) {
      setState(() {
        goldSchemes = response.map((e) => GoldScheme.fromJson(e)).toList();
      });
    }
  }

  Future<void> _fetchCustomers() async {
    final response = await supabase
        .from('user_roles')
        // .select('*');
        .select('user_id, role_id, users(*)') // Fetch specific user fields
        .eq('role_id', 3);

    print(response.toString());

    if (response.isNotEmpty) {
      setState(() {
        customers = response.map((e) {
          final customer = e['users'];
          return Customer(id: customer['id'], name: customer['name'], email: customer['email'], phone: customer['phone']);
        }).toList();
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await supabase.from('customer_subscriptions').insert({
          'customer_id': customerId,
          'scheme_id': schemeId,
          'start_date': startDate?.toIso8601String(),
          'status': status,
          'total_paid': double.tryParse(totalPaidController.text) ?? 0.0,
          // 'installment_amount': double.tryParse(installmentAmountController.text) ?? 0.0,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription added successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Subscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: 'Customer'),
                  value: customerId,
                  items: customers
                      .map((customer) => DropdownMenuItem(
                    value: customer.id,
                    child: Text(customer.name),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => customerId = val as String),
                  validator: (val) => val == null ? 'Select a customer' : null,
                ),
                DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: 'Gold Scheme'),
                  value: schemeId,
                  items: goldSchemes
                      .map((scheme) => DropdownMenuItem(
                    value: scheme.id.toString(),
                    child: Text(scheme.name),
                  )).toList(),
                  // onChanged: (val) => setState(() => schemeId = val as String),
                  onChanged: (val) {
                    setState(() {
                      schemeId = val as String;

                      // Find the selected scheme
                      GoldScheme? selectedScheme =
                      goldSchemes.firstWhere((scheme) => scheme.id.toString() == schemeId);

                      // Update total paid and installment amount fields
                      totalPaidController.text = selectedScheme.total_amount.toString();
                      installmentAmountController.text = selectedScheme.min_installment.toString();
                    });
                  },
                  validator: (val) => val == null ? 'Select a scheme' : null,
                ),
                TextFormField(
                  controller: totalPaidController,
                  decoration: const InputDecoration(labelText: 'Total Paid (₹)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: installmentAmountController,
                  decoration:
                  const InputDecoration(labelText: 'Installment Amount (₹)'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: 'Status'),
                  value: status,
                  items: ['Active', 'Completed', 'Cancelled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => status = val as String),
                ),
                ListTile(
                  title: Text(startDate == null
                      ? 'Pick Start Date'
                      : '${startDate!.toLocal()}'.split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Add Subscription'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
