import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/constant/base_api.dart';

const String baseUrl = ApiConstants.baseUrl;

final countryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final countryApiUrl = Uri.parse('$baseUrl/user-country');
  final response = await http.get(countryApiUrl);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load country data');
  }
});
