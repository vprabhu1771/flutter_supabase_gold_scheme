class GoldScheme {
  final int id;
  final String name;
  final String duration_months;
  final String total_amount;
  final String min_installment;

  GoldScheme({
    required this.id,
    required this.name,
    required this.duration_months,
    required this.total_amount,
    required this.min_installment
  });

  GoldScheme.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name =json['name'],
        duration_months = json['duration_months'],
        total_amount = json['total_amount'],
        min_installment = json['min_installment'];
}