// category_provider.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider {
  static final categoryProvider =
      FutureProvider<Map<String, dynamic>?>((ref) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String mbCategoryKey = 'mb_category';

      final String? mbCategoryJson = prefs.getString(mbCategoryKey);

      if (mbCategoryJson != null) {
        final dynamic mbCategoryData = json.decode(mbCategoryJson);

        if (mbCategoryData is Map<String, dynamic>) {
          return mbCategoryData;
        } else {
          print('Invalid mb_category format: $mbCategoryData');
        }
      } else {
        print('No mb_category data found in shared preferences.');
      }
    } catch (e, stackTrace) {
      print('Error loading mb_category data: $e');
      print('StackTrace: $stackTrace');
    }

    // Return a default value or handle the null case appropriately
    return {'default': 'values'};
  });
}
