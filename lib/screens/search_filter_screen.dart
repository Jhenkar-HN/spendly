import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/expense_card.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _selectedCategories = {};
  DateTimeRange? _selectedDateRange;
  double? _minAmount;
  double? _maxAmount;

  final TextEditingController _minAmountCtrl = TextEditingController();
  final TextEditingController _maxAmountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applySearch();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _minAmountCtrl.dispose();
    _maxAmountCtrl.dispose();
    super.dispose();
  }

  void _applySearch() {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    expenseProvider.searchExpenses(
      query: _searchCtrl.text.trim(),
      categories: _selectedCategories.isNotEmpty ? _selectedCategories.toList() : null,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
      minAmount: _minAmount,
      maxAmount: _maxAmount,
    );
  }

  void _resetFilters() {
    setState(() {
      _searchCtrl.clear();
      _selectedCategories.clear();
      _selectedDateRange = null;
      _minAmount = null;
      _maxAmount = null;
      _minAmountCtrl.clear();
      _maxAmountCtrl.clear();
    });
    _applySearch();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _applySearch();
    }
  }

  void _showFilterBottomSheet() {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Expenses',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              _resetFilters();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Reset All'),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Categories filter
                      const Text(
                        'Filter by Category',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categoryProvider.categories.map((cat) {
                          final isSel = _selectedCategories.contains(cat.name);
                          return FilterChip(
                            label: Text(cat.name),
                            selected: isSel,
                            onSelected: (selected) {
                              setSheetState(() {
                                if (selected) {
                                  _selectedCategories.add(cat.name);
                                } else {
                                  _selectedCategories.remove(cat.name);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Date Range
                      const Text(
                        'Date Range',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _pickDateRange();
                        },
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _selectedDateRange == null
                              ? 'Any Date'
                              : '${DateFormat('d MMM').format(_selectedDateRange!.start)} - ${DateFormat('d MMM yyyy').format(_selectedDateRange!.end)}',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Amount Range
                      const Text(
                        'Amount Range',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minAmountCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Min Amount',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                _minAmount = double.tryParse(val.trim());
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _maxAmountCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max Amount',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                _maxAmount = double.tryParse(val.trim());
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _applySearch();
                        },
                        child: const Text('Apply Filters'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final totalFilteredAmount = expenseProvider.searchResults.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _selectedCategories.isNotEmpty ||
                  _selectedDateRange != null ||
                  _minAmount != null ||
                  _maxAmount != null,
              child: const Icon(Icons.tune),
            ),
            tooltip: 'Filter',
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search notes or categories...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _applySearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              onChanged: (val) => _applySearch(),
            ),
          ),

          // Active filter chips bar
          if (_selectedCategories.isNotEmpty || _selectedDateRange != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_selectedDateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                          '${DateFormat('d MMM').format(_selectedDateRange!.start)} - ${DateFormat('d MMM').format(_selectedDateRange!.end)}',
                        ),
                        onDeleted: () {
                          setState(() => _selectedDateRange = null);
                          _applySearch();
                        },
                      ),
                    ),
                  ..._selectedCategories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(cat),
                        onDeleted: () {
                          setState(() => _selectedCategories.remove(cat));
                          _applySearch();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Search Stats Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${expenseProvider.searchResults.length} results found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Total: ${themeProvider.formatAmount(totalFilteredAmount)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Results List
          Expanded(
            child: expenseProvider.searchResults.isEmpty
                ? const EmptyStateView(
                    icon: Icons.search_off,
                    title: 'No expenses match your search',
                    subtitle: 'Try changing keywords, clear category chips or widen the date range.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: expenseProvider.searchResults.length,
                    itemBuilder: (context, index) {
                      final exp = expenseProvider.searchResults[index];
                      return ExpenseCard(expense: exp);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
