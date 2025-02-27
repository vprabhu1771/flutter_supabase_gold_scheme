import 'package:flutter/material.dart';
import 'package:flutter_supabase_gold_scheme/screens/PaymentScreen.dart';
import '../models/Subscription.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MySubscriptionScreen extends StatefulWidget {
  final String title;

  const MySubscriptionScreen({super.key, required this.title});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  String? userId;


  @override
  void initState() {
    super.initState();

    setState(() {
      userId = supabase.auth.currentUser?.id;
    });
  }

  /// Fetch subscriptions with customer and scheme data.
  Future<List<Subscription>> fetchSubscriptions() async {
    final response = await supabase
        .from('customer_subscriptions')
        .select('*, customer:users(*), scheme:gold_schemes(*)') // Fetch related data
        // .select('id, start_date, status, total_paid, created_at, '
        //   'customer:users(id, name, email, phone), '
        //   'scheme:gold_schemes(id, name, duration_months, total_amount, min_installment)')
        .eq('customer_id', userId as Object)
        .order('created_at', ascending: false);

    print('Raw data from Supabase: $response'); // Debugging output

    return response.map<Subscription>((row) => Subscription.fromJson(row)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Subscription>>(
        future: fetchSubscriptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final subscriptions = snapshot.data ?? [];

          if (subscriptions.isEmpty) {
            return Center(child: Text('No subscriptions available.'));
          }

          return ListView.builder(
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final subscription = subscriptions[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Customer: ${subscription.customer?.name}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scheme: ${subscription.scheme?.name}'),
                      Text('Start Date: ${subscription.startDate}'),
                      Text('Status: ${subscription.status}'),
                      Text('Total Paid: \$${subscription.totalPaid}'),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // Handle subscription details

                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(subscription: subscription,),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      )
    );
  }
}
