import 'package:flutter/material.dart';
import 'package:flutter_supabase_gold_scheme/admin/AdminPaymentScreen.dart';
import 'package:flutter_supabase_gold_scheme/admin/customer/CustomerManagementScreen.dart';
import 'package:flutter_supabase_gold_scheme/admin/gold_scheme/GoldSchemeManagementScreen.dart';
import 'package:flutter_supabase_gold_scheme/widgets/CustomDrawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Payment.dart';

class AdminDashboard extends StatefulWidget {

  final String title;

  const AdminDashboard({super.key, required this.title});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  final SupabaseClient supabase = Supabase.instance.client;

  late String userId;
  late double earnings = 0;
  late int customerCount = 0;
  late int goldSchemeCount = 0;
  late double goldPrice = 0;
  late double silverPrice = 0;

  List<Payment> recentPayments = [];


  @override
  void initState() {
    super.initState();

    setState(() {
      userId = supabase.auth.currentUser!.id; // Replace with actual logged-in user ID
    });
    listenToEarnings();
    // listenToCustomerCounts();
    fetchCustomerCount();
    fetchSchemeCount();
    fetchGoldSilverData();
    fetchRecentPayments();
  }

  void listenToEarnings() {
    supabase.from('payments').stream(primaryKey: ['id', 'amount']).listen((data) {
      double totalEarnings = data.fold<double>(0.0, (sum, row) {
        final amount = row['amount'];
        if (amount != null) {
          return sum + (double.tryParse(amount.toString()) ?? 0.0);
        }
        return sum;
      });

      setState(() => earnings = totalEarnings);
    });
  }

  // void listenToCustomerCounts() {
  //   supabase.from('users').stream(primaryKey: ['id']).listen((data) {
  //     setState(() => customerCount = data.length);
  //   });
  // }

  fetchCustomerCount() async {
    if (userId == null) return; // Ensure userId is not null

    try {
      final response = await supabase
          .from('users')
          .select('id'); // Count the number of rows

      final customerCount = response.length ?? 0; // Get count value safely.

      // print("fetchCustomerCount ${response.toString()}");

      setState(() {
        // Updating the customer count
        this.customerCount = response.length;
      });

      print('Total Customers: $customerCount');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      print('Error: $e');
    }
  }

  fetchSchemeCount() async {
    if (userId == null) return; // Ensure userId is not null

    try {
      final response = await supabase
          .from('gold_schemes')
          .select('id'); // Count the number of rows

      final goldSchemeCount = response.length ?? 0; // Get count value safely.

      // print("fetchSchemeCount ${response.toString()}");

      setState(() {
        // Updating the customer count
        this.goldSchemeCount = response.length;
      });

      print('Total Customers: $goldSchemeCount');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      print('Error: $e');
    }
  }

  Future<void> fetchGoldSilverData() async {
    final userId = supabase.auth.currentUser?.id;
    final goldPriceResponse = await supabase.from('gold_prices').select('price_per_gram').order('recorded_at', ascending: false).limit(1).single();
    final silverPriceResponse = await supabase.from('silver_prices').select('price_per_gram').order('recorded_at', ascending: false).limit(1).single();

    // print("fetchGoldSilverData  goldPriceResponse ${goldPriceResponse.toString()}");
    // print("fetchGoldSilverData  silverPriceResponse ${silverPriceResponse.toString()}");

    setState(() {
      goldPrice = goldPriceResponse?['price_per_gram'] ?? 0.0;
      silverPrice = silverPriceResponse?['price_per_gram'] ?? 0.0;
    });
  }

  Future<void> fetchRecentPayments() async {
    try {
      final response = await supabase
          .from('payments')
          .select('*, subscription:customer_subscriptions(id, start_date, status, total_paid, customer:users(*), scheme:gold_schemes(*))')
          .order('payment_date', ascending: false);

      print('Raw data from Supabase: $response');

      if (mounted) {
        setState(() {
          recentPayments = response.map<Payment>((row) => Payment.fromJson(row)).toList();
        });
      }
    } catch (e) {
      // showErrorSnackbar(e);
      print('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.poppins(fontSize: 20)),
        // backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                fetchCustomerCount();
                fetchSchemeCount();
                fetchGoldSilverData();
                fetchRecentPayments();
              }
          )
        ],
      ),
      drawer: CustomDrawer(parentContext: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryCards(), // Summary Grid
            SizedBox(height: 20),
            _buildRecentPayments(), // Recent Payments List
          ],
        ),
      ),
    );
  }

  // 🔹 Summary Cards for Earnings, Customers, etc.
  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // ✅ Responsive layout
      shrinkWrap: true,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.0,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildCard(
          "Earnings",
          "₹ ${earnings.toString()}",
          Icons.monetization_on,
          Colors.green,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPaymentScreen(title: "Earnings"))), // ✅ Navigate to AdminPaymentScreen
        ),
        _buildCard(
          "Customers",
          customerCount.toString(),
          Icons.people,
          Colors.blue,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerManagementScreen(title: 'Customers'))), // ✅ Navigate to CustomerManagementScreen
        ),
        _buildCard(
            "Schemes",
            goldSchemeCount.toString(),
            Icons.card_giftcard,
            Colors.orange,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => GoldSchemeManagementScreen(title: 'Gold Scheme'))), // ✅ Navigate to GoldSchemeManagementScreen
        ),
        _buildCard("Gold Price", "₹${goldPrice}/gm", Icons.star, Colors.amber, () {}),
        _buildCard("Silver Price", "₹${silverPrice}/gm", Icons.g_mobiledata, Colors.grey, () {}),
      ],
    );
  }

  // 🔹 Helper function for summary cards
  Widget _buildCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // ✅ Navigate on tap
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 30),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54)),
                  Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Recent Payments List
  Widget _buildRecentPayments() {
    // List<Map<String, String>> recentPayments = [
    //   {"name": "John Doe", "amount": "₹ 5,000", "date": "15 Mar 2025"},
    //   {"name": "Alice Brown", "amount": "₹ 3,200", "date": "14 Mar 2025"},
    //   {"name": "Michael Smith", "amount": "₹ 7,800", "date": "12 Mar 2025"},
    // ];

    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Recent Payments", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: recentPayments.length,
                itemBuilder: (context, index) {
                  var payment = recentPayments[index];

                  return ListTile(
                    leading: CircleAvatar(child: Icon(Icons.payment, color: Colors.white), backgroundColor: Colors.blue),
                    title: Text("${payment.subscription.customer?.name.toString()} - ${payment.amount!}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text(payment.formattedDate!.toString(), style: TextStyle(color: Colors.grey)),
                    trailing: Text(payment.payment_mode!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
