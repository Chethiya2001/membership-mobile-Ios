import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/auth/provider/country.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/countact_us/screens/main_contact_us_screen.dart';
import 'package:mobile_app/features/membership/faqs/screens/main_faqs_screen.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/provider/user_data_provider.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/membership/organization_membership/data/union_region_data.dart';
import 'package:mobile_app/features/membership/tearms&condition/screens/main_tearms_and_condition_screen.dart';

class OrganizationRegisterScreen extends ConsumerStatefulWidget {
  const OrganizationRegisterScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OrganizationRegisterScreenState();
}

class _OrganizationRegisterScreenState
    extends ConsumerState<OrganizationRegisterScreen> {
  final orgKey = GlobalKey<FormState>();
  final log = Logger();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController addressLineOneeController =
      TextEditingController();
  final TextEditingController addressLineTwoController =
      TextEditingController();
  final TextEditingController addressLineThreeController =
      TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController alternativeEmailController =
      TextEditingController();
  final TextEditingController faxController = TextEditingController();

  String? selectedCountry = '';
  String? selectedtitle = '';
  String? selectedGender = '';
  String? selectedInstitutionType = '';
  String? selectedAgeRange = '';
  String? selectedjobCatergory = '';
  String? selectedlanguage = '';
  String? selectedqualification = '';
  String? selectednationality = '';
  String? selectedmobileCode = '';
  String? selectedUnionRegion = '';

  Future<bool> updateOrgForm() async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        _showErrorDialog("User not authenticated. Please log in.");
        return false;
      }
      const String apiBaseUrl = ApiConstants.baseUrl;

      const String apiEndpoint =
          '$apiBaseUrl/user-organization-membership-add-form';

      final String firstName = firstNameController.text;
      final String secondName = secondNameController.text;
      final String lastName = lastNameController.text;
      final String email = emailController.text;
      final String mobile = mobileNumberController.text;
      final String jobTitle = jobTitleController.text;
      final String institution = institutionController.text;
      final String department = departmentController.text;
      final String addressline1 = addressLineOneeController.text;
      final String addressline2 = addressLineTwoController.text;
      final String addressline3 = addressLineThreeController.text;
      final String postalcode = postalCodeController.text;
      final String city = cityController.text;
      final String state = stateController.text;
      final String fax = faxController.text;
      final String country = selectedCountry ?? "";
      final String title = selectedtitle ?? "";
      final String gender = selectedGender ?? "";
      final String ageRange = selectedAgeRange ?? "";
      final String jobCategory = selectedjobCatergory ?? "";
      final String language = selectedlanguage ?? "";
      final String qualification = selectedqualification ?? "";
      final String typeInstitution = selectedInstitutionType ?? "";
      final String nationality = selectednationality ?? "";
      final String mobileCode = selectedmobileCode ?? "";
      final String unionRegion = selectedUnionRegion ?? "";

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "first_name": firstName,
          "second_name": secondName,
          "surname": lastName,
          "email": email,
          "mobile": mobile,
          "mobileCode": mobileCode,
          "job_title": jobTitle,
          "institution": institution,
          "department": department,
          "address_line1": addressline1,
          "address_line2": addressline2,
          "address_line3": addressline3,
          "po_code": postalcode,
          "city": city,
          "state": state,
          "fax": fax,
          "country": country,
          "title": title,
          "gender": gender,
          "age_range": ageRange,
          "job_category": jobCategory,
          "language": language,
          "qualification": qualification,
          "type_of_institution": typeInstitution,
          "nationality": nationality,
          "union_region": unionRegion,
        }),
      );
      log.d('Response Status Code: ${response.statusCode}');

      // log.d('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        log.d("Organization Regostration success");
        final resBody = json.decode(response.body);
        print(resBody);
        _successMsg("Updated successfully.");
      } else {
        print(response.body);
        print("Org register Faild");
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
  void initState() {
    super.initState();
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
                  color: newKMainColor,
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
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 60, 0, 2),
                            child: Text(
                              "Stage 01",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
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
                SizedBox(
                  height: screenHeight * 1.55,
                )
              ],
            ),
            Positioned(
              top: 180,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Form(
                key: orgKey,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  width: screenWidth * 0.9,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
                    child: Column(
                      children: [
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
                              final titleAsyncValue = ref.watch(titleProvider);

                              return titleAsyncValue.when(
                                data: (titleList) {
                                  print('title Data: $titleList');
                                  if (titleList.isEmpty) {
                                    selectedtitle = '';
                                  } else {
                                    if (!titleList.any((title) =>
                                        title['id'].toString() ==
                                        selectedtitle)) {
                                      selectedtitle =
                                          titleList.first['id'].toString();
                                    }
                                  }

                                  return DropdownButtonFormField<String>(
                                    value: selectedtitle,
                                    dropdownColor: Colors.white,
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.040,
                                        fontFamily: 'Poppins',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500),
                                    decoration: const InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(left: 20),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        labelText: "Title",
                                        fillColor: Colors.white,
                                        labelStyle: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            color: Colors.black38,
                                            fontWeight: FontWeight.normal)),
                                    items: titleList
                                        .map<DropdownMenuItem<String>>((title) {
                                      return DropdownMenuItem<String>(
                                        value: title['id'].toString(),
                                        child: Text(
                                          title['label_eng'].toString(),
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedtitle = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a title.';
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
                        const SizedBox(
                          height: 10,
                        ),
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
                            const SizedBox(width: 10),
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
                                      controller: secondNameController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            left: 20, top: 5, bottom: 5),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        labelText: 'Second Name',
                                        fillColor: Colors.white,
                                        labelStyle: TextStyle(
                                            fontSize: screenWidth * 0.040,
                                            fontFamily: 'Poppins',
                                            color: Colors.black38,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500),
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      keyboardType: TextInputType.text,
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
                            controller: lastNameController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 20, top: 5, bottom: 5),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: 'Sername',
                              fillColor: Colors.white,
                              labelStyle: TextStyle(
                                  fontSize: screenWidth * 0.040,
                                  fontFamily: 'Poppins',
                                  color: Colors.black38,
                                  fontWeight: FontWeight.normal),
                            ),
                            style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                            textAlignVertical: TextAlignVertical.center,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your surname.';
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
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        labelText: "Gender",
                                        fillColor: Colors.white,
                                        labelStyle: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            color: Colors.black38,
                                            fontWeight: FontWeight.normal),
                                        contentPadding:
                                            EdgeInsets.only(left: 20),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      dropdownColor: Colors.white,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.040,
                                          fontFamily: 'Poppins',
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500),
                                      items: const [
                                        DropdownMenuItem<String>(
                                          value:
                                              'M', // Update value to 'M' for Male
                                          child: Text(
                                            'Male',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value:
                                              'F', // Update value to 'F' for Female
                                          child: Text(
                                            'Female',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGender = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a gender.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
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
                                    child: Consumer(
                                      builder: (context, ref, child) {
                                        final ageRangeAsyncValue =
                                            ref.watch(ageRangeProvider);

                                        return ageRangeAsyncValue.when(
                                          data: (ageRangeList) {
                                            print(
                                                'gender Type Data: $ageRangeList');

                                            if (ageRangeList.isEmpty) {
                                              selectedAgeRange = '';
                                            } else {
                                              selectedAgeRange ??= ageRangeList
                                                  .first['id']
                                                  .toString();

                                              if (!ageRangeList.any((gender) =>
                                                  gender['id'].toString() ==
                                                  selectedAgeRange)) {
                                                selectedAgeRange = ageRangeList
                                                    .first['id']
                                                    .toString();
                                              }
                                            }

                                            return DropdownButtonFormField<
                                                String>(
                                              value: selectedAgeRange,
                                              dropdownColor: Colors.white,
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.040,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500),
                                              decoration: const InputDecoration(
                                                labelText: "Age Range",
                                                fillColor: Colors.white,
                                                labelStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins',
                                                    color: Colors.black38,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                contentPadding:
                                                    EdgeInsets.only(left: 20),
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                              ),
                                              items: ageRangeList.map<
                                                      DropdownMenuItem<String>>(
                                                  (ageRange) {
                                                return DropdownMenuItem<String>(
                                                  value:
                                                      ageRange['id'].toString(),
                                                  child: Text(
                                                    ageRange['age_range']
                                                        .toString(),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedAgeRange = value!;
                                                });
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please select a Age Range.';
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
                                                'Error loading Age range data: $error');
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Union Region",
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
                            dropdownColor: Colors.white,
                            style: TextStyle(
                                fontSize: screenWidth * 0.040,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'AFR', // Update value to 'M' for Male
                                child: Text(
                                  'Africa',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'EUR', // Update value to 'F' for Female
                                child: Text(
                                  'Europe',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'APR', // Update value to 'F' for Female
                                child: Text(
                                  'Asia Pacific',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'LAM', // Update value to 'F' for Female
                                child: Text(
                                  'Latin America',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'MDE', // Update value to 'F' for Female
                                child: Text(
                                  'Middle East',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'NAR', // Update value to 'F' for Female
                                child: Text(
                                  'North America',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'SEA', // Update value to 'F' for Female
                                child: Text(
                                  'South East Asia',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedUnionRegion = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a Union Region.';
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
                          child: TextFormField(
                            controller: jobTitleController,
                            decoration: const InputDecoration(
                              labelText: "Job title",
                              fillColor: Colors.white,
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
                            style: TextStyle(
                                fontSize: screenWidth * 0.040,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                            textAlignVertical: TextAlignVertical.center,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your job title.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
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
                              final jobCatergoryAsyncValue =
                                  ref.watch(jobCatergoryProvider);

                              return jobCatergoryAsyncValue.when(
                                data: (jobCatergoryList) {
                                  print(
                                      'gob catergotry Type Data: $jobCatergoryList');

                                  if (jobCatergoryList.isEmpty) {
                                    selectedjobCatergory = '';
                                  } else {
                                    selectedjobCatergory ??=
                                        jobCatergoryList.first['id'].toString();

                                    if (!jobCatergoryList.any((jobCatergory) =>
                                        jobCatergory['id'].toString() ==
                                        selectedjobCatergory)) {
                                      selectedjobCatergory = jobCatergoryList
                                          .first['id']
                                          .toString();
                                    }
                                  }

                                  return DropdownButtonFormField<String>(
                                    value: selectedjobCatergory,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 20),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      labelText: "Job Catergory",
                                      fillColor: Colors.white,
                                      labelStyle: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          color: Colors.black38,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    dropdownColor: Colors.white,
                                    isExpanded: true,
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.040,
                                        fontFamily: 'Poppins',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500),
                                    items: jobCatergoryList
                                        .map<DropdownMenuItem<String>>(
                                            (jobCatergory) {
                                      return DropdownMenuItem<String>(
                                        value: jobCatergory['id'].toString(),
                                        child: Text(
                                          jobCatergory['label_eng'].toString(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedjobCatergory = value!;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a Job Catergory.';
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
                                      'Error loading job catergory data: $error');
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: TextFormField(
                            controller: institutionController,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 20, top: 5, bottom: 5),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: "Instituiton",
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your Institution.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
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
                              final institutionAsyncValue =
                                  ref.watch(institutionProvider);

                              return institutionAsyncValue.when(
                                data: (institutionList) {
                                  print(
                                      'Institution Type Data: $institutionList');
                                  if (institutionList.isEmpty) {
                                    selectedInstitutionType = '';
                                  } else {
                                    if (!institutionList.any((institution) =>
                                        institution['id'].toString() ==
                                        selectedInstitutionType)) {
                                      selectedInstitutionType = institutionList
                                          .first['id']
                                          .toString();
                                    }
                                  }

                                  return DropdownButtonFormField<String>(
                                    value: selectedInstitutionType,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 20),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      labelText: "Instituiton Type",
                                      fillColor: Colors.white,
                                      labelStyle: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          color: Colors.black38,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    dropdownColor: Colors.white,
                                    isExpanded: true,
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.040,
                                        fontFamily: 'Poppins',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500),
                                    items: institutionList
                                        .map<DropdownMenuItem<String>>(
                                            (institution) {
                                      return DropdownMenuItem<String>(
                                        value: institution['id'].toString(),
                                        child: Text(
                                          institution['label_eng'].toString(),
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedInstitutionType = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a Instituiton Type.';
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
                                      'Error loading Institution data: $error');
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
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: TextFormField(
                            controller: departmentController,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 20, top: 5, bottom: 5),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: "Department",
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your Department.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(left: 20),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: "Language",
                              fillColor: Colors.white,
                              labelStyle: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color: Colors.black38,
                                  fontWeight: FontWeight.normal),
                            ),
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            style: TextStyle(
                                fontSize: screenWidth * 0.040,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'ENG',
                                child: Text(
                                  'English',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'ESP',
                                child: Text(
                                  'Spanish',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'FRE',
                                child: Text(
                                  'French',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedlanguage = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a gender.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
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
                              final qualificationAsyncValue =
                                  ref.watch(qualificationProvider);

                              return qualificationAsyncValue.when(
                                data: (qualificationList) {
                                  print(
                                      'qualification Type Data: $qualificationList');
                                  if (qualificationList.isEmpty) {
                                    selectedqualification = '';
                                  } else {
                                    if (!qualificationList.any(
                                        (qualification) =>
                                            qualification['id'].toString() ==
                                            selectedqualification)) {
                                      selectedqualification = qualificationList
                                          .first['id']
                                          .toString();
                                    }
                                  }

                                  return DropdownButtonFormField<String>(
                                    value: selectedqualification,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 20),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      labelText: "Qualification",
                                      fillColor: Colors.white,
                                      labelStyle: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          color: Colors.black38,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    dropdownColor: Colors.white,
                                    isExpanded: true,
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.040,
                                        fontFamily: 'Poppins',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500),
                                    items: qualificationList
                                        .map<DropdownMenuItem<String>>(
                                            (qualification) {
                                      return DropdownMenuItem<String>(
                                        value: qualification['id'].toString(),
                                        child: Text(
                                          qualification['label_eng'].toString(),
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedqualification = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a qualification.';
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
                                      'Error loading Qualification data: $error');
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: TextFormField(
                            controller: addressLineOneeController,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 20, top: 5, bottom: 5),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: "Address Line 01",
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your Address.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: TextFormField(
                            controller: addressLineTwoController,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 20, top: 5, bottom: 5),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: "Address Line 02",
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
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: TextFormField(
                            controller: addressLineThreeController,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 20, top: 5, bottom: 5),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: "Address Line 03",
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
                          ),
                        ),
                        const SizedBox(height: 10),
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
                                      controller: postalCodeController,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 20, top: 5, bottom: 5),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        labelText: "Postal Code",
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
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter postal code.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
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
                                      controller: cityController,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 20, top: 5, bottom: 5),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        labelText: "City",
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
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter city.';
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
                        const SizedBox(height: 10),
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
                                      controller: stateController,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 20, top: 5, bottom: 5),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        labelText: "State",
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
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter state.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
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
                                    child: Consumer(
                                      builder: (context, ref, child) {
                                        final nationalityAsyncValue =
                                            ref.watch(nationalityProvider);

                                        return nationalityAsyncValue.when(
                                          data: (nationalityList) {
                                            print(
                                                'natinality Type Data: $nationalityList');
                                            if (nationalityList.isEmpty) {
                                              selectednationality = '';
                                            } else {
                                              if (!nationalityList.any(
                                                  (nationality) =>
                                                      nationality['code']
                                                          .toString() ==
                                                      selectednationality)) {
                                                selectednationality =
                                                    nationalityList
                                                        .first['code']
                                                        .toString();
                                              }
                                            }

                                            return DropdownButtonFormField<
                                                String>(
                                              value: selectednationality,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.only(left: 20),
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                labelText: "Nationality",
                                                fillColor: Colors.white,
                                                labelStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins',
                                                    color: Colors.black38,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              dropdownColor: Colors.white,
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.040,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500),
                                              items: nationalityList.map<
                                                      DropdownMenuItem<String>>(
                                                  (nationality) {
                                                return DropdownMenuItem<String>(
                                                  value: nationality['code']
                                                      .toString(),
                                                  child: Text(
                                                    nationality['label_eng']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize:
                                                            screenWidth * 0.03),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectednationality = value;
                                                });
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please select your Nationality.';
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
                                                'Error loading Natinality data: $error');
                                          },
                                        );
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
                          child: Consumer(
                            builder: (context, ref, child) {
                              final countryAsyncValue =
                                  ref.watch(countryProvider);

                              return countryAsyncValue.when(
                                data: (countryList) {
                                  // print('country Data: $countryList');
                                  if (countryList.isEmpty) {
                                    selectedCountry = '';
                                  } else {
                                    if (!countryList.any((title) =>
                                        title['code_ISO'].toString() ==
                                        selectedCountry)) {
                                      selectedCountry = countryList
                                          .first['code_ISO']
                                          .toString();
                                    }
                                  }

                                  return DropdownButtonFormField<String>(
                                    value: selectedCountry,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 20),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      labelText: "Country",
                                      fillColor: Colors.white,
                                      labelStyle: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          color: Colors.black38,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    dropdownColor: Colors.white,
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.040,
                                        fontFamily: 'Poppins',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500),
                                    items: countryList
                                        .map<DropdownMenuItem<String>>((title) {
                                      return DropdownMenuItem<String>(
                                        value: title['code_ISO'].toString(),
                                        child: Text(
                                          title['label_eng'].toString(),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: screenWidth * 0.03),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCountry = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a Country.';
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
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: TextFormField(
                            controller: mobileNumberController,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 20, top: 5, bottom: 5),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: "Mobile Number",
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your mobile number.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: TextFormField(
                            controller: faxController,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 20, top: 5, bottom: 5),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: "FAX",
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
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                minimumSize: const Size(
                                  double.infinity,
                                  50,
                                )),
                            onPressed: () {
                              if (orgKey.currentState!.validate()) {
                                updateOrgForm();
                              } else {
                                _showErrorDialog('Please fill requierd fields');
                              }
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
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