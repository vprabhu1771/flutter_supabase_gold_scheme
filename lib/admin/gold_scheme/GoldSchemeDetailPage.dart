import 'package:flutter/material.dart';
import 'package:flutter_supabase_gold_scheme/models/GoldScheme.dart';

class GoldSchemeDetailPage extends StatelessWidget {
  final GoldScheme goldScheme;

  GoldSchemeDetailPage({required this.goldScheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(goldScheme.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: goldScheme.id,
                    child: Icon(Icons.attach_money, size: 80, color: Colors.amber),
                  ),
                ),
                SizedBox(height: 20),
                Text(goldScheme.name),
                _buildDetailRow(Icons.calendar_month, "Duration", "${goldScheme.duration_months} months"),
                _buildDetailRow(Icons.account_balance_wallet, "Total Amount", "₹${goldScheme.total_amount.toStringAsFixed(2)}"),
                _buildDetailRow(Icons.payment, "Min Installment", "₹${goldScheme.min_installment.toStringAsFixed(2)}"),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                    label: Text("Go Back"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
