import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/GoldScheme.dart';
import '../../widgets/CustomDrawer.dart';

import '../../admin/gold_scheme/GoldSchemeDetailPage.dart';

import '../../admin/gold_scheme/AddEditGoldSchemeForm.dart';

class GoldSchemeManagementScreen extends StatefulWidget {
  final String title;

  const GoldSchemeManagementScreen({super.key, required this.title});

  @override
  State<GoldSchemeManagementScreen> createState() => _GoldSchemeManagementScreenState();
}

class _GoldSchemeManagementScreenState extends State<GoldSchemeManagementScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<GoldScheme>> goldSchemeStream() {
    return supabase
        .from('gold_schemes')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((row) => GoldScheme.fromJson(row)).toList());
  }

  Future<void> _deleteScheme(int id) async {
    await supabase.from('gold_schemes').delete().eq('id', id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gold Scheme deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(parentContext: context),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEditGoldSchemeForm()),
              );
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
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }

          final goldSchemes = snapshot.data ?? [];

          if (goldSchemes.isEmpty) {
            return const Center(
              child: Text('No gold schemes available.', style: TextStyle(fontSize: 16)),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: goldSchemes.length,
              itemBuilder: (context, index) {
                final scheme = goldSchemes[index];
                return Slidable(
                  key: ValueKey(scheme.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddEditGoldSchemeForm(goldScheme: scheme)),
                          );
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (context) => _deleteScheme(scheme.id),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.attach_money, color: Colors.amber, size: 32),
                      title: Text(scheme.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Duration: ${scheme.duration_months} months'),
                          Text('Total Amount: ₹${scheme.total_amount.toStringAsFixed(2)}'),
                          Text('Min Installment: ₹${scheme.min_installment.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GoldSchemeDetailPage(goldScheme: scheme)),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
