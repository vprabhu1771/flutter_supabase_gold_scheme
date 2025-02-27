import 'package:flutter/material.dart';
import '../models/Subscription.dart';
import '../models/Payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final Subscription subscription;

  const PaymentScreen({super.key, required this.subscription});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Fetch payments related to the subscription
  Future<List<Payment>> fetchPayments() async {
    final response = await supabase
        .from('payments')
        .select('*, subscription:customer_subscriptions(id, start_date, status, total_paid, customer:users(*), scheme:gold_schemes(*))')
        .order('payment_date', ascending: false);

    print('Raw data from Supabase: $response'); // Debugging output

    return response.map<Payment>((row) => Payment.fromJson(row)).toList();
  }

  /// Get icon and color based on payment mode
  Widget getPaymentIcon(String mode) {
    switch (mode) {
      case 'Cash':
        return CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.money, color: Colors.white),
        );
      case 'UPI':
        return CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.qr_code, color: Colors.white),
        );
      case 'Card':
        return CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.credit_card, color: Colors.white),
        );
      case 'Bank Transfer':
        return CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.account_balance, color: Colors.white),
        );
      default:
        return CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.payment, color: Colors.white),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment History")),
      body: FutureBuilder<List<Payment>>(
        future: fetchPayments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final payments = snapshot.data ?? [];

          if (payments.isEmpty) {
            return const Center(child: Text('No payment records found.'));
          }

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: getPaymentIcon(payment.payment_mode),
                  title: Text(
                    'Customer: ${payment.subscription.customer?.name}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scheme: ${payment.subscription.scheme?.name}'),
                      Text('Amount: ₹ ${payment.amount.toStringAsFixed(2)}'),
                      Text('Date: ${payment.formattedDate}'),
                      Text('Mode: ${payment.payment_mode}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
