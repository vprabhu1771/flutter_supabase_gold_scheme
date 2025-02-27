import 'GoldScheme.dart';
import 'User.dart';

class Subscription {
  final int id;
  final User customer;
  final GoldScheme scheme;
  final String startDate;
  final String status;
  final double totalPaid;

  Subscription({
    required this.id,
    required this.customer,
    required this.scheme,
    required this.startDate,
    required this.status,
    required this.totalPaid,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      customer: User.fromJson(json['customer']),
      scheme: GoldScheme.fromJson(json['scheme']),
      startDate: json['start_date'],
      status: json['status'],
      totalPaid: double.parse(json['total_paid'].toString()),
    );
  }
}
