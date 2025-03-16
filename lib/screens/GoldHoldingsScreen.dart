import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoldHoldingsScreen extends StatefulWidget {
  final String title;

  const GoldHoldingsScreen({super.key, required this.title});

  @override
  _GoldHoldingsScreenState createState() => _GoldHoldingsScreenState();
}

class _GoldHoldingsScreenState extends State<GoldHoldingsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  double goldGrams = 0.0;

  @override
  void initState() {
    super.initState();
    fetchGoldHoldings();
  }

  Future<void> fetchGoldHoldings() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('gold_holdings')
        .select('gold_grams')
        .eq('user_id', user.id);

    if (response.isNotEmpty) {
      double totalGold = response.fold(0.0, (sum, row) => sum + (row['gold_grams'] as num).toDouble());

      setState(() {
        goldGrams = totalGold;
      });
    } else {
      setState(() {
        goldGrams = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Your Gold Holdings:", style: TextStyle(fontSize: 18)),
            Text("$goldGrams grams", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
