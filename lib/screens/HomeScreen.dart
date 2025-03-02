import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/CustomDrawer.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> goldPriceStream() {
    return supabase
        .from('gold_prices')
        .stream(primaryKey: ['id'])  // Listen for changes in the table
        .order('recorded_at', ascending: false)
        .limit(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gold Price Today")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: goldPriceStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}")); // Error state
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No gold price data available"));
          }

          // Extract latest gold price
          final goldData = snapshot.data!.first;
          final goldPrice = goldData['price_per_gram'] as double;
          final recordedAt = goldData['recorded_at'];

          return Center(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Current Gold Price", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("₹ $goldPrice per gram", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                    SizedBox(height: 10),
                    Text("Last Updated: ${recordedAt.split('T')[0]}", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
