import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mobile_app/constant/base_api.dart';

final log = Logger();
const String baseUrl = ApiConstants.baseUrl;

final feesProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  try {
    final apiUrl = Uri.parse('$baseUrl/fees-joining-info');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      if (responseData is Map<String, dynamic>) {
        log.d('fees-joining-info data  loaded successfully: $responseData');
        return responseData;
      } else {
        log.d('Invalid data structure: $responseData');
      }
    } else {
      log.d('Invalid response status code: ${response.statusCode}');
    }

    throw Exception('Failed to load fees-joining-info data');
  } catch (error, stackTrace) {
    log.e('Error fetching fees-joining-info data: $error');
    log.e(stackTrace);
    rethrow;
  }
});
