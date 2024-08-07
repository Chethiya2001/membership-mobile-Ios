import 'dart:convert';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/countact_us/screens/main_contact_us_screen.dart';
import 'package:mobile_app/features/membership/faqs/screens/main_faqs_screen.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/list_drawer.dart';

import 'package:mobile_app/features/membership/tearms&condition/screens/main_tearms_and_condition_screen.dart';

class InvoiveScreen extends ConsumerStatefulWidget {
  const InvoiveScreen({super.key, required this.invoiceData});

  final dynamic invoiceData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InvoiveScreenState();
}

class _InvoiveScreenState extends ConsumerState<InvoiveScreen> {
  Future<Map<String, dynamic>> getInvoiceData(int invoiceId) async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        print("User not authenticated. Please log in.");
        return {}; 
      }

      const String apiBaseUrl = ApiConstants.baseUrl;
      final String apiEndpoint = '$apiBaseUrl/incoice-viwe/$invoiceId';

      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      var resBody = response.body;
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $resBody');

      if (response.statusCode == 200) {
        var invoiceData = json.decode(response.body);
        print("Success get data");
        print(invoiceData);
        return invoiceData;
      } else {
        print(
            'Error getting invoice data. Status Code: ${response.statusCode}');
        return {}; // or return an empty Map
      }
    } catch (e) {
      print('Error getting invoice data: $e');
      return {}; // or return an empty Map
    }
  }

  @override
  Widget build(BuildContext context) {
    //List<dynamic> invoices = widget.invoiceData["invoices"];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final data = widget.invoiceData;
    print("data: $data");
    return Scaffold(
      backgroundColor: newKBgColor,
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
          borderRadius: BorderRadius.circular(60),
        ),
        child: const Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                color: newKMainColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Back button

                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 0, 0),
                            child: Text(
                              "Invoices",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Adamina',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 40, left: 18),
                            child: SvgPicture.asset('assets/Group.svg'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.3,
              )
            ],
          ),
          Positioned(
            top: 220,
            left: (screenWidth - screenWidth * 0.9) / 2,
            right: (screenWidth - screenWidth * 0.9) / 2,
            child: Container(
              height: screenHeight * 0.6,
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Color of the shadow
                    offset: const Offset(
                        1, 2), // Offset of the shadow [horizontal, vertical]
                    blurRadius: 4, // Spread radius of the shadow
                    spreadRadius: 2, // Extend the shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 17),
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: ListView.separated(
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 15,
                          );
                        },
                        itemBuilder: (context, index) {
                          final invoices = data["invoices"][index];
                          if (invoices == null) {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text("No invoices found"),
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 3,

                                      blurRadius: 10,
                                      offset: const Offset(
                                          1, 3), // Offset shadow for more depth
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                  ),
                                ),
                                height: 200,
                                width: screenWidth * 0.70,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 16, 8, 0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Membership Category: ${invoices['membership_category']}\n',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54,
                                                      fontFamily: 'Poppins'),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Start of Membership: ${invoices['membership_start']}\n',
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'End of Membership: ${invoices['membership_end']}\n',
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Status: ${invoices['payment_status']}\n',
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                if (invoices[
                                                        'payment_status'] ==
                                                    'PAID') ...[
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 19, left: 8),
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      color: Color.fromARGB(
                                                          255, 29, 255, 146),
                                                    ),
                                                  )
                                                ] else ...[
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 19, left: 8),
                                                    child: Icon(
                                                      Icons
                                                          .radio_button_unchecked,
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                ]
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //color container vertical one
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 3,

                                      blurRadius: 10,
                                      offset: const Offset(
                                          1, 3), // Offset shadow for more depth
                                    ),
                                  ],
                                  color: newKMainColor,
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                height: 200,
                                width: 50,
                                child: Center(
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      'Invoice ID: ${invoices['id']}\n',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        itemCount: data["invoices"].length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
