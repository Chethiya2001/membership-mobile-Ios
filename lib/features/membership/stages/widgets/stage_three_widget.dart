// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/countact_us/screens/main_contact_us_screen.dart';
import 'package:mobile_app/features/membership/faqs/screens/main_faqs_screen.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:mobile_app/features/membership/stages/widgets/stage_four_widget.dart';
import 'package:mobile_app/features/membership/tearms&condition/screens/main_tearms_and_condition_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';

class MembershipDetailsWidget extends StatefulWidget {
  const MembershipDetailsWidget({
    super.key,
    required this.catgoryData,
  });

  final dynamic catgoryData;

  @override
  State<MembershipDetailsWidget> createState() =>
      _MembershipDetailsWidgetState();
}

class _MembershipDetailsWidgetState extends State<MembershipDetailsWidget> {
  final formKey = GlobalKey<FormState>();
  final log = Logger();
  final aboutController = TextEditingController();
  String? selectedUnionRegion;
  String? selectedScientificSection;
  List<String> selectedOtherSections = [];
  List<String> selectedWorkingGroups = [];
  String loadedMembershipId = '';

  bool validtionForWorkingGroups() {
    return selectedWorkingGroups.length >= 3;
  }

  List<Map<String, dynamic>> scientificSectionData = [];

  Future<bool> submitTrirdForm() async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        print("User not authenticated. Please log in.");
        return false;
      }

      const String apiBaseUrl = ApiConstants.baseUrl;
      const String apiEndpoint = '$apiBaseUrl/user-membership-3rd-form-update';

      final String unionRegion = selectedUnionRegion!;
      final String sceintificSection = selectedScientificSection!;
      final List<String> other = selectedOtherSections;
      final List<String> work = selectedOtherSections;
      final String about = aboutController.text;

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            "membership_id": loadedMembershipId,
            "about_yourself": about,
            "prop_scientific_section": sceintificSection,
            "union_region": unionRegion,
            "prop_list_serves": other,
            "prop_working_groups": work
          },
        ),
      );

      if (response.statusCode == 200) {
        try {
          final dynamic resBody = json.decode(response.body);
          print("${resBody}");
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
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => PaymentWidget(
                      // id: resBody,
                      data: resBody,
                    )));
          }

          // Check if the response is in the expected JSON format
          if (resBody is Map<String, dynamic>) {
            // Save scientific section locally
            if (resBody['success']['membership_invoice'] != null) {
              saveInvoiceLocally(resBody['success']['membership_invoice']);
              saveSelectedDataToSharedPreferences(); // Save
              log.d("Successfully submitting");
              _successMsg("Successfull");
            }
          } else {
            log.e("Unexpected response format: $resBody");
            _showErrorDialog("Unexpected response format");
          }
        } catch (e) {
          log.e('Error decoding response body');
          log.e(e);
          _showErrorDialog("Error decoding response");
        }
      } else {
        log.e("Error Submitting: Status Code ${response.statusCode}");
        _showErrorDialog("Please fill the missing fields");
      }

      return true;
    } catch (e) {
      log.e("Error Submitting $e");
      _showErrorDialog("Fill the missing fields!");
      return false;
    }
  }

