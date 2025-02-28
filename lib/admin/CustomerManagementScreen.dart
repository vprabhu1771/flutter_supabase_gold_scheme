import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomerManagementScreen extends StatefulWidget {

  final String title;

  const CustomerManagementScreen({super.key, required this.title});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {

  // Dummy customer list
  List<Map<String, String>> customers = [
    {'name': 'John Doe', 'email': 'john@example.com', 'phone': '9876543210'},
    {'name': 'Alice Smith', 'email': 'alice@example.com', 'phone': '9123456789'},
    {'name': 'Bob Johnson', 'email': 'bob@example.com', 'phone': '9988776655'},
  ];

  void _deleteCustomer(int index) {
    setState(() {
      customers.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Customer deleted')),
    );
  }

  void _navigateToDetail(Map<String, String> customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(customer: customer),
      ),
    );
  }

  void _addCustomer() {
    // Navigate to add customer form
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditCustomerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Management')),
      body: ListView.builder(
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
              leading: CircleAvatar(child: Text(customer['name']![0])),
              title: Text(customer['name']!),
              subtitle: Text(customer['email']!),
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

// Customer Detail Page
class CustomerDetailPage extends StatelessWidget {
  final Map<String, String> customer;

  CustomerDetailPage({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(customer['name']!)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${customer['email']}', style: TextStyle(fontSize: 16)),
            Text('Phone: ${customer['phone']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Order History:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: Text('Order #12345'),
              subtitle: Text('Status: Paid'),
              trailing: Text('\$200'),
            ),
            ListTile(
              title: Text('Order #67890'),
              subtitle: Text('Status: Pending'),
              trailing: Text('\$150'),
            ),
          ],
        ),
      ),
    );
  }
}

// Add/Edit Customer Page
class AddEditCustomerPage extends StatefulWidget {
  @override
  _AddEditCustomerPageState createState() => _AddEditCustomerPageState();
}

class _AddEditCustomerPageState extends State<AddEditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String phone = '';

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      // Save customer logic here
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add/Edit Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
                onChanged: (value) => name = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) =>
                value!.isEmpty || !value.contains('@') ? 'Enter valid email' : null,
                onChanged: (value) => email = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.length != 10 ? 'Enter valid phone number' : null,
                onChanged: (value) => phone = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCustomer,
                child: Text('Save Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}