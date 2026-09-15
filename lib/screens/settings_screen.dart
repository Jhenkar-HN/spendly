import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/theme_provider.dart';
import '../services/export_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showCurrencySelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currencies = [
      {'symbol': '₹', 'name': 'Indian Rupee (INR)'},
      {'symbol': '\$', 'name': 'US Dollar (USD)'},
      {'symbol': '€', 'name': 'Euro (EUR)'},
      {'symbol': '£', 'name': 'British Pound (GBP)'},
      {'symbol': '¥', 'name': 'Japanese Yen (JPY)'},
      {'symbol': '₩', 'name': 'Korean Won (KRW)'},
      {'symbol': 'C\$', 'name': 'Canadian Dollar (CAD)'},
      {'symbol': 'A\$', 'name': 'Australian Dollar (AUD)'},
      {'symbol': '฿', 'name': 'Thai Baht (THB)'},
      {'symbol': 'Rp', 'name': 'Indonesian Rupiah (IDR)'},
      {'symbol': 'AED', 'name': 'UAE Dirham (AED)'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Currency Symbol',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currencies.length,
                  itemBuilder: (context, i) {
                    final curr = currencies[i];
                    final isSelected = curr['symbol'] == themeProvider.currencySymbol;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceVariant,
                        child: Text(
                          curr['symbol']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(curr['name']!),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                          : null,
                      onTap: () {
                        themeProvider.setCurrencySymbol(curr['symbol']!);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoriesManager(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()),
    );
  }

  Future<void> _exportCSV(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing CSV export...')),
      );
      await ExportService.exportExpensesToCSV();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Preferences Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'PREFERENCES',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency Symbol'),
            subtitle: Text('Currently: ${themeProvider.currencySymbol}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCurrencySelector(context),
          ),
          SwitchListTile(
            secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            title: const Text('Dark Mode'),
            subtitle: Text(themeProvider.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled'),
            value: themeProvider.isDarkMode,
            onChanged: (val) => themeProvider.toggleDarkMode(val),
          ),

          const Divider(),

          // Budget & Categories Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'BUDGET & CATEGORIES',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Monthly Budget Limit'),
            subtitle: Text(
              budgetProvider.hasBudget
                  ? '${themeProvider.formatAmount(budgetProvider.budgetLimit)} for ${budgetProvider.currentMonthKey}'
                  : 'Not set for this month',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const SetBudgetDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Manage Categories'),
            subtitle: const Text('Add or remove custom categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCategoriesManager(context),
          ),

          const Divider(),

          // Data & Backup Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'DATA & BACKUP',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export Data as CSV'),
            subtitle: const Text('Backup all transactions & share via Android share sheet'),
            trailing: const Icon(Icons.share),
            onTap: () => _exportCSV(context),
          ),
          const ListTile(
            leading: Icon(Icons.cloud_off_outlined),
            title: Text('100% Offline & Private'),
            subtitle: Text('All data is encrypted and stored strictly on this device in SQLite.'),
          ),

          const Divider(),

          // App Info
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'ABOUT',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Spendly v1.0.0'),
            subtitle: const Text('Personal Daily Expense Tracker for Android'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Spendly',
                applicationVersion: '1.0.0',
                applicationIcon: const CircleAvatar(
                  child: Icon(Icons.account_balance_wallet),
                ),
                children: const [
                  Text(
                    'Spendly is a standalone, offline-first personal finance tracker designed for rapid expense logging and insightful analytics.',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// SET BUDGET DIALOG
// -------------------------------------------------------------

class SetBudgetDialog extends StatefulWidget {
  const SetBudgetDialog({super.key});

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    _controller = TextEditingController(
      text: budgetProvider.budgetLimit > 0
          ? budgetProvider.budgetLimit.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return AlertDialog(
      title: const Text('Set Monthly Budget'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target for ${budgetProvider.currentMonthKey}:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              prefixText: '${themeProvider.currencySymbol} ',
              hintText: 'e.g. 25000',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final val = double.tryParse(_controller.text.trim());
            if (val != null && val > 0) {
              await budgetProvider.setMonthlyBudget(val);
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text('Save Budget'),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// MANAGE CATEGORIES SCREEN
// -------------------------------------------------------------

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    int selectedColor = 0xFF2196F3;
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'e.g. Subscriptions, Pet Care',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Color Badge:', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      0xFF2196F3, 0xFF4CAF50, 0xFFFF9800, 0xFFE91E63,
                      0xFF9C27B0, 0xFF009688, 0xFFFF5722, 0xFF795548
                    ].map((colVal) {
                      final isSel = selectedColor == colVal;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = colVal),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(colVal),
                            shape: BoxShape.circle,
                            border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                            boxShadow: isSel ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      final success = await categoryProvider.addCategory(
                        nameCtrl.text.trim(),
                        'other',
                        selectedColor,
                      );
                      if (success && mounted) {
                        Navigator.pop(ctx);
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: categoryProvider.categories.length,
        separatorBuilder: (context, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final cat = categoryProvider.categories[index];
          final color = Color(cat.colorValue);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                Category.getIconData(cat.icon),
                color: color,
                size: 20,
              ),
            ),
            title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(cat.isCustom ? 'Custom Category' : 'Default Category'),
            trailing: cat.isCustom
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete Category',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Category?'),
                          content: Text('Are you sure you want to remove "${cat.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && cat.id != null) {
                        await categoryProvider.deleteCategory(cat.id!);
                      }
                    },
                  )
                : const Chip(
                    label: Text('System', style: TextStyle(fontSize: 10)),
                    visualDensity: VisualDensity.compact,
                  ),
          );
        },
      ),
    );
  }
}
