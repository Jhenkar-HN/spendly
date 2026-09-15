import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final String icon; // Icon identifier key, e.g. 'fastfood', 'flight', etc.
  final bool isCustom;
  final int colorValue; // Hex color integer

  Category({
    this.id,
    required this.name,
    required this.icon,
    this.isCustom = false,
    this.colorValue = 0xFF2196F3,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'icon': icon,
      'isCustom': isCustom ? 1 : 0,
      'colorValue': colorValue,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      isCustom: (map['isCustom'] as int) == 1,
      colorValue: map['colorValue'] != null ? map['colorValue'] as int : 0xFF2196F3,
    );
  }

  static IconData getIconData(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'food':
      case 'restaurant':
      case 'fastfood':
        return Icons.restaurant;
      case 'travel':
      case 'flight':
      case 'commute':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
      case 'receipt':
        return Icons.receipt_long;
      case 'entertainment':
      case 'movie':
        return Icons.movie;
      case 'health':
      case 'medical':
        return Icons.medical_services;
      case 'groceries':
      case 'local_grocery_store':
        return Icons.local_grocery_store;
      case 'education':
      case 'school':
        return Icons.school;
      case 'fitness':
      case 'gym':
        return Icons.fitness_center;
      case 'gifts':
        return Icons.card_giftcard;
      case 'investment':
        return Icons.trending_up;
      case 'other':
      default:
        return Icons.category;
    }
  }

  static List<Category> defaultCategories() {
    return [
      Category(name: 'Food', icon: 'food', colorValue: 0xFFFF5722),
      Category(name: 'Travel', icon: 'travel', colorValue: 0xFF2196F3),
      Category(name: 'Shopping', icon: 'shopping', colorValue: 0xFFE91E63),
      Category(name: 'Bills', icon: 'bills', colorValue: 0xFFFF9800),
      Category(name: 'Entertainment', icon: 'entertainment', colorValue: 0xFF9C27B0),
      Category(name: 'Health', icon: 'health', colorValue: 0xFF4CAF50),
      Category(name: 'Groceries', icon: 'groceries', colorValue: 0xFF009688),
      Category(name: 'Other', icon: 'other', colorValue: 0xFF607D8B),
    ];
  }
}
