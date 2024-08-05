import 'dart:convert';
import 'package:mobile_app/constant/base_api.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/membership/membership_catergories/model/section_model.dart';

class MemebrshipSectionService {
  static Future<List<Section>> getAllSectionData() async {
    try {
      const String apiBaseUrl = ApiConstants.baseUrl;
      const String apiEndpoint = '$apiBaseUrl/membership-groups';
      final response = await http.get(Uri.parse(apiEndpoint));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> sectionJsonData = jsonResponse['success'];
        return sectionJsonData.map((json) => Section.fromJson(json)).toList();
      } else {
        throw Exception('Failed to Get sections Data');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
