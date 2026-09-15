import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../services/database_helper.dart';

enum BudgetStatus {
  notSet,
  normal,
  warning, // 80% - 100%
  exceeded, // > 100%
}

class BudgetProvider extends ChangeNotifier {
  Budget? _currentBudget;
  double _monthSpent = 0.0;
  bool _isLoading = true;

  Budget? get currentBudget => _currentBudget;
  double get budgetLimit => _currentBudget?.limitAmount ?? 0.0;
  double get monthSpent => _monthSpent;
  bool get hasBudget => _currentBudget != null && _currentBudget!.limitAmount > 0;
  bool get isLoading => _isLoading;

  String get currentMonthKey => DateFormat('yyyy-MM').format(DateTime.now());

  double get remainingBudget => (budgetLimit - _monthSpent) > 0 ? (budgetLimit - _monthSpent) : 0.0;

  double get progress {
    if (budgetLimit <= 0) return 0.0;
    final ratio = _monthSpent / budgetLimit;
    return ratio.clamp(0.0, 1.0);
  }

  BudgetStatus get status {
    if (!hasBudget) return BudgetStatus.notSet;
    if (_monthSpent > budgetLimit) return BudgetStatus.exceeded;
    if (_monthSpent >= (budgetLimit * 0.8)) return BudgetStatus.warning;
    return BudgetStatus.normal;
  }

  BudgetProvider() {
    loadCurrentMonthBudget();
  }

  Future<void> loadCurrentMonthBudget() async {
    _isLoading = true;
    notifyListeners();

    try {
      final month = currentMonthKey;
      _currentBudget = await DatabaseHelper.instance.getBudgetForMonth(month);

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      _monthSpent = await DatabaseHelper.instance.getTotalForDateRange(startOfMonth, endOfMonth);
    } catch (e) {
      debugPrint('Error loading budget: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setMonthlyBudget(double amount) async {
    final month = currentMonthKey;
    final budget = Budget(month: month, limitAmount: amount);
    await DatabaseHelper.instance.setBudget(budget);
    await loadCurrentMonthBudget();
  }

  void updateMonthSpent(double total) {
    _monthSpent = total;
    notifyListeners();
  }
}
