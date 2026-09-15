import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/expense_card.dart';
import 'add_edit_expense_screen.dart';
import 'search_filter_screen.dart';

class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);

    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spendly',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formattedDate,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search & Filter',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchFilterScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              expenseProvider.refreshAll(budgetProvider: budgetProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => expenseProvider.refreshAll(budgetProvider: budgetProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Daily Total Spent Hero Card
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Spent Today',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${expenseProvider.todayExpenses.length} ${expenseProvider.todayExpenses.length == 1 ? 'item' : 'items'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      themeProvider.formatAmount(expenseProvider.todayTotal),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Monthly Budget Progress Banner
            const SliverToBoxAdapter(
              child: BudgetProgressCard(),
            ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Transactions",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (expenseProvider.todayExpenses.isNotEmpty)
                      Text(
                        'Swipe left to delete',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Expenses List or Empty State
            if (expenseProvider.todayExpenses.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateView(
                  icon: Icons.receipt_long_outlined,
                  title: 'No expenses logged today',
                  subtitle: 'Tap the + button below to quickly record your first daily expense!',
                  actionLabel: 'Add Expense',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditExpenseScreen(),
                      ),
                    );
                  },
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exp = expenseProvider.todayExpenses[index];
                    return ExpenseCard(expense: exp);
                  },
                  childCount: expenseProvider.todayExpenses.length,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditExpenseScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
