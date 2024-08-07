import 'package:flutter/material.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/auth/screen/login_auth.dart';
import 'package:mobile_app/features/membership/auth/services/rest_password_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class RestPasswordScreen extends StatefulWidget {
  const RestPasswordScreen({super.key});

  @override
  State<RestPasswordScreen> createState() => _RestPasswordScreenState();
}

final TextEditingController useremailauthController = TextEditingController();
final TextEditingController userepasswordauthController =
    TextEditingController();
final formKey = GlobalKey<FormState>();

class _RestPasswordScreenState extends State<RestPasswordScreen> {
  bool _isObscured = true;

  void _passwordVisible() {
    setState(() {
      _isObscured = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible();
  }

  Future<void> _handleButtonPress() async {
    if (formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
    }
    try {
      final enteredEmail = useremailauthController.text;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('email');

      if (enteredEmail == storedEmail) {
        final restPassword = await AuthServiceOtp()
            .restPassword(enteredEmail, userepasswordauthController.text);
        if (restPassword != null) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const LoginAuthScreen(),
              ),
            );
          }
        } else {
          if (mounted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('password rest faild. Try again.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: newKBgColor,
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  //login img

                  Container(
                    margin: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 40, right: 20),
                    height: 230,
                    width: 200,
                    alignment: AlignmentDirectional.topStart,
                    child: Image.asset('assets/images/restpwd/restpwd.jpg'),
                  ),

                  const SizedBox(height: 0.5),

                  const Column(
                    children: [
                      Text(
                        "Password Rest",
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                      Text(
                        "Rest your password here",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      )
                    ],
                  ),
                  //Login user
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //password field
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color:
                                  Colors.grey[100], // Set gray background color
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: TextFormField(
                              controller: userepasswordauthController,
                              decoration: InputDecoration(
                                labelText: 'New password',
                                labelStyle: const TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                ),
                                contentPadding: const EdgeInsets.only(left: 20),
                                suffixIcon: GestureDetector(
                                  onTap: _passwordVisible,
                                  child: Opacity(
                                      opacity: 0.5,
                                      child: Icon(_isObscured
                                          ? Icons.visibility
                                          : Icons.visibility_off)),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              textAlignVertical: TextAlignVertical.center,
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: _isObscured,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Password is required.';
                                }

                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters long.';
                                }

                                if (!RegExp(r'[A-Z]').hasMatch(value) ||
                                    !RegExp(r'[a-z]').hasMatch(value) ||
                                    !RegExp(r'[0-9]').hasMatch(value) ||
                                    !RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                        .hasMatch(value)) {
                                  return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character.';
                                }

                                return null;
                              },
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: _handleButtonPress,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.9),
                                minimumSize: const Size(300, 55)),
                            child: const Text(
                              'Sing in',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
