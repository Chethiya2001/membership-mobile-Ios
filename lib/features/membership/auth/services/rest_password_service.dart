import 'package:http/http.dart' as http;
import 'package:mobile_app/constant/base_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServiceOtp {
    static const String baseUrl = ApiConstants.baseUrl;

  Future<String?> getOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user-forgetPassword'),
        headers: <String, String>{
          'Accept': 'application/json',
        },
        body: {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        print("Send OTP");
        //save locally
        final SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('email', email);
        pref.setString('otp', response.body);

        return response.body;
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during OTP generation: $e');
      return null;
    }
  }

  Future<String?> restPassword(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user-resetPassword'),
        headers: <String, String>{
          'Accept': 'application/json',
        },
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        print(response.body);
        print("Rest password success");
        //save locally
        // Save the email locally using SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', email);
        return response.body;
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during password reset: $e');
      return null;
    }
  }
}
