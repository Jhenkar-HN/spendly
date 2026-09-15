# Spendly — Personal Daily Expense Tracker Android App 💰

**Spendly** is a fast, clean, and production-ready personal expense tracking Android application built using **Flutter (Dart)**. It operates **100% offline**, storing all data locally in an on-device SQLite database with zero server or cloud dependencies.

---

## ✨ Features

1. **⚡ Fast Add Expense Flow (< 10 seconds)**
   - Numeric input with instant numpad focus.
   - Dynamic category chip selector with color badges.
   - Optional note description.
   - Payment modes: **Cash**, **UPI**, **Card**, **Other**.
   - Editable Date & Time picker (defaults to now).
   - Strict input validation (prevents negative or zero amounts).

2. **📅 Daily View (Home Screen)**
   - Today's date with live summary card of total spent today.
   - Monthly budget progress banner with color-coded safety indicators.
   - List of all transactions logged today sorted by most recent first.
   - **Swipe-to-delete** with an instant **UNDO** SnackBar.
   - Tap any expense to edit.
   - Quick search button in the top bar.
   - Floating Action Button (+) to add new expenses.

3. **🗓️ History / Calendar View**
   - Browse any past or future day using previous/next arrows or the calendar date picker.
   - Displays exact total spent for the chosen date.
   - Full list of expenses logged on that day with swipe/tap actions.

4. **📊 Analytics & Visual Insights**
   - Metric cards: **Total Spent** in period & **Top Spending Category**.
   - Triple metric indicators: **Today**, **This Week**, **This Month**.
   - **Interactive Donut / Pie Chart** powered by `fl_chart` with touch tooltips and percentage breakdown.
   - Detailed category table with amounts and percentages.
   - **Spending Trend Bar Chart** showing daily spend trends over the last 7 or 30 days.

5. **🎯 Monthly Budget Tracking**
   - Set monthly spending limit (e.g., ₹25,000 / $1,000).
   - Visual progress bar:
     - 🟢 **Green (On Track)**: Under 80% of limit.
     - 🟡 **Amber (Near Limit)**: 80% - 100% of limit.
     - 🔴 **Red (Exceeded)**: Exceeded budget with warning badge.
   - Displays spent amount, percentage, and remaining balance.

6. **🔍 Live Search & Filter**
   - Real-time search across transaction notes and category names.
   - Filter drawer/chips by:
     - Multi-category selection
     - Custom date ranges (start date to end date)
     - Minimum and maximum amount bounds
   - Live result count and aggregate sum.

7. **⚙️ Settings & Data Portability**
   - **Currency Symbol Selection**: Indian Rupee (₹), US Dollar ($), Euro (€), British Pound (£), Japanese Yen (¥), Canadian Dollar (C$), Australian Dollar (A$), and more.
   - **Custom Category Manager**: Create custom categories with custom color badges and delete them whenever needed.
   - **CSV Export**: Exports all SQLite database entries to a clean `.csv` file and triggers the native Android share sheet (Drive, WhatsApp, Gmail, Files).
   - **Dark Mode Toggle**: Seamlessly switch between Light and Dark Material 3 themes.
   - **100% Offline & Private**: No analytics trackers, no cloud sync, complete user data ownership.

---

## 📁 Folder Structure

