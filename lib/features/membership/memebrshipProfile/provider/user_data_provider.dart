import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/constant/base_api.dart';

const String baseUrl = ApiConstants.baseUrl;

final titleProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final titleApiUrl = Uri.parse('$baseUrl/user-title');
  final response = await http.get(titleApiUrl);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load country data');
  }
});
final genderProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final genderApiUrl = Uri.parse('$baseUrl/user-gender');
  final response = await http.get(genderApiUrl);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load gender data');
  }
});

final languageProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final languageApiUrl = Uri.parse('$baseUrl/user-language');
  final response = await http.get(languageApiUrl);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load language data');
  }
});
final qualificationProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final qualificationUrl = Uri.parse('$baseUrl/user-qualification');
  final response = await http.get(qualificationUrl);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load qualification data');
  }
});
final institutionProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final institutionApiUrl = Uri.parse('$baseUrl/user-typeOfInstitution');
  final response = await http.get(institutionApiUrl);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load institution data');
  }
});
final jobCatergoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final jobCatergoryApiUrl = Uri.parse('$baseUrl/user-jobCatagory');
  final response = await http.get(jobCatergoryApiUrl);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load jobCatergory data');
  }
});
final ageRangeProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final ageRangeApiUrl = Uri.parse('$baseUrl/user-ageRange');
  final response = await http.get(ageRangeApiUrl);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load ageRange data');
  }
});

final nationalityProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final nationalityApiUrl = Uri.parse('$baseUrl/user-nationality');
    final response = await http.get(nationalityApiUrl);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load nationality data');
    }
  } catch (error) {
    print('Error fetching nationality data: $error');
    rethrow; // Rethrow the error to trigger the error state
  }
});

final moCodeProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final nationalityApiUrl = Uri.parse('$baseUrl/user-phoneCode');
    final response = await http.get(nationalityApiUrl);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load phone Code data');
    }
  } catch (error) {
    print('Error fetching Phone Code data: $error');
    rethrow;
  }
});

final departmentProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final nationalityApiUrl = Uri.parse('$baseUrl/departments/1');
    final response = await http.get(nationalityApiUrl);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load department  data');
    }
  } catch (error) {
    print('Error fetching department data: $error');
    rethrow;
  }
});
