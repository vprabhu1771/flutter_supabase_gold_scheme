import 'package:flutter/material.dart';
import 'package:flutter_supabase_gold_scheme/models/GoldScheme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEditGoldSchemeForm extends StatefulWidget {
  final GoldScheme? goldScheme; // If null, it's for creation

  const AddEditGoldSchemeForm({super.key, this.goldScheme});

  @override
  State<AddEditGoldSchemeForm> createState() => _AddEditGoldSchemeFormState();
}

class _AddEditGoldSchemeFormState extends State<AddEditGoldSchemeForm> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _installmentController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.goldScheme != null) {
      _nameController.text = widget.goldScheme!.name;
      _durationController.text = widget.goldScheme!.duration_months.toString();
      _totalAmountController.text = widget.goldScheme!.total_amount.toString();
      _installmentController.text = widget.goldScheme!.min_installment.toString();
    }
  }

  // Function to create or update scheme
  Future<void> _saveGoldScheme() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final goldSchemeData = {
      'name': _nameController.text,
      'duration_months': int.parse(_durationController.text),
      'total_amount': double.parse(_totalAmountController.text),
      'min_installment': double.parse(_installmentController.text),
    };

    try {
      if (widget.goldScheme == null) {
        // Create new scheme
        await supabase.from('gold_schemes').insert(goldSchemeData);
      } else {
        // Update existing scheme
        await supabase.from('gold_schemes').update(goldSchemeData).eq('id', widget.goldScheme!.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.goldScheme == null ? 'Scheme created' : 'Scheme updated')),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.goldScheme == null ? 'Add Gold Scheme' : 'Edit Gold Scheme')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, "Scheme Name", Icons.card_giftcard),
              _buildTextField(_durationController, "Duration (Months)", Icons.calendar_today, isNumber: true),
              _buildTextField(_totalAmountController, "Total Amount (₹)", Icons.attach_money, isNumber: true),
              _buildTextField(_installmentController, "Min Installment (₹)", Icons.payment, isNumber: true),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _saveGoldScheme,
                  icon: isLoading ? CircularProgressIndicator() : Icon(Icons.save),
                  label: Text(widget.goldScheme == null ? 'Create Scheme' : 'Update Scheme'),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }
}
