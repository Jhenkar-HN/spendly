import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/database_helper.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = true;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await DatabaseHelper.instance.getAllCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(String name, String icon, int colorValue) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    // Check if category name already exists (case-insensitive)
    if (_categories.any((c) => c.name.toLowerCase() == trimmed.toLowerCase())) {
      return false;
    }

    final newCat = Category(
      name: trimmed,
      icon: icon,
      isCustom: true,
      colorValue: colorValue,
    );

    final id = await DatabaseHelper.instance.insertCategory(newCat);
    if (id > 0) {
      await loadCategories();
      return true;
    }
    return false;
  }

  Future<bool> deleteCategory(int id) async {
    final deleted = await DatabaseHelper.instance.deleteCategory(id);
    if (deleted > 0) {
      await loadCategories();
      return true;
    }
    return false;
  }

  Category getCategoryByName(String name) {
    return _categories.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => Category(
        name: name,
        icon: 'other',
        colorValue: 0xFF607D8B,
      ),
    );
  }
}
