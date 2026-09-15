class Expense {
  final int? id;
  final double amount;
  final String category;
  final String? note;
  final String? paymentMode;
  final DateTime dateTime;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    this.note,
    this.paymentMode,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'amount': amount,
      'category': category,
      'note': note,
      'paymentMode': paymentMode,
      'dateTime': dateTime.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      note: map['note'] as String?,
      paymentMode: map['paymentMode'] as String?,
      dateTime: DateTime.parse(map['dateTime'] as String),
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? category,
    String? note,
    String? paymentMode,
    DateTime? dateTime,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      paymentMode: paymentMode ?? this.paymentMode,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
