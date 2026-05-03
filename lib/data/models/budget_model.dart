import 'dart:convert';

class Budget {
  final double amount;

  Budget({required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      amount: map['amount'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Budget.fromJson(String source) => Budget.fromMap(json.decode(source));
}
