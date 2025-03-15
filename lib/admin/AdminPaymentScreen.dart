import 'package:flutter/material.dart';
import 'package:flutter_supabase_gold_scheme/models/GoldScheme.dart';
import '../models/Subscription.dart';
import '../models/Payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminPaymentScreen extends StatefulWidget {
  final String title;

  const AdminPaymentScreen({super.key, required this.title});

  @override
  State<AdminPaymentScreen> createState() => _AdminPaymentScreenState();
}

class _AdminPaymentScreenState extends State<AdminPaymentScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<GoldScheme> goldSchemes = [];
  List<Payment> payments = [];
  List<Payment> filteredPayments = [];

  GoldScheme? selectedGoldScheme;
  String? selectedPaymentMode;
  DateTime? selectedDate;
  String searchQuery = "";

  final List<String> paymentModes = ['All', 'Cash', 'UPI', 'Card', 'Bank Transfer'];

  @override
  void initState() {
    super.initState();
    fetchGoldSchemes();
    fetchPayments();
  }

  Future<void> fetchGoldSchemes() async {
    final response = await supabase.from('gold_schemes').select();

    if (response != null) {
      setState(() {
        goldSchemes = response.map((json) => GoldScheme.fromJson(json)).toList();
      });
    }
  }

  Future<void> fetchPayments() async {
    final response = await supabase
        .from('payments')
        .select('*, subscription:customer_subscriptions(id, start_date, status, total_paid, customer:users(*), scheme:gold_schemes(*))')
        .order('payment_date', ascending: false);

    if (response != null) {
      setState(() {
        payments = response.map<Payment>((row) => Payment.fromJson(row)).toList();
        filteredPayments = payments;
      });
    }
  }

  void filterPayments() {
    setState(() {
      filteredPayments = payments.where((payment) {
        final bool hasScheme = selectedGoldScheme != null;
        final bool hasPaymentMode = selectedPaymentMode != null && selectedPaymentMode != "All";
        final bool hasDate = selectedDate != null;
        final bool hasSearch = searchQuery.isNotEmpty;

        final bool matchesScheme = !hasScheme ||
            (payment.subscription.scheme?.name == selectedGoldScheme?.name);

        final bool matchesPaymentMode = !hasPaymentMode ||
            (payment.payment_mode == selectedPaymentMode);

        final bool matchesDate = !hasDate ||
            (payment.payment_date != null &&
                DateFormat('yyyy-MM-dd').format(payment.payment_date as DateTime) ==
                    DateFormat('yyyy-MM-dd').format(selectedDate!));

        final bool matchesSearch = !hasSearch ||
            (payment.subscription.customer?.name?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (payment.subscription.customer?.phone?.contains(searchQuery) ?? false) ||
            (payment.subscription.customer?.email?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

        return matchesScheme && matchesPaymentMode && matchesDate && matchesSearch;
      }).toList();
    });
  }

  Widget getPaymentIcon(String mode) {
    switch (mode) {
      case 'Cash':
        return CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.money, color: Colors.white));
      case 'UPI':
        return CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.qr_code, color: Colors.white));
      case 'Card':
        return CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.credit_card, color: Colors.white));
      case 'Bank Transfer':
        return CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.account_balance, color: Colors.white));
      default:
        return CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.payment, color: Colors.white));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        filterPayments();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<GoldScheme>(
                        isExpanded: true,
                        value: selectedGoldScheme,
                        hint: Text("Select Gold Scheme"),
                        items: goldSchemes.map((scheme) {
                          return DropdownMenuItem(
                            value: scheme,
                            child: Text(scheme.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGoldScheme = value;
                            filterPayments();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedPaymentMode,
                        hint: Text("Select Payment Mode"),
                        items: paymentModes.map((mode) => DropdownMenuItem(value: mode, child: Text(mode))).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMode = value;
                            filterPayments();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: Text(selectedDate == null
                            ? "Select Date"
                            : DateFormat('dd MMM yyyy').format(selectedDate!)),
                      ),
                    ),
                    if (selectedDate != null)
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            selectedDate = null;
                            filterPayments();
                          });
                        },
                      ),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Search by Customer Name, Phone, Email",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      filterPayments();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredPayments.isEmpty
                ? Center(child: Text("No payment records found."))
                : ListView.builder(
              itemCount: filteredPayments.length,
              itemBuilder: (context, index) {
                final payment = filteredPayments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: getPaymentIcon(payment.payment_mode),
                    title: Text(
                      'Customer: ${payment.subscription.customer?.name ?? "Unknown"}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scheme: ${payment.subscription.scheme?.name ?? "N/A"}'),
                        Text('Amount: ₹ ${payment.amount.toStringAsFixed(2)}'),
                        Text('Date: ${payment.formattedDate ?? "N/A"}'),
                        Text('Mode: ${payment.payment_mode}'),
                        Text('Phone: ${payment.subscription.customer?.phone ?? "N/A"}'),
                        Text('Email: ${payment.subscription.customer?.email ?? "N/A"}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