// Function to save selected data to shared preferences
  Future<void> saveSelectedDataToSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save selected data to shared preferences
      prefs.setString('selected_union_region', selectedUnionRegion ?? '');
      prefs.setString(
          'selected_scientific_section', selectedScientificSection ?? '');
      prefs.setStringList('selected_other_sections', selectedOtherSections);
      prefs.setStringList('selected_work_sections', selectedWorkingGroups);
      prefs.setString('about_yourself', aboutController.text);

      print('Selected data saved to shared preferences.');
    } catch (e) {
      print('Failed to save selected data. Error: $e');
    }
  }

  Future<void> saveInvoiceLocally(Map<String, dynamic> invoice) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String invoiceKey = 'membership_invoice';

      // Save invoice to shared preferences
      await prefs.setString(invoiceKey, json.encode(invoice));

      log.d('Invoice saved locally: $invoice');
    } catch (e) {
      log.e('Error saving invoice locally: $e');
    }
  }

  List<DropdownMenuItem<String>> getUniqueDropdownItems(
      List<Map<String, dynamic>> data) {
    Set<String> uniqueValues = <String>{};
    List<DropdownMenuItem<String>> dropdownItems = [];

    for (var item in data) {
      if (uniqueValues.add(item['code'])) {
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: item['code'],
            child: Text(item['label_eng']),
          ),
        );
      }
    }

    return dropdownItems;
  }

  Future<List<Map<String, dynamic>>> loadWorkingGroupLocally() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String workingKey = 'working_group';

      final String? workingJson = prefs.getString(workingKey);

      if (workingJson != null) {
        List<Map<String, dynamic>> loadedData =
            List<Map<String, dynamic>>.from(json.decode(workingJson));

        // Ensure uniqueness of 'code' values
        Set<String> uniqueCodes = {};
        loadedData.removeWhere((element) => !uniqueCodes.add(element['code']));

        log.d('Loaded working Section Data: $loadedData');

        return loadedData;
      } else {
        return [];
      }
    } catch (e) {
      log.e('Error loading working data locally: $e');
      return [];
    }
  }

  Future<String> loadMembershipIdLocally() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String membershipKey = 'membership';

      // Get membership ID from shared preferences
      final String? loadedId = prefs.getString(membershipKey);

      return loadedId ?? ''; // Return an empty string if null
    } catch (e) {
      log.e('Error loading membership ID locally: $e');
      return ''; // Return an empty string in case of an error
    }
  }

  Future<List<Map<String, dynamic>>> loadScientificSectionLocally() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String scientificSectionKey = 'scientific_section';

      final String? scientificSectionJson =
          prefs.getString(scientificSectionKey);

      if (scientificSectionJson != null) {
        List<Map<String, dynamic>> loadedData =
            List<Map<String, dynamic>>.from(json.decode(scientificSectionJson));

        // Remove duplicates based on the 'code' field
        Set<String> uniqueCodes = {};
        loadedData.removeWhere((data) {
          return !uniqueCodes.add(data['code']);
        });

        log.d('Loaded Scientific Section Data: $loadedData');

        return loadedData;
      } else {
        return [];
      }
    } catch (e) {
      log.e('Error loading scientificSection data locally: $e');
      return [];
    }
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              ' Registration failed!',
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

  void clearAndNavigateBack() {
    // widget.onBackPressed();
  }

  @override
  void initState() {
    super.initState();

    loadMembershipIdLocally().then((loadedId) {
      setState(() {
        loadedMembershipId = loadedId;
      });
      log.d('Loaded Membership ID in initState: $loadedId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final data = widget.catgoryData['success'];
    print('Stage 03 data : $data');

    final unionRegionData = data['union_region'];
    print('union region data: $unionRegionData');

    // print('SC data: $scientificSectionData');

    final otherData = data['other_section'];
    // print('other  data: $otherData');

    final workingData = data['working_group'];
    // print('working  data: $workingData');
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
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(18, 16, 8, 8),
                              child: Text(
                                "Stage 03",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Adamina',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 1.1,
                )
              ],
            ),

            Positioned(
              top: screenHeight * 0.18,
              left: (screenWidth - screenWidth * 0.92) / 2,
              right: (screenWidth - screenWidth * 0.92) / 2,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      //Bio
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.5), // Color of the shadow
                                offset: const Offset(1,
                                    2), // Offset of the shadow [horizontal, vertical]
                                blurRadius: 4, // Spread radius of the shadow
                                spreadRadius: 2, // Extend the shadow
                              ),
                            ]),
                        height: 80,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9.0),
                          ),
                          child: TextFormField(
                            controller: aboutController,
                            maxLength: null,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Bio',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              contentPadding: EdgeInsets.only(left: 20),
                              suffixIcon: Opacity(
                                opacity: 0.5,
                                child: Icon(Icons.people_alt_outlined),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.text,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: AutofillHints.sublocality),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter about you.';
                              }

                              return null;
                            },
                          ),
                        ),
                      ),
                      //Union Region
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.5), // Color of the shadow
                                offset: const Offset(1,
                                    2), // Offset of the shadow [horizontal, vertical]
                                blurRadius: 4, // Spread radius of the shadow
                                spreadRadius: 2, // Extend the shadow
                              ),
                            ]),
                        height: 70,
                        child: Container(
                          height: 50,
                          width: double.maxFinite,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9.0),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: DropdownButtonFormField(
                              value: selectedUnionRegion,
                              decoration: const InputDecoration(
                                labelText: 'REGION',
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                contentPadding: EdgeInsets.only(left: 15),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AutofillHints.sublocality),
                              dropdownColor: Colors.white,
                              items: unionRegionData
                                  .map<DropdownMenuItem<String>>((data) {
                                return DropdownMenuItem<String>(
                                  value: data['code'],
                                  child: Text(data['label_eng'],
                                      style:
                                          const TextStyle(color: Colors.black)),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    selectedUnionRegion = value;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a region';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      //sceintic section
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              offset: const Offset(1, 2),
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                          color: Colors.white,
                        ),
                        height: 70,
                        child: Container(
                          height: 50,
                          width: double.maxFinite,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9.0),
                          ),
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: loadScientificSectionLocally(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator
                                    .adaptive();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<Map<String, dynamic>>
                                    scientificSectionData = snapshot.data ?? [];
                                return SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: DropdownButtonFormField(
                                    value: selectedScientificSection,
                                    decoration: const InputDecoration(
                                      labelText: 'SCIENTIFIC SECTION',
                                      labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                      contentPadding: EdgeInsets.only(left: 15),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AutofillHints.sublocality),
                                    dropdownColor: Colors.white,
                                    items: getUniqueDropdownItems(
                                        scientificSectionData),
                                    onChanged: (String? value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedScientificSection = value;
                                        });
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a valid scientific section';
                                      }
                                      if (!scientificSectionData.any(
                                          (item) => item['code'] == value)) {
                                        return 'Invalid scientific section';
                                      }
                                      return null;
                                    },
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: screenHeight * 0.57,
              left: (screenWidth - screenWidth * 0.92) / 2,
              right: (screenWidth - screenWidth * 0.92) / 2,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        'Other Groups',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey
                              .withOpacity(0.5), // Color of the shadow
                          offset: const Offset(1,
                              2), // Offset of the shadow [horizontal, vertical]
                          blurRadius: 4, // Spread radius of the shadow
                          spreadRadius: 2, // Extend the shadow
                        ),
                      ],
                    ),
                    height: 320,
                    child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: otherData.length,
                          itemBuilder: (context, index) {
                            return CheckboxListTile(
                              activeColor: secondbg,
                              checkColor: Colors.white,
                              title: Text(
                                otherData[index]['label_eng'],
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                              value: selectedOtherSections
                                  .contains(otherData[index]['code']),
                              onChanged: (value) {
                                setState(() {
                                  if (value != null && value) {
                                    selectedOtherSections
                                        .add(otherData[index]['code']);
                                  } else {
                                    selectedOtherSections
                                        .remove(otherData[index]['code']);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Working Groups
            Positioned(
              top: screenHeight * 1.0,
              left: (screenWidth - screenWidth * 0.92) / 2,
              right: (screenWidth - screenWidth * 0.92) / 2,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        'Working Groups',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withOpacity(0.5), // Color of the shadow
                            offset: const Offset(1,
                                2), // Offset of the shadow [horizontal, vertical]
                            blurRadius: 4, // Spread radius of the shadow
                            spreadRadius: 2, // Extend the shadow
                          ),
                        ]),
                    height: 320,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '(Please Select 3 Working Groups.)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 250,
                            child: Container(
                              width: double.maxFinite,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9.0),
                              ),
                              child: SizedBox(
                                height: 800,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListView.builder(
                                    itemCount: workingData.length,
                                    itemBuilder: (context, index) {
                                      return CheckboxListTile(
                                        activeColor: secondbg,
                                        checkColor: Colors.white,
                                        title: Text(
                                          workingData[index]['label_eng'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        value: selectedWorkingGroups.contains(
                                            workingData[index]['code']),
                                        onChanged: (value) {
                                          setState(
                                            () {
                                              if (value != null && value) {
                                                selectedWorkingGroups.add(
                                                    workingData[index]['code']);
                                              } else {
                                                selectedWorkingGroups.remove(
                                                    workingData[index]['code']);
                                              }
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
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
            Positioned(
              bottom: 40,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: submitTrirdForm,
                  child: const Text(
                    "Next",
                    style: TextStyle(color: Colors.white),
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
