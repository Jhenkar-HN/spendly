class Budget {
  final int? id;
  final String month; // Format: "YYYY-MM" e.g. "2026-09"
  final double limitAmount;

  Budget({
    this.id,
    required this.month,
    required this.limitAmount,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'month': month,
      'limitAmount': limitAmount,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      month: map['month'] as String,
      limitAmount: (map['limitAmount'] as num).toDouble(),
    );
  }

  Budget copyWith({
    int? id,
    String? month,
    double? limitAmount,
  }) {
    return Budget(
      id: id ?? this.id,
      month: month ?? this.month,
      limitAmount: limitAmount ?? this.limitAmount,
    );
  }
}
