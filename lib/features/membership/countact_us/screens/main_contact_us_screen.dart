import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/faqs/screens/main_faqs_screen.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/provider/user_data_provider.dart';
import 'package:mobile_app/features/membership/tearms&condition/screens/main_tearms_and_condition_screen.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final contactUsKey = GlobalKey<FormState>();
  final log = Logger();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String? selectedInquaryType = '';
  String? selectedDepartment = '';

  Future<bool> contactUsForm() async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        _showErrorDialog("User not authenticated. Please log in.");
        return false;
      }
      const String apiBaseUrl = ApiConstants.baseUrl;

      const String apiEndpoint = '$apiBaseUrl/user-contact-us';

      final String firstName = firstNameController.text;

      final String email = emailController.text;
      final String department = selectedDepartment ?? "";
      final String inquary = selectedInquaryType ?? "";
      final String message = messageController.text;

      print(inquary);

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": firstName,
          "email": email,
          "department": department,
          "inquiry_type": inquary,
          "message": message,
        }),
      );
      log.d('Response Status Code: ${response.statusCode}');

      log.d('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        log.d("Contact Us success");
        _successMsg("Send email");
      } else {
        print("Faild to send contact us");
      }

      return true;
    } catch (e) {
      log.e("Fiaild $e");
      return false;
    }
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '  Faild sending email!',
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
                  color: Color.fromARGB(255, 40, 63, 166),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ListDrawer(),
                  ));
                }),
            IconButton(
                icon: const Icon(Icons.phone, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ContactUsScreen(),
                  ));
                }),
            IconButton(
                icon: const Icon(Icons.format_quote, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const FaqsScreen(),
                  ));
                }),
            IconButton(
                icon: const Icon(Icons.rule_sharp, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const TearmsAndConditionScreen(),
                  ));
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        hoverColor: Colors.blue,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        splashColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(60), // You can adjust the radius as needed
        ),
        child: const Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  color: Colors.blue,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 26, 8, 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ListDrawer(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 40, 0, 2),
                            child: Text(
                              "Contact Us",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Adamina',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 40, left: 18),
                            child: SvgPicture.asset('assets/contactUs-Svg.svg'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.52,
                )
              ],
            ),
            Positioned(
              top: 180,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Form(
                key: contactUsKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.grey.withOpacity(0.5), // Color of the shadow
                        offset: const Offset(1,
                            2), // Offset of the shadow [horizontal, vertical]
                        blurRadius: 4, // Spread radius of the shadow
                        spreadRadius: 2, // Extend the shadow
                      ),
                    ],
                  ),
                  width: screenWidth * 0.9,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                          color: Colors.black.withOpacity(0.1),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    height: 60,
                                    child: TextFormField(
                                      controller: firstNameController,
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.only(
                                              left: 20, top: 5, bottom: 5),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          labelText: 'First Name',
                                          fillColor: Colors.white,
                                          labelStyle: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Poppins',
                                              color: Colors.black38,
                                              fontWeight: FontWeight.normal)),
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.040,
                                          fontFamily: 'Poppins',
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500),
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your first name.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 20, top: 5, bottom: 5),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: 'Email',
                              fillColor: Colors.white,
                              labelStyle: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color: Colors.black38,
                                  fontWeight: FontWeight.normal),
                            ),
                            style: TextStyle(
                                fontSize: screenWidth * 0.040,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.emailAddress,
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
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final departmentAsyncValue =
                                  ref.watch(departmentProvider);

                              return departmentAsyncValue.when(
                                data: (departmentList) {
                                  if (departmentList.isEmpty) {
                                    selectedDepartment = '';
                                  } else {
                                    selectedDepartment ??=
                                        departmentList.first['id'].toString();

                                    if (!departmentList.any((jobCatergory) =>
                                        jobCatergory['id'].toString() ==
                                        selectedDepartment)) {
                                      selectedDepartment =
                                          departmentList.first['id'].toString();
                                    }
                                  }

                                  return DropdownButtonFormField<String>(
                                    value: selectedDepartment,
                                    decoration: const InputDecoration(
                                      labelText: 'Department',
                                      fillColor: Colors.white,
                                      labelStyle: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          color: Colors.black38,
                                          fontWeight: FontWeight.normal),
                                      contentPadding: EdgeInsets.only(left: 20),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.040,
                                        fontFamily: 'Poppins',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500),
                                    items: departmentList
                                        .map<DropdownMenuItem<String>>(
                                            (department) {
                                      return DropdownMenuItem<String>(
                                        value: department['id'].toString(),
                                        child: Text(
                                          department['department_name']
                                              .toString(),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDepartment = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a Department.';
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
                                      'Error loading department data: $error');
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the value as needed
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Text('Select Inquary Type',
                                        style: TextStyle(
                                            color: Color.fromRGBO(0, 0, 0, 0.5),
                                            fontSize: 15)),
                                  ],
                                ),
                              ),
                              CheckboxListTile(
                                title: const Text('Registration',
                                    style: TextStyle(color: Colors.black)),
                                value: selectedInquaryType == 'Registration',
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedInquaryType =
                                        newValue! ? 'Registration' : '';
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('General',
                                    style: TextStyle(color: Colors.black)),
                                value: selectedInquaryType == 'General',
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedInquaryType =
                                        newValue! ? 'General' : '';
                                  });
                                },
                              ),
                              CheckboxListTile(
                                selectedTileColor: Colors.white,
                                title: const Text(
                                  'Other',
                                  style: TextStyle(color: Colors.black),
                                ),
                                value: selectedInquaryType == 'Other',
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedInquaryType =
                                        newValue! ? 'Other' : '';
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: TextFormField(
                            maxLines: 5,
                            maxLength: null,
                            controller: messageController,
                            decoration: const InputDecoration(
                              labelText: 'Message',
                              labelStyle: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color: Colors.black38,
                                  fontWeight: FontWeight.normal),
                              contentPadding:
                                  EdgeInsets.only(left: 20, top: 5, bottom: 5),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            minLines: 5,
                            style: TextStyle(
                                fontSize: screenWidth * 0.040,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                            textAlignVertical: TextAlignVertical.center,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter message.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                            ),
                            onPressed: contactUsForm,
                            child: const Text(
                              "Message",
                              style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}
