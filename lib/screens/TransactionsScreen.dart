import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionsScreen extends StatefulWidget {

  final String title;

  const TransactionsScreen({super.key, required this.title});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final supabase = Supabase.instance.client;
  final _amountController = TextEditingController();

  Future<void> makeTransaction(String type) async {
    final userId = supabase.auth.currentUser?.id;
    final response = await supabase.from('gold_transactions').insert({
      'user_id': userId,
      'type': type,
      'amount': double.parse(_amountController.text),
      'status': 'pending',
    });

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction submitted!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gold Transactions")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _amountController, decoration: InputDecoration(labelText: "Amount")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => makeTransaction('deposit'), child: Text("Deposit Gold")),
            ElevatedButton(onPressed: () => makeTransaction('withdrawal'), child: Text("Withdraw Gold")),
            ElevatedButton(onPressed: () => makeTransaction('purchase'), child: Text("Buy Gold")),
          ],
        ),
      ),
    );
  }
}
