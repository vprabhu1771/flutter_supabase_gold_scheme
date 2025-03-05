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
  TextEditingController totalPaidController = TextEditingController(text: '0.00');
  List<GoldScheme> goldSchemes = [];


  @override
  void initState() {
    super.initState();

    setState(() {
      customerId = supabase.auth.currentUser?.id;
    });

    _fetchGoldSchemes();
  }

  Future<void> _fetchGoldSchemes() async {
    final response = await supabase.from('gold_schemes').select('*');
    setState(() {
      goldSchemes = response.map((e) => GoldScheme.fromJson(e)).toList();
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
          'total_paid': double.parse(totalPaidController.text),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription added successfully!')),
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
      appBar: AppBar(title: Text('Add Subscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // TextFormField(
              //   decoration: InputDecoration(labelText: 'Customer ID'),
              //   onChanged: (val) => customerId = val,
              //   validator: (val) => val!.isEmpty ? 'Enter Customer ID' : null,
              // ),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Gold Scheme'),
                value: schemeId,
                items: goldSchemes
                    .map((scheme) => DropdownMenuItem(
                  value: scheme.id.toString(),
                  child: Text(scheme.name),
                ))
                    .toList(),
                onChanged: (val) => setState(() => schemeId = val as String),
                validator: (val) => val == null ? 'Select a scheme' : null,
              ),
              TextFormField(
                controller: totalPaidController,
                decoration: InputDecoration(labelText: 'Total Paid (₹)'),
                keyboardType: TextInputType.number,
              ),
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
                    : 'Start Date: ${startDate!.toLocal()}'.split(' ')[0]),
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