class GoldScheme {
  final int id;
  final String name;
  final int duration_months;
  final double total_amount;
  final double min_installment;

  GoldScheme({
    required this.id,
    required this.name,
    required this.duration_months,
    required this.total_amount,
    required this.min_installment,
  });

  factory GoldScheme.fromJson(Map<String, dynamic> json) {
    return GoldScheme(
      id: json['id'],
      name: json['name'],
      duration_months: int.parse(json['duration_months'].toString()), // Convert to int
      total_amount: double.parse(json['total_amount'].toString()), // Convert to double
      min_installment: double.parse(json['min_installment'].toString()), // Convert to double
    );
  }
}
