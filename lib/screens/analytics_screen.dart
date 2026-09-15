import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/summary_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final categoryTotals = expenseProvider.analyticsCategoryTotals;
    final totalSpentInPeriod = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Analytics',
            onPressed: () => expenseProvider.loadAnalyticsData(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Today', label: Text('Today')),
                  ButtonSegment(value: 'Week', label: Text('This Week')),
                  ButtonSegment(value: 'Month', label: Text('This Month')),
                ],
                selected: {expenseProvider.analyticsPeriod},
                onSelectionChanged: (Set<String> newSelection) {
                  expenseProvider.setAnalyticsPeriod(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 12),

            // Top Summary Cards Grid (Total Spent, Top Category)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Total Spent',
                      amount: themeProvider.formatAmount(totalSpentInPeriod),
                      icon: Icons.payments_outlined,
                      accentColor: theme.colorScheme.primary,
                      subtitle: 'In ${expenseProvider.analyticsPeriod}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'Top Category',
                      amount: expenseProvider.topCategory,
                      icon: Icons.star_border,
                      accentColor: Colors.orange.shade700,
                      subtitle: expenseProvider.topCategoryAmount > 0
                          ? themeProvider.formatAmount(expenseProvider.topCategoryAmount)
                          : 'No spend',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Triple quick metrics (Today, Week, Month totals)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniMetric(
                        context,
                        'Today',
                        themeProvider.formatAmount(expenseProvider.todayTotal),
                      ),
                      Container(height: 30, width: 1, color: theme.colorScheme.outlineVariant),
                      _buildMiniMetric(
                        context,
                        'This Week',
                        themeProvider.formatAmount(expenseProvider.weekTotal),
                      ),
                      Container(height: 30, width: 1, color: theme.colorScheme.outlineVariant),
                      _buildMiniMetric(
                        context,
                        'This Month',
                        themeProvider.formatAmount(expenseProvider.monthTotal),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Breakdown Chart Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Category Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (categoryTotals.isEmpty || totalSpentInPeriod <= 0)
              const EmptyStateView(
                icon: Icons.pie_chart_outline,
                title: 'No spending in this period',
                subtitle: 'Log expenses to see dynamic category breakdowns.',
              )
            else ...[
              // Donut / Pie Chart
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedPieIndex = -1;
                            return;
                          }
                          _touchedPieIndex =
                              pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 46,
                    sections: _buildPieSections(
                      categoryTotals,
                      totalSpentInPeriod,
                      categoryProvider,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Legend Table
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: categoryTotals.length,
                    separatorBuilder: (context, i) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = categoryTotals.entries.elementAt(index);
                      final catObj = categoryProvider.getCategoryByName(entry.key);
                      final color = Color(catObj.colorValue);
                      final percent = (entry.value / totalSpentInPeriod) * 100;

                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Category.getIconData(catObj.icon),
                            color: color,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              themeProvider.formatAmount(entry.value),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${percent.toStringAsFixed(1)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),

            // Spending Trend Bar Chart Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spending Trend (${expenseProvider.analyticsPeriod == 'Month' ? 'Last 30 Days' : 'Last 7 Days'})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (expenseProvider.spendingTrend.isEmpty)
              const Center(child: Text('No trend data available'))
            else
              Container(
                height: 220,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final dayData = expenseProvider.spendingTrend[group.x.toInt()];
                          return BarTooltipItem(
                            '${dayData['date']}\n',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: themeProvider.formatAmount(rod.toY),
                                style: const TextStyle(color: Colors.amber, fontSize: 13),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= expenseProvider.spendingTrend.length) {
                              return const SizedBox.shrink();
                            }
                            // Show labels periodically to avoid clutter
                            final step = expenseProvider.spendingTrend.length > 10 ? 5 : 1;
                            if (idx % step != 0 && idx != expenseProvider.spendingTrend.length - 1) {
                              return const SizedBox.shrink();
                            }
                            final dateStr = expenseProvider.spendingTrend[idx]['date'] as String;
                            final parts = dateStr.split('-');
                            final label = '${parts[2]}/${parts[1]}';
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: _buildBarGroups(expenseProvider.spendingTrend, theme.colorScheme.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> categoryTotals,
    double total,
    CategoryProvider categoryProvider,
  ) {
    int i = 0;
    return categoryTotals.entries.map((entry) {
      final isTouched = i == _touchedPieIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final catObj = categoryProvider.getCategoryByName(entry.key);
      final color = Color(catObj.colorValue);
      final percent = (entry.value / total) * 100;
      i++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildBarGroups(List<Map<String, dynamic>> trend, Color barColor) {
    final List<BarChartGroupData> groups = [];
    for (int i = 0; i < trend.length; i++) {
      final double amount = (trend[i]['amount'] as num).toDouble();
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: amount > 0 ? barColor : barColor.withOpacity(0.15),
              width: trend.length > 15 ? 6 : 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return groups;
  }
}
