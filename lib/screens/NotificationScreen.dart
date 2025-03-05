import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  final String title;

  const NotificationScreen({super.key, required this.title});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SectionHeader(title: 'Gold Scheme Notifications'),
          NotificationCard(
            icon: Icons.account_balance_wallet,
            title: 'New Gold Scheme Launched',
            subtitle: 'Exclusive gold investment plan with high returns.',
            time: '10 mins ago',
          ),
          NotificationCard(
            icon: Icons.monetization_on,
            title: 'Installment Due Reminder',
            subtitle: 'Your monthly gold scheme installment is due.',
            time: '1 hour ago',
          ),
          const SectionHeader(title: 'Gold Investment Alerts'),
          NotificationCard(
            icon: Icons.trending_up,
            title: 'Gold Prices Updated',
            subtitle: 'Check the latest gold price trends.',
            time: '30 mins ago',
          ),
          NotificationCard(
            icon: Icons.notifications_active,
            title: 'Maturity Date Approaching',
            subtitle: 'Your gold scheme is maturing soon.',
            time: '3 hours ago',
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.yellow.shade50,
          child: Icon(icon, color: Colors.orange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}