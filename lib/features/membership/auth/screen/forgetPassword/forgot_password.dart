import 'package:flutter/material.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/auth/screen/forgetPassword/forget_password_opt.dart';
import 'package:mobile_app/features/membership/auth/services/rest_password_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailforgetpwdcontroller =
      TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> _handleButtonPress() async {
    if (formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        barrierDismissible: false,
      );
      try {
        final email = emailforgetpwdcontroller.text;
        print('Email: $email');

        final otp = await AuthServiceOtp().getOtp(email);
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (otp != null) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ForgetPasswordOTPScreen(),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to get OTP. Please try again.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        print('Error: $e');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: newKBgColor,
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
                        "Forgot\nPassword ?",
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
                        "Don’t worry! It happens. Please enter the email Address we will send \nthe email to reset password.",
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
                      controller: emailforgetpwdcontroller,
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
                    onPressed: _handleButtonPress,
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
                  const SizedBox(
                    height: 5,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.7),
                      minimumSize: const Size(360, 70),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
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
