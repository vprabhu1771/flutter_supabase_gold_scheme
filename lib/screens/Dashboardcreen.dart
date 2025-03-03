import 'package:flutter/material.dart';

import '../widgets/CustomDrawer.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {

  final String title;

  const DashboardScreen({super.key, required this.title});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final supabase = Supabase.instance.client;

  String? userId;

  double goldHoldings = 0.0;
  double goldPrice = 0.0;


  @override
  void initState() {
    super.initState();

    setState(() {
      userId = supabase.auth.currentUser?.id;
    });

    fetchData();
  }

  Future<void> fetchData() async {
    final userId = supabase.auth.currentUser?.id;
    final holdingsResponse = await supabase.from('gold_holdings').select('gold_grams').eq('user_id', userId as Object).single();
    final priceResponse = await supabase.from('gold_prices').select('price_per_gram').order('recorded_at', ascending: false).limit(1).single();

    setState(() {
      goldHoldings = holdingsResponse?['gold_grams'] ?? 0.0;
      goldPrice = priceResponse?['price_per_gram'] ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: CustomDrawer(parentContext: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text("Your Gold Holdings"),
                subtitle: Text("$goldHoldings grams"),
              ),
            ),
            Card(
              child: ListTile(
                title: Text("Current Gold Price"),
                subtitle: Text("\$$goldPrice per gram"),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/transactions'), child: Text("View Transactions")),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/subscriptions'), child: Text("View Plans"))
          ],
        ),
      ),
    );
  }
}