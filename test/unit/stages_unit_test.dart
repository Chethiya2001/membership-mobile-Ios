import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';


import 'stages_unit_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  const String apiBaseUrl = 'https://membership-api.codefusion.com.lk/api/v1';
  const String apiEndpoint1 = '$apiBaseUrl/user-membership-1st-form-update';
  const String apiEndpoint2 = '$apiBaseUrl/user-membership-2nd-form-update';
  const String apiEndpoint3 = '$apiBaseUrl/user-membership-3rd-form-update';
  const String apiEndpoint4 = '$apiBaseUrl/user-membership-4th-form-update';

  group('Organization', () {
    test('Stage 01', () async {
      final client = MockClient();

      when(
        client.post(
          Uri.parse(apiEndpoint1),
          body: {
            "first_name": "John1",
            "last_name": "Doe",
            "email": "johndoe1@example.com",
            "password": "password",
            "mobile": "1234567890",
            "country": "US",
            "second_name": "secondName",
            "surname": "lastName",
            "job_title": "jobTitle",
            "institution": "institution",
            "department": "department",
            "address_line1": "addressline1",
            "address_line2": " addressline2",
            "address_line3": "addressline3",
            "po_code": "12121",
            "city": "city",
            "state": "state",
            "fax": "",
            "title": 11,
            "gender": "M",
            "age_range": 1,
            "job_category": 0,
            "language": "ENG",
            "qualification": 11,
            "type_of_institution": 10,
            "nationality": "AFR",
          },
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthManager.tokenKey}',
          },
        ),
      ).thenAnswer((_) async => http.Response("Successful", 201));

      final response = await client.post(
        Uri.parse(apiEndpoint1),
        body: {
          "first_name": "John1",
          "last_name": "Doe",
          "email": "johndoe1@example.com",
          "password": "password",
          "mobile": "1234567890",
          "country": "US",
          "second_name": "secondName",
          "surname": "lastName",
          "job_title": "jobTitle",
          "institution": "institution",
          "department": "department",
          "address_line1": "addressline1",
          "address_line2": " addressline2",
          "address_line3": "addressline3",
          "po_code": "12121",
          "city": "city",
          "state": "state",
          "fax": "",
          "title": 11,
          "gender": "M",
          "age_range": 1,
          "job_category": 0,
          "language": "ENG",
          "qualification": 11,
          "type_of_institution": 10,
          "nationality": "AFR",
        },
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthManager.tokenKey}',
        },
      );

      expect(response.statusCode, 201);
      expect(response.body, "Successful");
      verify(client.post(
        Uri.parse(apiEndpoint1),
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).called(1);
    });

    test('Stage 02', () async {
      final client = MockClient();

      when(
        client.post(
          Uri.parse(apiEndpoint2),
          body: {
            "address1": "addressline1",
            "city": "city",
            "country": "AF",
            "email": "johndoe1@example.com",
            "mobile": "1234567890",
            "mobileCode": "93",
            "price_book_entry_id": "154",
            "product_custom_price": "2000",
            "membership_category": "BP",
            "item_ids": ""
          },
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthManager.tokenKey}',
          },
        ),
      ).thenAnswer((_) async => http.Response("Successful", 201));

      final response = await client.post(
        Uri.parse(apiEndpoint2),
        body: {
          "address1": "addressline1",
          "city": "city",
          "country": "AF",
          "email": "johndoe1@example.com",
          "mobile": "1234567890",
          "mobileCode": "93",
          "price_book_entry_id": "154",
          "product_custom_price": "2000",
          "membership_category": "BP",
          "item_ids": ""
        },
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthManager.tokenKey}',
        },
      );

      expect(response.statusCode, 201);
      expect(response.body, "Successful");
      verify(client.post(
        Uri.parse(apiEndpoint2),
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).called(1);
    });

    test('Stage 03', () async {
      final client = MockClient();

      when(
        client.post(
          Uri.parse(apiEndpoint3),
          body: {
            "membership_id": "000036",
            "about_yourself": "about_yourself",
            "prop_scientific_section": "sceintificSection",
            "union_region": "unionRegion",
            "prop_list_serves": "other",
            "prop_working_groups": "work"
          },
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthManager.tokenKey}',
          },
        ),
      ).thenAnswer((_) async => http.Response("Successful", 201));

      final response = await client.post(
        Uri.parse(apiEndpoint3),
        body: {
          "membership_id": "000036",
          "about_yourself": "about_yourself",
          "prop_scientific_section": "sceintificSection",
          "union_region": "unionRegion",
          "prop_list_serves": "other",
          "prop_working_groups": "work"
        },
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthManager.tokenKey}',
        },
      );

      expect(response.statusCode, 201);
      expect(response.body, "Successful");
      verify(client.post(
        Uri.parse(apiEndpoint3),
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).called(1);
    });
    test('Stage 04', () async {
      final client = MockClient();

      when(
        client.post(
          Uri.parse(apiEndpoint4),
          body: {
            "membership_id": "000036",
          },
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthManager.tokenKey}',
          },
        ),
      ).thenAnswer((_) async => http.Response("Successful", 201));

      final response = await client.post(
        Uri.parse(apiEndpoint4),
        body: {
          "membership_id": "000036",
          "about_yourself": "about_yourself",
          "prop_scientific_section": "sceintificSection",
          "union_region": "unionRegion",
          "prop_list_serves": "other",
          "prop_working_groups": "work"
        },
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthManager.tokenKey}',
        },
      );

      expect(response.statusCode, 201);
      expect(response.body, "Successful");
      verify(client.post(
        Uri.parse(apiEndpoint4),
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).called(1);
    });
  });
}
