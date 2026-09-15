import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/budget_provider.dart';
import 'providers/category_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProxyProvider<BudgetProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update: (_, budgetProvider, expenseProvider) {
            final provider = expenseProvider ?? ExpenseProvider();
            // Sync initial state if available
            return provider;
          },
        ),
      ],
      child: const SpendlyApp(),
    ),
  );
}

class SpendlyApp extends StatelessWidget {
  const SpendlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Light Theme
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E88E5), // Indigo / Blue accent
        brightness: Brightness.light,
        surface: const Color(0xFFF9FAFC),
        surfaceVariant: const Color(0xFFF0F3F8),
      ),
      scaffoldBackgroundColor: const Color(0xFFF9FAFC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 2,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1E88E5).withOpacity(0.18),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );

    // Dark Theme
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E88E5),
        brightness: Brightness.dark,
        surface: const Color(0xFF1A1C1E),
        surfaceVariant: const Color(0xFF24282D),
      ),
      scaffoldBackgroundColor: const Color(0xFF121316),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E2126),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 2,
        backgroundColor: const Color(0xFF1A1C1E),
        indicatorColor: const Color(0xFF1E88E5).withOpacity(0.25),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );

    return MaterialApp(
      title: 'Spendly',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
