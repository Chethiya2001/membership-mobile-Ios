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
  const String apiEndpoint1 = '$apiBaseUrl/get-election?orgId=1';
  const String apiEndpoint2 = '$apiBaseUrl/create-application/1';
  const String apiEndpoint3 = '$apiBaseUrl  /create-vote/1';

  group(
    'Election Test',
    () {
      test('Get All Elections', () async {
        final client = MockClient();

        when(
          client.get(
            Uri.parse(apiEndpoint1),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AuthManager.tokenKey}',
            },
          ),
        ).thenAnswer((_) async => http.Response("Successful", 200));

        final response = await client.get(
          Uri.parse(apiEndpoint1),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthManager.tokenKey}',
          },
        );

        expect(response.statusCode, 200);
        expect(response.body, "Successful");
        verify(client.get(
          Uri.parse(apiEndpoint1),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthManager.tokenKey}',
          },
        )).called(1);
      });
      test('Apply for Candidate', () async {
        final client = MockClient();

        // Define the post fields
        final Map<String, dynamic> postFields = {
          "election_id": "1",
          "position_id": "2",
          "member_id": "3",
          "election_position": "President",
          "country": "US",
          "description": "I am running for President",
          "involvement": "Community leader",
          "future_plan": "Improve community services",
          "agreement": "1",
          "active": "1",
          "approve": "1",
          "present_file": "path/to/present_file",
          "endorsement_cv": "path/to/endorsement_cv"
        };

        when(
          client.post(
            Uri.parse(apiEndpoint2),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AuthManager.tokenKey}',
            },
            body: jsonEncode(postFields),
          ),
        ).thenAnswer((_) async => http.Response("Application Successful", 201));

        final response = await client.post(
          Uri.parse(apiEndpoint2),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthManager.tokenKey}',
          },
          body: jsonEncode(postFields),
        );

        expect(response.statusCode, 201);
        expect(response.body, "Application Successful");
        verify(client.post(
          Uri.parse(apiEndpoint2),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthManager.tokenKey}',
          },
          body: jsonEncode(postFields),
        )).called(1);
      });
      test('Create Vote', () async {
        final client = MockClient();

        // Define the post fields
        final Map<String, dynamic> postFields = {
          "votesData": [
            {
              "voter_id": "loadedMembershipId",
              "election_id": "1",
              "position_id": "2",
              "candidate_id": "3",
              "user_role": "user"
            }
          ]
        };

        when(
          client.post(
            Uri.parse(apiEndpoint3),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AuthManager.tokenKey}',
            },
            body: jsonEncode(postFields),
          ),
        ).thenAnswer((_) async => http.Response("Vote Successful", 201));

        final response = await client.post(
          Uri.parse(apiEndpoint3),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthManager.tokenKey}',
          },
          body: jsonEncode(postFields),
        );

        expect(response.statusCode, 201);
        expect(response.body, "Vote Successful");
        verify(client.post(
          Uri.parse(apiEndpoint3),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthManager.tokenKey}',
          },
          body: jsonEncode(postFields),
        )).called(1);
      });
    },
  );
}
