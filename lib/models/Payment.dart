  import 'Subscription.dart';

  class Payment {
    final int id;
    final Subscription subscription;
    final double amount;
    final String payment_date;
    final String payment_mode;

    Payment({
      required this.id,
      required this.subscription,
      required this.amount,
      required this.payment_date,
      required this.payment_mode
    });

    factory Payment.fromJson(Map<String, dynamic> json) {
      return Payment(
        id: json['id'],
        subscription: Subscription.fromJson(json['subscription']),
        amount: double.parse(json['amount'].toString()),
        payment_date: json['payment_date'],
        payment_mode: json['payment_mode']
      );
    }
  }
