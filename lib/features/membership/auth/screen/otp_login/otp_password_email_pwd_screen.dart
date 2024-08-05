import 'package:flutter/material.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/membership/home/screen/home_screen.dart';

class OptLoginScreen extends StatefulWidget {
  const OptLoginScreen({super.key});

  @override
  State<OptLoginScreen> createState() => _OptLoginScreenState();
}

final TextEditingController useremailauthController = TextEditingController();

final formKey = GlobalKey<FormState>();

class _OptLoginScreenState extends State<OptLoginScreen> {
  bool isObscured = true;

  void _passwordVisible() {
    setState(() {
      isObscured = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible();
  }

  Future<bool> loginEmail() async {
    const String baseUrl = ApiConstants.baseUrl;
    final email = useremailauthController.text;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user-otpLogin-otpCheck'),
        headers: <String, String>{
          'Accept': 'application/json',
        },
        body: {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        print("success login");
        print(response.body);
        if (mounted) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => HomeScreen(
                    signOutCallback: () {},
                  )));
        }
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
      }
      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        "Login",
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                      Text(
                        "Enter your email",
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
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color:
                                  Colors.grey[100], // Set gray background color
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: TextFormField(
                                controller: useremailauthController,
                                decoration: const InputDecoration(
                                  labelText: 'Enter your email',
                                  labelStyle: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 0.5),
                                  ),
                                  contentPadding: EdgeInsets.only(left: 20),
                                  suffixIcon: Opacity(
                                    opacity: 0.5,
                                    child: Icon(Icons.email_outlined),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                textAlignVertical: TextAlignVertical.center,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.emailAddress,
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
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: loginEmail,
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
