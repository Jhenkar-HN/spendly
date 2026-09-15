import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/expense_card.dart';
import 'add_edit_expense_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _currentSelectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.setSelectedHistoryDate(_currentSelectedDate);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentSelectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _currentSelectedDate = picked);
      if (mounted) {
        final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
        await expenseProvider.setSelectedHistoryDate(picked);
      }
    }
  }

  void _changeDay(int offset) {
    final newDate = _currentSelectedDate.add(Duration(days: offset));
    setState(() => _currentSelectedDate = newDate);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    expenseProvider.setSelectedHistoryDate(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final isToday = DateUtils.isSameDay(_currentSelectedDate, DateTime.now());
    final displayDateStr = isToday
        ? 'Today, ${DateFormat('d MMMM yyyy').format(_currentSelectedDate)}'
        : DateFormat('EEEE, d MMMM yyyy').format(_currentSelectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Pick Date',
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Header with Prev / Next day arrows
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous Day',
                  onPressed: () => _changeDay(-1),
                ),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          displayDateStr,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next Day',
                  onPressed: () => _changeDay(1),
                ),
              ],
            ),
          ),

          // Total spent on this specific date
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day Total',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      themeProvider.formatAmount(expenseProvider.historyDateTotal),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${expenseProvider.historyExpenses.length} ${expenseProvider.historyExpenses.length == 1 ? 'transaction' : 'transactions'}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Transactions list for the date
          Expanded(
            child: expenseProvider.historyExpenses.isEmpty
                ? EmptyStateView(
                    icon: Icons.event_busy,
                    title: 'No expenses for this date',
                    subtitle: 'No records found for ${DateFormat('d MMM yyyy').format(_currentSelectedDate)}.',
                    actionLabel: 'Log Expense for This Day',
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditExpenseScreen(
                            expenseToEdit: null,
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: expenseProvider.historyExpenses.length,
                    itemBuilder: (context, index) {
                      final exp = expenseProvider.historyExpenses[index];
                      return ExpenseCard(expense: exp);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
