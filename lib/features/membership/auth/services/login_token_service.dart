import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/features/membership/auth/screen/login_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = ApiConstants.baseUrl;

  final Dio _dio = Dio();
  // Add interceptor for handling 401 errors globally
  AuthService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            handleAuthError(error.requestOptions.extra['context']);
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<String?> loginUser(
      String email, String password, http.Client client) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user-login'),
        body: {'email': email, 'password': password},
      );
      print('API Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 202) {
        final Map<String, dynamic> data = json.decode(response.body);

        final token = data['success']['token'];
        final membershipId = data['success']['membership_id'];
        final orgId = data['success']['user']['organisation_id'];
        final user = data['success']['user'];

        await saveOrgIdLocally(orgId);
        await saveUserData(user);

        // Check if membership_id is not null before saving
        if (membershipId != null) {
          // Save membership_id to shared preferences
          await saveMembershipIdLocally(membershipId);
        } else {
          print('Warning: Received null membership ID');
          // Decide how to handle the case when membership_id is null
        }

        return token;
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
        AlertDialog.adaptive(
          actions: [
            Text(response.body),
          ],
        );
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = jsonEncode(user);
      await prefs.setString('user_data', userDataString);
      print('User data saved successfully: $user');
    } catch (error) {
      print('Error saving user data: $error');
      // Handle error as needed
    }
  }

// Save membership_id to shared preferences
  Future<void> saveMembershipIdLocally(String? membershipId) async {
    if (membershipId != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('membership_id_validates', membershipId);
      print("Saved membership id: $membershipId");
    } else {
      print('Warning: Attempted to save null membership ID');
      // Decide how to handle the case when membership_id is null
    }
  }
  

  // Save membership_id to shared preferences
  Future<void> saveOrgIdLocally(String? grpId) async {
    if (grpId != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('org_id', grpId);
      print("Saved group id: $grpId");
    } else {
      print('No Organization id $grpId');
      // Decide how to handle the case when membership_id is null
      // Save membership_id to shared preferences
    }
  }

  void handleAuthError(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => const LoginAuthScreen(),
      ),
    );
  }
}

class AuthManager {
  static const String tokenKey = 'token';
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  static Future<void> logout(BuildContext context) async {
    try {
      print('Logout method called');

      final token = await getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          await clearUserDataLocally();
          await clearUserImageDataLocally();
          await clearMebrshipIDvalidatesDataLocally();
          await clearMebrshipInvoicesDataLocally();
          await clearcatergoryDataLocally();
          await clearmemebrshipDataLocally();
          await clearuserLocally();
          await clearpropLocally();
          await clearToken();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const LoginAuthScreen(),
          ));
          // Add a debug print to check if the token is cleared
          print('Token cleared successfully');
        } else {
          print('Logout API Error: ${response.statusCode}, ${response.body}');
        }
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}

Future<void> clearUserDataLocally() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const String userDataKey = 'user_data';

    // Clear user data from shared preferences
    await prefs.remove(userDataKey);

    print('User data cleared locally.');
  } catch (e) {
    print('Error clearing user data locally: $e');
  }
}

Future<void> clearUserImageDataLocally() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const String userDataKey = 'user_updated_data';

    // Clear user data from shared preferences
    await prefs.remove(userDataKey);

    print('User data cleared locally.');
  } catch (e) {
    print('Error clearing user data locally: $e');
  }
}

Future<void> clearMebrshipIDvalidatesDataLocally() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const String userDataKey = 'membership_id_validates';

    // Clear user data from shared preferences
    await prefs.remove(userDataKey);

    print('membership_id cleared locally.');
  } catch (e) {
    print('Error clearing usermembership_id data locally: $e');
  }
}

Future<void> clearMebrshipInvoicesDataLocally() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const String userDataKey = 'membership_invoice';

    // Clear user data from shared preferences
    await prefs.remove(userDataKey);

    print('membership cleared locally.');
  } catch (e) {
    print('Error clearing usermembership_id data locally: $e');
  }
}

Future<void> clearcatergoryDataLocally() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const String userDataKey = 'membership_prop_categories';

    // Clear user data from shared preferences
    await prefs.remove(userDataKey);

    print('membership cleared locally.');
  } catch (e) {
    print('Error clearing usermembership_id data locally: $e');
  }
}

Future<void> clearmemebrshipDataLocally() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const String userDataKey = 'membership';

    // Clear user data from shared preferences
    await prefs.remove(userDataKey);

    print('membership cleared locally.');
  } catch (e) {
    print('Error clearing usermembership_id data locally: $e');
  }
}

Future<void> clearpropLocally() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const String userDataKey = 'membership_prop_categories';

    // Clear user data from shared preferences
    await prefs.remove(userDataKey);

    print('membership cleared locally.');
  } catch (e) {
    print('Error clearing usermembership_id data locally: $e');
  }
}

Future<void> clearuserLocally() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const String userDataKey = 'user';

    // Clear user data from shared preferences
    await prefs.remove(userDataKey);

    print('membership cleared locally.');
  } catch (e) {
    print('Error clearing usermembership_id data locally: $e');
  }
}
