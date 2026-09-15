import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/settings_screen.dart';

class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (!budgetProvider.hasBudget) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Set a monthly budget to track savings',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const SetBudgetDialog(),
                  );
                },
                child: const Text('Set Budget'),
              ),
            ],
          ),
        ),
      );
    }

    Color progressColor;
    String statusText;
    switch (budgetProvider.status) {
      case BudgetStatus.exceeded:
        progressColor = Colors.red.shade600;
        statusText = 'Budget Exceeded!';
        break;
      case BudgetStatus.warning:
        progressColor = Colors.amber.shade700;
        statusText = 'Near Limit (>=80%)';
        break;
      case BudgetStatus.normal:
      default:
        progressColor = Colors.green.shade600;
        statusText = 'On Track';
        break;
    }

    final double percent = budgetProvider.budgetLimit > 0
        ? (budgetProvider.monthSpent / budgetProvider.budgetLimit * 100)
        : 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: progressColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 20, color: progressColor),
                    const SizedBox(width: 8),
                    Text(
                      'Monthly Budget',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: budgetProvider.progress,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 10),

            // Spent vs Limit numbers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${themeProvider.formatAmount(budgetProvider.monthSpent)} (${percent.toStringAsFixed(1)}%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Limit: ${themeProvider.formatAmount(budgetProvider.budgetLimit)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            if (budgetProvider.status != BudgetStatus.exceeded) ...[
              const SizedBox(height: 4),
              Text(
                'Remaining: ${themeProvider.formatAmount(budgetProvider.remainingBudget)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
