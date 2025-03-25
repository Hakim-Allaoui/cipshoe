import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shoe_item.dart';

class StorageService {
  static const String _inventoryKey = 'inventory_data';

  // Save inventory to SharedPreferences
  static Future<bool> saveInventory(List<ShoeItem> inventory) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert ShoeItem list to JSON
    final jsonData = inventory.map((item) => item.toJson()).toList();
    final jsonString = jsonEncode(jsonData);

    return prefs.setString(_inventoryKey, jsonString);
  }

  // Load inventory from SharedPreferences
  static Future<List<ShoeItem>> loadInventory() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_inventoryKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonData = jsonDecode(jsonString) as List;
      return jsonData.map((item) => ShoeItem.fromJson(item)).toList();
    } catch (e) {
      print('Error loading inventory: $e');
      return [];
    }
  }

  // Clear all saved data
  static Future<bool> clearInventory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_inventoryKey);
  }
}
