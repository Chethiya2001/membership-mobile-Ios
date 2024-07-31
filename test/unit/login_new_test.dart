
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';


import 'login_new_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group(
    'User Login',
    () {
      test(
        'Login successfully',
        () async {
          final client = MockClient();

          when(
            client.post(
              Uri.parse(
                  'https://membership-api.codefusion.com.lk/api/v1/user-login'),
              body: {"email": "mishani@gmail.com", "password": "Aaa12345!."},
              headers: <String, String>{
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          ).thenAnswer((_) async => http.Response(AuthManager.tokenKey, 200));
        },
      );
      test(
        'Register successfully',
        () async {
          final client = MockClient();

          when(
            client.post(
              Uri.parse(
                  'https://membership-api.codefusion.com.lk/api/v1/user-register'),
              body: {
                "first_name": "John1",
                "last_name": "Doe",
                "email": "johndoe1@example.com",
                "password": "password",
                "mobile": "1234567890",
                "country": "US",
                "privacy_policy_accept": "true"
              },
              headers: <String, String>{
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          ).thenAnswer(
              (_) async => http.Response("Resgisted Successfull", 201));
        },
      );
    },
  );
}
