import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddEditExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = 'Food';
  String _selectedPaymentMode = 'Cash';
  DateTime _selectedDateTime = DateTime.now();

  final List<String> _paymentModes = ['Cash', 'UPI', 'Card', 'Other'];

  bool get _isEditing => widget.expenseToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final exp = widget.expenseToEdit!;
      _amountController.text = exp.amount.toStringAsFixed(exp.amount.truncateToDouble() == exp.amount ? 0 : 2);
      _noteController.text = exp.note ?? '';
      _selectedCategory = exp.category;
      _selectedPaymentMode = exp.paymentMode ?? 'Cash';
      _selectedDateTime = exp.dateTime;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

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
              title: const Text('Add Custom Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'e.g. Subscriptions',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Choose Color:', style: TextStyle(fontWeight: FontWeight.w600)),
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
                        onTap: () {
                          setDialogState(() => selectedColor = colVal);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(colVal),
                            shape: BoxShape.circle,
                            border: isSel
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSel
                                ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                                : null,
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
                        setState(() {
                          _selectedCategory = nameCtrl.text.trim();
                        });
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

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount')),
      );
      return;
    }

    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    final expense = Expense(
      id: widget.expenseToEdit?.id,
      amount: amount,
      category: _selectedCategory,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      paymentMode: _selectedPaymentMode,
      dateTime: _selectedDateTime,
    );

    if (_isEditing) {
      await expenseProvider.updateExpense(expense, budgetProvider: budgetProvider);
    } else {
      await expenseProvider.addExpense(expense, budgetProvider: budgetProvider);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _saveExpense,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Amount Input with Currency Symbol
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      themeProvider.currencySymbol,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        autofocus: !_isEditing,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          border: InputBorder.none,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter amount';
                          }
                          final parsed = double.tryParse(val.trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Enter positive number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Selector Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Custom'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryProvider.categories.map((cat) {
                  final isSelected = cat.name == _selectedCategory;
                  final iconData = Category.getIconData(cat.icon);
                  final catColor = Color(cat.colorValue);

                  return ChoiceChip(
                    avatar: Icon(
                      iconData,
                      size: 18,
                      color: isSelected ? Colors.white : catColor,
                    ),
                    label: Text(cat.name),
                    selected: isSelected,
                    selectedColor: catColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat.name);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Note / Description Field
              Text(
                'Note / Description (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'e.g. Lunch with team, Fuel, Netflix subscription',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Mode Selector
              Text(
                'Payment Mode',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _paymentModes.map((mode) {
                  final isSelected = mode == _selectedPaymentMode;
                  IconData modeIcon;
                  switch (mode) {
                    case 'Cash':
                      modeIcon = Icons.money;
                      break;
                    case 'UPI':
                      modeIcon = Icons.qr_code_scanner;
                      break;
                    case 'Card':
                      modeIcon = Icons.credit_card;
                      break;
                    case 'Other':
                    default:
                      modeIcon = Icons.account_balance;
                      break;
                  }

                  return ChoiceChip(
                    avatar: Icon(modeIcon, size: 16),
                    label: Text(mode),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedPaymentMode = mode);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Date & Time Picker
              Text(
                'Date & Time',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateFormat('dd MMM yyyy').format(_selectedDateTime)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(DateFormat('hh:mm a').format(_selectedDateTime)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Full-width Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saveExpense,
                  icon: Icon(_isEditing ? Icons.save : Icons.add),
                  label: Text(
                    _isEditing ? 'Update Expense' : 'Save Expense',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
