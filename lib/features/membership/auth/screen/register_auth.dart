import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/auth/model/auth_model.dart';
import 'package:mobile_app/features/membership/auth/provider/country.dart';
import 'package:mobile_app/features/membership/auth/screen/login_auth.dart';
import 'package:mobile_app/features/membership/tearms&condition/screens/main_tearms_and_condition_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterAuthScreen extends ConsumerStatefulWidget {
  const RegisterAuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegisterAuthScreenState();
}

class _RegisterAuthScreenState extends ConsumerState<RegisterAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  String? selectedCountry;
  bool _ispwdVisible = false;
  String checkboxValue = '0';

  Future<bool> registerUser() async {
    const String apiBaseUrl = ApiConstants.baseUrl;
    const String apiEndpoint = '$apiBaseUrl/user-register';

    final String firstName = firstNameController.text;
    final String lastName = secondNameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String mobile = mobileNumberController.text;
    final String country = selectedCountry ?? "";

    try {
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: <String, String>{
          'Accept': 'application/json',
        },
        body: {
          "first_name": firstName,
          "second_name": lastName,
          "email": email,
          "password": password,
          "mobile": mobile,
          "country": country,
          "privacy_policy_accept": checkboxValue
        },
      );

      var resBody = json.decode(response.body);

      print(resBody);

      if (response.statusCode == 201) {
        print('Registration successful!');
        User newUser = User(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          mobile: mobile,
          country: country,
        );

        // Save user data locally
        await saveUserDataLocally(newUser);
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            barrierDismissible: false,
          );
        }
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const LoginAuthScreen()));
        }
        _successMsg("Register successfully.");

        return true;
      } else {
        _showErrorMsg(
          response.body,
        );
        print('Registration failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      _showErrorDialog(
        " $e",
      );
      print('Error during registration: $e');
      return false;
    }
  }

  void _showErrorMsg(String responseBody) {
    try {
      // Parse the response body
      final Map<String, dynamic> errorData = jsonDecode(responseBody);

      // Check if the error field exists
      if (errorData.containsKey('error')) {
        final Map<String, dynamic> error = errorData['error'];

        // Check if email error exists
        if (error.containsKey('email')) {
          // Show the email error message
          final List<dynamic> emailErrors = error['email'];
          final String emailErrorMessage = emailErrors.isNotEmpty
              ? emailErrors.first.toString()
              : 'Unknown email error';
          _showEmailMobileError(emailErrorMessage, isError: true);
          print('Email Error: $emailErrorMessage');
        }

        // Check if mobile error exists
        if (error.containsKey('mobile')) {
          // Show the mobile error message
          final List<dynamic> mobileErrors = error['mobile'];
          final String mobileErrorMessage = mobileErrors.isNotEmpty
              ? mobileErrors.first.toString()
              : 'Unknown mobile error';
          _showEmailMobileError(mobileErrorMessage, isError: true);
          print('Mobile Error: $mobileErrorMessage');
        }
      } else {
        // Handle cases where the error field doesn't exist
        _showEmailMobileError('Unknown error occurred', isError: true);
      }
    } catch (e) {
      // Handle errors during parsing or unexpected errors
      _showEmailMobileError('Error parsing response: $e', isError: true);
      print('Error during error handling: $e');
    }
  }

  void _showEmailMobileError(String errorMessage, {bool isError = false}) {
    if (isError) {
      // Show error message
      _showErrorDialog(errorMessage);
    } else {
      // Handle non-error messages
      print(errorMessage);
    }
  }

  void _showError(String responseBody) {
    try {
      // Parse the response body JSON
      final Map<String, dynamic> responseData = json.decode(responseBody);

      // Extract the error message
      final errorMessage = responseData['error']['email'][0];

      // Show the error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
                child: Text(
              'Error',
              style: TextStyle(color: Colors.red),
            )),
            content: Text(errorMessage),
            actions: <Widget>[
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
    } catch (e) {
      print('Error parsing response body: $e');
      // Handle any errors during parsing or displaying the error message
      // Show a generic error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred. Please try again later.'),
            actions: <Widget>[
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
  }

  Future<void> saveUserDataLocally(User user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String userDataKey = 'user_data';

      // Convert user object to Map
      final Map<String, dynamic> userMap = user.toMap();

      // Convert Map to JSON string
      final String userJson = json.encode(userMap);

      // Save JSON string to shared preferences
      await prefs.setString(userDataKey, userJson);

      print('User data saved locally: $userJson');
    } catch (e) {
      print('Error saving user data locally: $e');
    }
  }

  Future<void> _showErrorDialog(String errorMessage) async {
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

  Future<void> _successMsg(String successMessage) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: maingbg,
            width: double.infinity,
            height: double.infinity,
          ),

          //Register UI
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [homeclr, maingbg],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.5, 0.9],
                  tileMode: TileMode.decal,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Get Started",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontFamily: AutofillHints.addressCity,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            "by creating free account",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          )
                        ],
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: firstNameController,
                                  decoration: InputDecoration(
                                    label:
                                        const Center(child: Text("First Name")),
                                    labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    contentPadding:
                                        const EdgeInsets.only(left: 60),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: const Opacity(
                                          opacity: 0.5,
                                          child:
                                              Icon(Icons.emoji_people_outlined),
                                        ),
                                      ),
                                    ),
                                    fillColor: Colors.black,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                  textCapitalization: TextCapitalization.none,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      fontSize: 16),
                                  textAlign: TextAlign.justify,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a valid first name.';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),

                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: secondNameController,
                                  decoration: InputDecoration(
                                    label: const Center(child: Text("Surname")),
                                    labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    contentPadding:
                                        const EdgeInsets.only(left: 60),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: const Opacity(
                                          opacity: 0.5,
                                          child:
                                              Icon(Icons.people_alt_outlined),
                                        ),
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                  textCapitalization: TextCapitalization.none,
                                  keyboardType: TextInputType.text,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      fontSize: 16),
                                  textAlign: TextAlign.justify,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a valid surname.';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              //login ui

                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: emailController,
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
                                        width: 50,
                                        height: 50,
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
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      fontSize: 16),
                                  textAlign: TextAlign.justify,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        !value.contains('@')) {
                                      return 'Please enter a valid email address.';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              //password field
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: !_ispwdVisible,
                                  decoration: InputDecoration(
                                    label:
                                        const Center(child: Text("Password")),
                                    labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    contentPadding:
                                        const EdgeInsets.only(left: 60),
                                    prefixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _ispwdVisible = !_ispwdVisible;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.1),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: Container(
                                            width: 50,
                                            height: 50,
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
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      fontSize: 16),
                                  textAlign: TextAlign.justify,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password.';
                                    }

                                    if (!RegExp(
                                            r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\-]).{8,}$')
                                        .hasMatch(value)) {
                                      return "Password: 8+ chars, mix of letters, numbers & symbols.";
                                    }

                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: mobileNumberController,
                                  decoration: InputDecoration(
                                    label: const Center(
                                        child: Text("Mobile Number")),
                                    labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    contentPadding:
                                        const EdgeInsets.only(left: 60),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: const Opacity(
                                          opacity: 0.5,
                                          child:
                                              Icon(Icons.mobile_screen_share),
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
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      fontSize: 16),
                                  textAlign: TextAlign.justify,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a valid mobile number.';
                                    }

                                    // Remove any non-numeric characters from the input
                                    String numericValue =
                                        value.replaceAll(RegExp(r'[^0-9]'), '');

                                    if (numericValue.length != 10) {
                                      return 'Mobile number must be exactly 10 digits.';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              // Dropdown selection field
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Icon(Icons.flag_circle_sharp,
                                          color: Colors.black.withOpacity(0.3)),
                                    ),
                                    Expanded(
                                      child: Consumer(
                                        builder: (context, ref, child) {
                                          final countriesAsyncValue =
                                              ref.watch(countryProvider);

                                          return countriesAsyncValue.when(
                                            data: (countryList) {
                                              print(
                                                  'Country Data: $countryList');

                                              return DropdownButtonFormField<
                                                  String>(
                                                value: selectedCountry,
                                                alignment: Alignment.center,
                                                decoration:
                                                    const InputDecoration(
                                                  label: Center(
                                                      child: Text("Country")),
                                                  labelStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                  iconColor: maingbg,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          -40, 0, 10, 0),
                                                  border: InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                ),
                                                dropdownColor: Colors.black,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                items: countryList.map<
                                                    DropdownMenuItem<
                                                        String>>((country) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: country['code_ISO']
                                                        .toString(),
                                                    child: Center(
                                                      child: Text(
                                                        country['label_eng']
                                                            .toString(),style: TextStyle(color: Colors.white),
                                                            
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedCountry = value;
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please select a country.';
                                                  }
                                                  return null;
                                                },
                                              );
                                            },
                                            loading: () {
                                              return const CircularProgressIndicator();
                                            },
                                            error: (error, stack) {
                                              return Text(
                                                  'Error loading country data: $error');
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: checkboxValue == '1',
                                        onChanged: (bool? value) {
                                          setState(() {
                                            checkboxValue = value! ? '1' : '0';
                                          });
                                        },
                                      ),
                                      const Text(
                                        'I agree to the privacy policy',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white60),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      const TearmsAndConditionScreen()));
                                          print('privecy policy clicked');
                                        },
                                        child: const Text(
                                          'Read more..',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  )),

                              const SizedBox(
                                height: 10,
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    if (checkboxValue == '1') {
                                      registerUser();
                                    } else {
                                      _showErrorDialog(
                                          'Please accept the privacy policy to register.');
                                    }
                                  } else {
                                    _showErrorDialog(
                                        'Please fill reqiuerd fields');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 5,
                                    minimumSize:
                                        const Size(double.infinity, 60)),
                                child: const Text(
                                  'Sign up',
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
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Already have an account',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
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
        ],
      ),
    );
  }
}
