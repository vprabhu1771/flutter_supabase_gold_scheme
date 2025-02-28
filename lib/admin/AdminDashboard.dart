import 'package:flutter/material.dart';
import '../widgets/CustomDrawer.dart';

class AdminDashboard extends StatefulWidget {

  final String title;

  const AdminDashboard({super.key, required this.title});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(parentContext: context),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(widget.title),
      ),
    );
  }
}