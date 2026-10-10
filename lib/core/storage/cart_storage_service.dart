import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class CartStorageService {
  static const String boxName = 'cart_box';
  static const String itemsKey = 'cart_items';

  Box? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox(boxName);
    } else {
      _box = Hive.box(boxName);
    }
  }

  Box get box {
    if (_box == null || !_box!.isOpen) {
      _box = Hive.box(boxName);
    }
    return _box!;
  }

  Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    final jsonList = items.map((e) => jsonEncode(e)).toList();
    await box.put(itemsKey, jsonList);
  }

  List<Map<String, dynamic>> getCartItems() {
    final raw = box.get(itemsKey);
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((item) {
        if (item is String) {
          return jsonDecode(item) as Map<String, dynamic>;
        } else if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  Future<void> clearCart() async {
    await box.delete(itemsKey);
  }
}
