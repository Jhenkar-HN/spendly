import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import 'budget_provider.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _todayExpenses = [];
  double _todayTotal = 0.0;

  DateTime _selectedHistoryDate = DateTime.now();
  List<Expense> _historyExpenses = [];
  double _historyDateTotal = 0.0;

  // Analytics
  double _weekTotal = 0.0;
  double _monthTotal = 0.0;
  Map<String, double> _analyticsCategoryTotals = {};
  List<Map<String, dynamic>> _spendingTrend = [];
  String _analyticsPeriod = 'Month'; // 'Today', 'Week', 'Month'

  // Search & Filter
  List<Expense> _searchResults = [];
  bool _isSearching = false;

  bool _isLoading = false;

  // Getters
  List<Expense> get todayExpenses => _todayExpenses;
  double get todayTotal => _todayTotal;

  DateTime get selectedHistoryDate => _selectedHistoryDate;
  List<Expense> get historyExpenses => _historyExpenses;
  double get historyDateTotal => _historyDateTotal;

  double get weekTotal => _weekTotal;
  double get monthTotal => _monthTotal;
  Map<String, double> get analyticsCategoryTotals => _analyticsCategoryTotals;
  List<Map<String, dynamic>> get spendingTrend => _spendingTrend;
  String get analyticsPeriod => _analyticsPeriod;

  List<Expense> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;

  String get topCategory {
    if (_analyticsCategoryTotals.isEmpty) return 'None';
    return _analyticsCategoryTotals.keys.first;
  }

  double get topCategoryAmount {
    if (_analyticsCategoryTotals.isEmpty) return 0.0;
    return _analyticsCategoryTotals.values.first;
  }

  ExpenseProvider() {
    refreshAll();
  }

  Future<void> refreshAll({BudgetProvider? budgetProvider}) async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      loadTodayExpenses(),
      loadHistoryForDate(_selectedHistoryDate),
      loadAnalyticsData(),
    ]);

    if (budgetProvider != null) {
      budgetProvider.updateMonthSpent(_monthTotal);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTodayExpenses() async {
    final now = DateTime.now();
    _todayExpenses = await DatabaseHelper.instance.getExpensesForDate(now);
    _todayTotal = _todayExpenses.fold(0.0, (sum, item) => sum + item.amount);
    notifyListeners();
  }

  Future<void> setSelectedHistoryDate(DateTime date) async {
    _selectedHistoryDate = date;
    await loadHistoryForDate(date);
  }

  Future<void> loadHistoryForDate(DateTime date) async {
    _historyExpenses = await DatabaseHelper.instance.getExpensesForDate(date);
    _historyDateTotal = _historyExpenses.fold(0.0, (sum, item) => sum + item.amount);
    notifyListeners();
  }

  void setAnalyticsPeriod(String period) {
    _analyticsPeriod = period;
    loadAnalyticsData();
  }

  Future<void> loadAnalyticsData() async {
    final now = DateTime.now();

    // Week total (start from 7 days ago or Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekZero = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    _weekTotal = await DatabaseHelper.instance.getTotalForDateRange(startOfWeekZero, now);

    // Month total (1st of this month to now)
    final startOfMonth = DateTime(now.year, now.month, 1);
    _monthTotal = await DatabaseHelper.instance.getTotalForDateRange(startOfMonth, now);

    // Period Category Breakdown
    DateTime periodStart;
    if (_analyticsPeriod == 'Today') {
      periodStart = DateTime(now.year, now.month, now.day);
    } else if (_analyticsPeriod == 'Week') {
      periodStart = startOfWeekZero;
    } else {
      periodStart = startOfMonth;
    }

    _analyticsCategoryTotals = await DatabaseHelper.instance.getCategoryTotalsForDateRange(
      periodStart,
      now,
    );

    // 7 or 30 days trend based on period
    final trendDays = (_analyticsPeriod == 'Month') ? 30 : 7;
    _spendingTrend = await DatabaseHelper.instance.getDailySpendingTrend(trendDays);

    notifyListeners();
  }

  Future<int> addExpense(Expense expense, {BudgetProvider? budgetProvider}) async {
    final id = await DatabaseHelper.instance.insertExpense(expense);
    await refreshAll(budgetProvider: budgetProvider);
    return id;
  }

  Future<bool> updateExpense(Expense expense, {BudgetProvider? budgetProvider}) async {
    final count = await DatabaseHelper.instance.updateExpense(expense);
    await refreshAll(budgetProvider: budgetProvider);
    return count > 0;
  }

  Future<bool> deleteExpense(int id, {BudgetProvider? budgetProvider}) async {
    final count = await DatabaseHelper.instance.deleteExpense(id);
    await refreshAll(budgetProvider: budgetProvider);
    return count > 0;
  }

  Future<void> searchExpenses({
    String? query,
    List<String>? categories,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) async {
    _isSearching = true;
    notifyListeners();

    _searchResults = await DatabaseHelper.instance.searchExpenses(
      query: query,
      categories: categories,
      startDate: startDate,
      endDate: endDate,
      minAmount: minAmount,
      maxAmount: maxAmount,
    );

    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults.clear();
    _isSearching = false;
    notifyListeners();
  }
}
