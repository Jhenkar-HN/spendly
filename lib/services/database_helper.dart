import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/budget.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spendly.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        paymentMode TEXT,
        dateTime TEXT NOT NULL
      )
    ''');

    // Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL,
        isCustom INTEGER NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');

    // Budgets Table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL UNIQUE,
        limitAmount REAL NOT NULL
      )
    ''');

    // Seed default categories
    final batch = db.batch();
    for (final cat in Category.defaultCategories()) {
      batch.insert('categories', cat.toMap());
    }
    await batch.commit(noResult: true);
  }

  // -------------------------------------------------------------
  // EXPENSES CRUD & QUERIES
  // -------------------------------------------------------------

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      orderBy: 'dateTime DESC',
    );
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<List<Expense>> getExpensesForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0).toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toIso8601String();

    final maps = await db.query(
      'expenses',
      where: 'dateTime >= ? AND dateTime <= ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'dateTime DESC',
    );
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final startIso = DateTime(start.year, start.month, start.day, 0, 0, 0).toIso8601String();
    final endIso = DateTime(end.year, end.month, end.day, 23, 59, 59, 999).toIso8601String();

    final maps = await db.query(
      'expenses',
      where: 'dateTime >= ? AND dateTime <= ?',
      whereArgs: [startIso, endIso],
      orderBy: 'dateTime DESC',
    );
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<double> getTotalForDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final startIso = DateTime(start.year, start.month, start.day, 0, 0, 0).toIso8601String();
    final endIso = DateTime(end.year, end.month, end.day, 23, 59, 59, 999).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM expenses
      WHERE dateTime >= ? AND dateTime <= ?
    ''', [startIso, endIso]);

    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  Future<Map<String, double>> getCategoryTotalsForDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final startIso = DateTime(start.year, start.month, start.day, 0, 0, 0).toIso8601String();
    final endIso = DateTime(end.year, end.month, end.day, 23, 59, 59, 999).toIso8601String();

    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total FROM expenses
      WHERE dateTime >= ? AND dateTime <= ?
      GROUP BY category
      ORDER BY total DESC
    ''', [startIso, endIso]);

    final Map<String, double> categoryTotals = {};
    for (final row in result) {
      final category = row['category'] as String;
      final total = (row['total'] as num).toDouble();
      categoryTotals[category] = total;
    }
    return categoryTotals;
  }

  Future<List<Map<String, dynamic>>> getDailySpendingTrend(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));
    final expenses = await getExpensesByDateRange(startDate, now);

    final Map<String, double> dayTotals = {};
    for (int i = 0; i < days; i++) {
      final d = startDate.add(Duration(days: i));
      final key = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      dayTotals[key] = 0.0;
    }

    for (final exp in expenses) {
      final d = exp.dateTime;
      final key = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      if (dayTotals.containsKey(key)) {
        dayTotals[key] = (dayTotals[key] ?? 0.0) + exp.amount;
      }
    }

    return dayTotals.entries.map((e) => {
      'date': e.key,
      'amount': e.value,
    }).toList();
  }

  Future<List<Expense>> searchExpenses({
    String? query,
    List<String>? categories,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) async {
    final db = await database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('(note LIKE ? OR category LIKE ?)');
      whereArgs.add('%${query.trim()}%');
      whereArgs.add('%${query.trim()}%');
    }

    if (categories != null && categories.isNotEmpty) {
      final placeholders = List.filled(categories.length, '?').join(',');
      whereClauses.add('category IN ($placeholders)');
      whereArgs.addAll(categories);
    }

    if (startDate != null) {
      final startIso = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0).toIso8601String();
      whereClauses.add('dateTime >= ?');
      whereArgs.add(startIso);
    }

    if (endDate != null) {
      final endIso = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999).toIso8601String();
      whereClauses.add('dateTime <= ?');
      whereArgs.add(endIso);
    }

    if (minAmount != null) {
      whereClauses.add('amount >= ?');
      whereArgs.add(minAmount);
    }

    if (maxAmount != null) {
      whereClauses.add('amount <= ?');
      whereArgs.add(maxAmount);
    }

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final maps = await db.query(
      'expenses',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'dateTime DESC',
    );
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  // -------------------------------------------------------------
  // CATEGORIES CRUD
  // -------------------------------------------------------------

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'isCustom ASC, id ASC');
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ? AND isCustom = 1', whereArgs: [id]);
  }

  // -------------------------------------------------------------
  // BUDGET CRUD
  // -------------------------------------------------------------

  Future<Budget?> getBudgetForMonth(String month) async {
    final db = await database;
    final maps = await db.query('budgets', where: 'month = ?', whereArgs: [month], limit: 1);
    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  Future<int> setBudget(Budget budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
