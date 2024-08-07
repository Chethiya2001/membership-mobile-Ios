import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/features/membership/auth/screen/login_auth.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/home/models/navigation_list_model_01.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

final List<MenuItemOne> menuItems = [
  MenuItemOne(
      name: 'Edit Profile',
      svgPath: 'assets/svg_list_draver/memebrship.svg',
      route: '/editProfile'),
  MenuItemOne(
      name: 'Membership',
      svgPath: 'assets/svg_list_draver/memebrship.svg',
      route: '/membership'),
  MenuItemOne(
      name: 'Blogs',
      svgPath: 'assets/svg_list_draver/memebrship.svg',
      route: '/blogs'),
  MenuItemOne(
      name: 'Profile',
      svgPath: 'assets/svg_list_draver/memebrsipProfile.svg',
      route: '/membershipProfile'),
  MenuItemOne(
      name: 'Webinars',
      svgPath: 'assets/svg_list_draver/memebrsipProfile.svg',
      route: '/webinar'),
  MenuItemOne(
      name: 'Sections',
      svgPath: 'assets/svg_list_draver/memebrsipProfile.svg',
      route: '/section'),
];

final List<MenuItemOne> menuItemsTow = [
  MenuItemOne(
      name: 'Membership',
      svgPath: 'assets/svg_list_draver/memebrship.svg',
      route: '/membership'),
  MenuItemOne(
      name: 'Packages',
      svgPath: 'assets/svg_list_draver/memebrship.svg',
      route: '/fees'),
  MenuItemOne(
      name: 'Organizations',
      svgPath: 'assets/svg_list_draver/memebrship.svg',
      route: '/orgRegister'),
  MenuItemOne(
      name: 'Delete Account',
      svgPath: 'assets/svg_list_draver/memebrship.svg',
      route: '/profile-delete',
      funtion: (context) => _deleteAccount(context)),
];

Future<bool> _deleteAccount(BuildContext context) async {
  print('Delete Account');
  try {
    final token = await AuthManager.getToken();
    if (token == null) {
      return false;
    }

    const String apiBaseUrl = ApiConstants.baseUrl;

    const String apiEndpoint = '$apiBaseUrl/membership/profile/delete';

    final response = await http.get(Uri.parse(apiEndpoint), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print(data);
      _successMsg(context, "Account Delete Successfully");

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginAuthScreen(),
      ));
    } else {
      print(response.body);
      _showErrorDialog(context, "Something went wrong. Please try again later");
    }

    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<void> _showErrorDialog(BuildContext context, String errorMessage) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
          child: Text(
            ' Registration faild!',
            style: TextStyle(color: Colors.red),
          ),
        ),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<void> _successMsg(BuildContext context, String successMessage) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Text('Success'),
            ],
          ),
        ),
        content: Text(successMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
