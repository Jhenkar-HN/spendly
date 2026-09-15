import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/models/category.dart';
import 'package:spendly/models/budget.dart';

void main() {
  group('Expense Model Tests', () {
    test('Expense model serialization toMap and fromMap works correctly', () {
      final now = DateTime.now();
      final expense = Expense(
        id: 1,
        amount: 250.75,
        category: 'Food',
        note: 'Team lunch',
        paymentMode: 'UPI',
        dateTime: now,
      );

      final map = expense.toMap();
      expect(map['id'], 1);
      expect(map['amount'], 250.75);
      expect(map['category'], 'Food');
      expect(map['note'], 'Team lunch');
      expect(map['paymentMode'], 'UPI');
      expect(map['dateTime'], now.toIso8601String());

      final restored = Expense.fromMap(map);
      expect(restored.id, expense.id);
      expect(restored.amount, expense.amount);
      expect(restored.category, expense.category);
      expect(restored.note, expense.note);
      expect(restored.paymentMode, expense.paymentMode);
      expect(restored.dateTime, expense.dateTime);
    });

    test('Category default list contains expected initial categories', () {
      final defaultCats = Category.defaultCategories();
      expect(defaultCats.length, 8);
      expect(defaultCats.any((c) => c.name == 'Food'), true);
      expect(defaultCats.any((c) => c.name == 'Travel'), true);
      expect(defaultCats.any((c) => c.name == 'Shopping'), true);
      expect(defaultCats.any((c) => c.name == 'Bills'), true);
    });

    test('Budget serialization and calculations', () {
      final budget = Budget(
        id: 1,
        month: '2026-09',
        limitAmount: 50000.0,
      );

      final map = budget.toMap();
      expect(map['month'], '2026-09');
      expect(map['limitAmount'], 50000.0);

      final restored = Budget.fromMap(map);
      expect(restored.month, '2026-09');
      expect(restored.limitAmount, 50000.0);
    });
  });
}
