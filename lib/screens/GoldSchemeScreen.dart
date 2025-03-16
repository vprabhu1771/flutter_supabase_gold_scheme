import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/GoldScheme.dart';
import '../widgets/CustomDrawer.dart';

class GoldSchemeScreen extends StatefulWidget {
  final String title;

  const GoldSchemeScreen({super.key, required this.title});

  @override
  State<GoldSchemeScreen> createState() => _GoldSchemeScreenState();
}

class _GoldSchemeScreenState extends State<GoldSchemeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<GoldScheme>> goldSchemeStream() {
    return supabase
        .from('gold_schemes')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((row) => GoldScheme.fromJson(row)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(parentContext: context),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Refresh StreamBuilder
            },
          ),
        ],
      ),
      body: StreamBuilder<List<GoldScheme>>(
        stream: goldSchemeStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final goldSchemes = snapshot.data ?? [];
          if (goldSchemes.isEmpty) {
            return const Center(child: Text('No gold schemes available.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Refresh UI
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: goldSchemes.length,
              itemBuilder: (context, index) {
                return GoldSchemeCard(goldScheme: goldSchemes[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class GoldSchemeCard extends StatefulWidget {
  final GoldScheme goldScheme;
  const GoldSchemeCard({super.key, required this.goldScheme});

  @override
  State<GoldSchemeCard> createState() => _GoldSchemeCardState();
}

class _GoldSchemeCardState extends State<GoldSchemeCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        title: Text(
          widget.goldScheme.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Duration: ${widget.goldScheme.duration_months} months',
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.monetization_on, "Total Amount", "₹${widget.goldScheme.total_amount}"),
                _infoRow(Icons.payments, "Min Installment", "₹${widget.goldScheme.min_installment}"),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.info_outline),
                  label: const Text("View Details"),
                  onPressed: () {
                    // Navigate to detailed page (if needed)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
