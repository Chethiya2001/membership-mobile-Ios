import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/features/membership/auth/screen/otp_login/otp_main.dart';
import 'package:mobile_app/features/membership/auth/screen/otp_login/otp_password_email_pwd_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();
  int timerSec = 300;
  bool timerExpired = false;
  late String otp;
  late String email;

  @override
  void initState() {
    super.initState();
    startTimer();
    getEmailAndOtp();
  }

  void getEmailAndOtp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    final storedOtpJson = prefs.getString('otp') ?? '';

    // Extract OTP from JSON string
    final Map<String, dynamic> storedOtpData = jsonDecode(storedOtpJson);
    otp = storedOtpData['success']['OTP'] ?? '';
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer timer) {
      if (timerSec == 0 || !mounted) {
        timerExpired = true;
        timer.cancel();
      } else {
        setState(() {
          timerSec--;
        });
      }
    });
  }

  @override
  void dispose() {
    startTimer();
    getEmailAndOtp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController pincodeController = TextEditingController();
    Color timerColor =
        timerSec <= 60 ? Colors.red : const Color.fromARGB(255, 0, 0, 0);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Login image
                Container(
                  margin: const EdgeInsets.only(
                    top: 50, // Adjust the top margin as needed
                    bottom: 100,
                  ),
                  height: 400, // Adjust the height as needed
                  width: 400, // Adjust the width as needed
                  alignment: AlignmentDirectional.topStart,
                  child: Image.asset('assets/images/restpwd/otprestpwd.jpg'),
                ),
                const SizedBox(height: 0.5),
                // Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (timerExpired)
                            const Text(
                              'Time has expired',
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            )
                          else
                            Text(
                              '${timerSec ~/ 60}: ${timerSec % 60}',
                              style: TextStyle(fontSize: 18, color: timerColor),
                            ),
                          const SizedBox(height: 20),
                          if (!timerExpired)
                            PinCodeTextField(
                              controller: pincodeController,
                              appContext: context,
                              length: 6,
                              onChanged: (value) {
                                // Handle OTP changes
                                print(value);
                              },
                              onCompleted: (value) {
                                // Handle OTP submission
                                print("Completed: $value");

                                if (!timerExpired && value == otp) {
                                  print("Access granted!");
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const OptLoginScreen(),
                                    ),
                                  );
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please try again. your OTP is Invalid'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                  print("Incorrect OTP or timer expired!");
                                  // Debug: print entered OTP and stored OTP
                                  print("Entered OTP: $value");
                                  print("Stored OTP: $otp");
                                }
                              },
                              textStyle: const TextStyle(fontSize: 20.0),
                              keyboardType: TextInputType.number,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                fieldHeight: 50,
                                fieldWidth: 40,
                                activeFillColor: Colors.white,
                              ),
                            ),
                          if (!timerExpired)
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Didn't receive the code? ",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black87,
                                      fontSize: 12,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>const OtpLogin() ,));
                                      },
                                      child: Text(
                                        "Resend",
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
