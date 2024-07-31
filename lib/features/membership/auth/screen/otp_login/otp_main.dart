
import 'package:flutter/material.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/features/membership/auth/screen/otp_login/otp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OtpLogin extends StatefulWidget {
  const OtpLogin({super.key});

  @override
  State<OtpLogin> createState() => _OtpLoginState();
}

class _OtpLoginState extends State<OtpLogin> {
  final TextEditingController emailOtpLogincontroller = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<bool> sendEmail() async {
    const String baseUrl = ApiConstants.baseUrl;
    final email = emailOtpLogincontroller.text;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user-otpLogin-otpSend'),
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

        print('Email: $email');
        print('Response Body: ${response.body}');
        if (mounted) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (ctx) => const OTPScreen()));
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

  // Future<void> _handleButtonPress() async {
  //   if (formKey.currentState!.validate()) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => const Center(
  //         child: CircularProgressIndicator.adaptive(),
  //       ),
  //       barrierDismissible: false,
  //     );
  //     try {
  //       final email = emailforgetpwdcontroller.text;
  //       print('Email: $email');

  //       final otp = await AuthServiceOtp().getOtp(email);
  //       if (mounted) {
  //         Navigator.of(context).pop();
  //       }

  //       if (otp != null) {
  //         if (mounted) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => const ForgetPasswordOTPScreen(),
  //             ),
  //           );
  //         }
  //       } else {
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text('Failed to get OTP. Please try again.'),
  //               duration: Duration(seconds: 3),
  //             ),
  //           );
  //         }
  //       }
  //     } catch (e) {
  //       if (mounted) {
  //         Navigator.of(context).pop();
  //       }
  //       print('Error: $e');

  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('An error occurred. Please try again.'),
  //             duration: Duration(seconds: 3),
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/restPassword.jpg',
                      alignment: Alignment.topCenter),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Padding(padding: EdgeInsets.all(13)),
                      Text(
                        "Welcome",
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Padding(padding: EdgeInsets.all(13)),
                      Text(
                        "Thank you for joining with us",
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // button
              SizedBox(
                child: Container(
                  width: 320,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(9.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      controller: emailOtpLogincontroller,
                      decoration: const InputDecoration(
                        labelText: 'Enter your email',
                        labelStyle: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          fontSize: 20,
                        ),
                        contentPadding: EdgeInsets.all(15),
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
                          return '';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: sendEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.7),
                      minimumSize: const Size(360, 70),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