```
spendly/
├── android/                          # Android native project and Gradle setup
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml   # App permissions and activity configs
│   │   │   └── kotlin/.../MainActivity.kt
│   │   └── build.gradle              # App-level build configs & SDK versions (minSdk 21, targetSdk 34)
│   ├── build.gradle                  # Root buildscript
│   └── settings.gradle               # Plugin repository bindings
├── lib/
│   ├── main.dart                     # App entry point, MultiProvider & Material 3 themes
│   ├── models/
│   │   ├── expense.dart              # Expense data model with toMap() / fromMap()
│   │   ├── category.dart             # Category model, icon mappings & color values
│   │   └── budget.dart               # Monthly budget limit model
│   ├── services/
│   │   ├── database_helper.dart      # SQLite database singleton with sqflite CRUD & aggregates
│   │   └── export_service.dart       # CSV file generator & Android share sheet integration
│   ├── providers/
│   │   ├── expense_provider.dart     # Expense state, history queries, trends & search filters
│   │   ├── category_provider.dart    # Category state & custom categories management
│   │   ├── budget_provider.dart      # Monthly budget calculations & status thresholds
│   │   └── theme_provider.dart       # Theme mode (Light/Dark) & currency symbol persistence
│   ├── screens/
│   │   ├── main_navigation_screen.dart # 4-tab bottom navigation shell
│   │   ├── daily_screen.dart         # Home screen: today's summary, list, budget card & FAB
│   │   ├── add_edit_expense_screen.dart # Fast <10s expense logger & editor
│   │   ├── history_screen.dart       # Calendar/date picker history browser
│   │   ├── analytics_screen.dart     # Pie chart, bar trend chart, and period metrics
│   │   ├── search_filter_screen.dart # Search query and multi-parameter filters
│   │   └── settings_screen.dart      # Currency picker, category manager, budget dialog, CSV export
│   └── widgets/
│       ├── expense_card.dart         # Expense item with category icon, details & swipe-to-delete
│       ├── category_chip.dart        # Reusable category chip selector
│       ├── budget_progress_card.dart # Visual budget bar with warning thresholds
│       ├── summary_card.dart         # Metric stat card with icons and trends
│       └── empty_state_view.dart     # Friendly illustration & text for empty states
├── test/
│   └── widget_test.dart              # Model serialization and unit tests
├── pubspec.yaml                      # Dependencies (sqflite, provider, fl_chart, etc.)
└── README.md                         # Project documentation and build guide
```

---

## 🚀 How to Build the Release APK

### Prerequisites
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.10 or newer).
2. Install [Android Studio](https://developer.android.com/studio) or Android Command Line Tools with Android SDK Platform 34.
3. Verify your installation by running:
   ```bash
   flutter doctor
   ```

### Step 1: Install Dependencies
Open a terminal in the project root directory (`c:\5th SEM\Spend`):
```bash
flutter pub get
```

### Step 2: Run in Debug Mode (Emulator or USB Device)
Connect your Android phone (with USB Debugging enabled) or start an Android emulator, then run:
```bash
flutter run
```

### Step 3: Build the Production Release APK
To compile a standalone, optimized release APK:
```bash
flutter build apk --release
```

#### 📦 Where to Find the Output APK File:
Once the build completes, the standalone APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```
You can transfer this `.apk` file directly to any Android phone (Android 5.0 Lollipop or higher) and install it immediately.

---

## 🛠️ How to Add New Features

### 1. Adding a New Default Category
1. Open [`lib/models/category.dart`](file:///c:/5th%20SEM/Spend/lib/models/category.dart).
2. Add a new `Category` to the `defaultCategories()` list:
   ```dart
   Category(name: 'Gifts', icon: 'gifts', colorValue: 0xFFE91E63),
   ```
3. If using a new icon key, register it in `Category.getIconData(String iconKey)`:
   ```dart
   case 'gifts':
     return Icons.card_giftcard;
   ```

### 2. Adding a New Chart Type (e.g., Spending Line Chart)
1. Open [`lib/screens/analytics_screen.dart`](file:///c:/5th%20SEM/Spend/lib/screens/analytics_screen.dart).
2. `fl_chart` supports `LineChart`, `BarChart`, `PieChart`, `RadarChart`, and `ScatterChart`.
3. To add a smooth line chart for spending over time, use `LineChart`:
   ```dart
   LineChart(
     LineChartData(
       lineBarsData: [
         LineChartBarData(
           spots: expenseProvider.spendingTrend.asMap().entries.map((e) {
             return FlSpot(e.key.toDouble(), (e.value['amount'] as num).toDouble());
           }).toList(),
           isCurved: true,
           color: Theme.of(context).colorScheme.primary,
           barWidth: 3,
         ),
       ],
     ),
   )
   ```

### 3. Adding Recurring Subscriptions (Stretch Goal)
1. Create a `Subscription` model in `lib/models/subscription.dart` with `frequency` (e.g. monthly, yearly) and `billingDay`.
2. Add a `subscriptions` table in `lib/services/database_helper.dart`.
3. On app startup in `main.dart`, compare the current date with the last logged subscription date and automatically insert overdue items via `insertExpense()`.

---

## 🔒 Privacy & Local Storage
- **Database**: Standard SQLite engine managed via `sqflite`.
- **Database File**: Stored inside the private app sandboxed directory (`spendly.db`).
- **Permissions**: Only external storage access if user chooses to save an exported CSV file.
- **No telemetry, no advertisements, no external tracking.**
