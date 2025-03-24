import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/GoldScheme.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final String title;

  const AddSubscriptionScreen({super.key, required this.title});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;

  String? customerId;
  String? schemeId;
  DateTime? startDate;
  String status = 'Active';

  List<GoldScheme> goldSchemes = [];
  double totalAmount = 0.0;
  double minInstallment = 0.0;
  int durationMonths = 0;

  @override
  void initState() {
    super.initState();
    customerId = supabase.auth.currentUser?.id;
    _fetchGoldSchemes();
  }

  Future<void> _fetchGoldSchemes() async {
    final response = await supabase.from('gold_schemes').select('*');

    setState(() {
      goldSchemes = response.map((e) => GoldScheme.fromJson(e)).toList();
    });
  }

  void _onSchemeSelected(String? selectedId) {
    if (selectedId == null) return;

    setState(() {
      schemeId = selectedId;
      GoldScheme selectedScheme =
      goldSchemes.firstWhere((scheme) => scheme.id.toString() == selectedId);
      totalAmount = selectedScheme.total_amount;
      minInstallment = selectedScheme.min_installment;
      durationMonths = selectedScheme.duration_months;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await supabase.from('customer_subscriptions').insert({
          'customer_id': customerId,
          'scheme_id': schemeId,
          'start_date': startDate?.toIso8601String(),
          'status': status,
          'total_paid': double.parse(totalAmount.toString()),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription added successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );

        print("customer_id $customerId");
        print("scheme_id $schemeId");
        print("start_date ${startDate?.toIso8601String()}");
        print("status $status");
        print("total_paid ${double.parse(totalAmount.toString())}");
        print('Error: $e');
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
      appBar: AppBar(title: Text('Add Subscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Gold Scheme'),
                value: schemeId,
                items: goldSchemes
                    .map((scheme) => DropdownMenuItem(
                  value: scheme.id.toString(),
                  child: Text(scheme.name),
                ))
                    .toList(),
                onChanged: _onSchemeSelected,
                validator: (val) => val == null ? 'Select a scheme' : null,
              ),
              SizedBox(height: 10),
              Text("Total Amount: ₹$totalAmount", style: TextStyle(fontSize: 16)),
              Text("Min Installment: ₹$minInstallment", style: TextStyle(fontSize: 16)),
              Text("Duration: $durationMonths months", style: TextStyle(fontSize: 16)),

              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Status'),
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
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Subscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
