import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';


import 'organization_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  const String apiBaseUrl = 'https://membership-api.codefusion.com.lk/api/v1';
  const String apiEndpoint1 =
      '$apiBaseUrl/user-organization-membership-add-form';

  group('Stages', () {
    test('Stage 01', () async {
      final client = MockClient();

      // Define the post fields
      final Map<String, dynamic> postFields = {
        "first_name": "John1",
        "second_name": "secondName",
        "surname": "lastName",
        "email": "johndoe1@example.com",
        "mobile": "1234567890",
        "mobileCode": "93",
        "job_title": "jobTitle",
        "institution": "institution",
        "department": "department",
        "address_line1": "addressline1",
        "address_line2": "addressline2",
        "address_line3": "addressline3",
        "po_code": "12121",
        "city": "city",
        "state": "state",
        "fax": "",
        "country": "US",
        "title": 11,
        "gender": "M",
        "age_range": 1,
        "job_category": 0,
        "language": "ENG",
        "qualification": 11,
        "type_of_institution": 10,
        "nationality": "AFR",
        "union_region": "unionRegion"
      };

      when(
        client.post(
          Uri.parse(apiEndpoint1),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthManager.tokenKey}',
          },
          body: jsonEncode(postFields),
        ),
      ).thenAnswer((_) async => http.Response("Successful", 201));

      final response = await client.post(
        Uri.parse(apiEndpoint1),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthManager.tokenKey}',
        },
        body: jsonEncode(postFields),
      );

      expect(response.statusCode, 201);
      expect(response.body, "Successful");
      verify(client.post(
        Uri.parse(apiEndpoint1),
        headers: anyNamed('headers'),
        body: jsonEncode(postFields),
      )).called(1);
    });
  });
}
