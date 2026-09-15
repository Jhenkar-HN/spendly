import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import 'database_helper.dart';

class ExportService {
  static Future<void> exportExpensesToCSV() async {
    final expenses = await DatabaseHelper.instance.getAllExpenses();

    List<List<dynamic>> rows = [
      [
        'ID',
        'Amount',
        'Category',
        'Note',
        'Payment Mode',
        'Date',
        'Time',
        'ISO Timestamp'
      ]
    ];

    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');

    for (final exp in expenses) {
      rows.add([
        exp.id ?? '',
        exp.amount,
        exp.category,
        exp.note ?? '',
        exp.paymentMode ?? 'Other',
        dateFormat.format(exp.dateTime),
        timeFormat.format(exp.dateTime),
        exp.dateTime.toIso8601String(),
      ]);
    }

    final String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/spendly_expenses_$timestamp.csv';
    final file = File(filePath);

    await file.writeAsString(csvData);

    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Spendly Expenses Export - $timestamp',
      subject: 'Spendly Expenses Backup',
    );
  }
}
