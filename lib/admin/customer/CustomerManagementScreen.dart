import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'AddEditCustomerScreen.dart';
import 'CustomerDetailPage.dart';

class CustomerManagementScreen extends StatefulWidget {
  final String title;

  const CustomerManagementScreen({super.key, required this.title});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> customers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _subscribeToRealtimeUpdates();
  }

  void _fetchCustomers() async {
    final response = await supabase.from('users').select('id, name, email, phone');
    setState(() {
      customers = List<Map<String, dynamic>>.from(response);
    });
  }

  void _subscribeToRealtimeUpdates() {
    supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      setState(() {
        customers = data;
      });
    });
  }

  void _deleteCustomer(int index) async {
    final customerId = customers[index]['id'];
    final response = await supabase.from('users').delete().match({'id': customerId});

    print(response.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Customer deleted')),
    );
  }

  void _navigateToDetail(Map<String, dynamic> customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(customer: customer),
      ),
    );
  }

  void _addCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditCustomerScreen(title: 'Add Customer',)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Management')),
      body: customers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Slidable(
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    _navigateToDetail(customer);
                  },
                  backgroundColor: Colors.blue,
                  icon: Icons.edit,
                  label: 'Edit',
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    _deleteCustomer(index);
                  },
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(child: Text(customer['name'][0])),
              title: Text(customer['name']),
              subtitle: Text(customer['email']),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _navigateToDetail(customer),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        child: Icon(Icons.add),
      ),
    );
  }
}