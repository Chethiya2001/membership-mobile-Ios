import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/auth/screen/facebok_login.dart';
import 'package:mobile_app/features/membership/auth/screen/forgetPassword/forgot_password.dart';
import 'package:mobile_app/features/membership/auth/screen/otp_login/otp_main.dart';
import 'package:mobile_app/features/membership/auth/screen/register_auth.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/home/screen/home_screen.dart';
import 'package:http/http.dart' as http;

class LoginAuthScreen extends StatefulWidget {
  const LoginAuthScreen({super.key});

  @override
  State<LoginAuthScreen> createState() => _LoginAuthScreenState();
}

class _LoginAuthScreenState extends State<LoginAuthScreen> {
  final formKeyAuth = GlobalKey<FormState>();
  final TextEditingController useremailauthController = TextEditingController();
  final TextEditingController userepasswordauthController =
      TextEditingController();
  bool _ispwdVisible = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      // Navigate to home screen upon successful sign-in
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              signOutCallback: handleSignOut,
            ),
          ),
        );
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> handleSignOut() async {
    try {
      await _googleSignIn.signOut();
      if (mounted) {
        Navigator.of(context).pop();
        print('google logOut');
      } // Sign out from Google
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIsLoging();
  }

  void _checkIsLoging() async {
    final token = await AuthManager.getToken();
    if (token != null) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => HomeScreen(
              signOutCallback: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: newKMainColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            scrollDirection: Axis.vertical,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  //login img

                  const Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Welcome back",
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontFamily: AutofillHints.addressCity,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "Sign in to access your account",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  //Login user
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKeyAuth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                  0.3), // Set gray background color
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextFormField(
                                controller: useremailauthController,
                                decoration: InputDecoration(
                                  label: const Center(
                                      child: Text("Email Address")),
                                  labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  contentPadding:
                                      const EdgeInsets.only(left: 60),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: const Opacity(
                                        opacity: 0.5,
                                        child: Icon(Icons.email_outlined),
                                      ),
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                textAlignVertical: TextAlignVertical.center,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: true,
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontSize: 16),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email address.';
                                  }
                                  return null;
                                }),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          //password field
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                  0.3), // Set gray background color
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextFormField(
                              controller: userepasswordauthController,
                              obscureText: !_ispwdVisible,
                              decoration: InputDecoration(
                                label: const Center(child: Text("Password")),
                                labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                                contentPadding: const EdgeInsets.only(left: 60),
                                prefixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _ispwdVisible = !_ispwdVisible;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            _ispwdVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors
                                                .grey, // Change the color of the visibility icon if needed
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              textAlignVertical: TextAlignVertical.center,
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.visiblePassword,
                              autocorrect: true,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  fontSize: 16),
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
                                  return "Password: 8+ chars, mix of letters, numbers & symbols.";
                                }

                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          // Remember Me Checkbox

                          const Column(
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'or\n sign in with,',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: handleSignIn,
                                    child: Image.asset(
                                      'assets/images/icons8-google-48.png',
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                  //fb login
                                  GestureDetector(
                                    onTap: () {
                                      if (mounted) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    const FacebookLogin()));
                                      }

                                      print('clicked face book');
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/logo/facebook_logo.svg',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (ctx) =>
                                                  const OtpLogin()));
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/logo/otp_login.svg',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final token = await AuthService().loginUser(
                                useremailauthController.text,
                                userepasswordauthController.text,
                                http.Client(),
                              );

                              try {
                                if (token != null) {
                                  print('Login Success. Token: $token');

                                  await AuthManager.saveToken(token);

                                  if (mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const Center(
                                          child: CircularProgressIndicator
                                              .adaptive(),
                                        );
                                      },
                                      barrierDismissible: false,
                                    );

                                    await Future.delayed(
                                        const Duration(seconds: 2));

                                    if (mounted) {
                                      Navigator.of(context).pop();
                                    }

                                    if (mounted) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) => HomeScreen(
                                            signOutCallback: () {},
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  print('Login failed');
                                  if (mounted) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Login failed.  your email and password not match.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                print('Error during login: $e');
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'An error occurred during login. Please try again later. $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                minimumSize: const Size(double.infinity, 60)),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                  color: maingbg,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AutofillHints.impp),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(10),
                              ),
                              const Text(
                                "Join with us",
                                style: TextStyle(color: Colors.white54),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterAuthScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Register now',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          // Forgot Password TextButton
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
