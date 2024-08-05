// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_app/constant/base_img_api.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/screens/user_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.userData,
  });

  final dynamic userData;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

//verification color
class _ProfileScreenState extends State<ProfileScreen> {
  late int amount = 0;
  late String productDescription = '';
  late String lastUpdate = '';
  late String createdAt = '';
  String? selectedUnionRegion;
  String? selectedScientificSection;
  List? selectedOtherSections;
  List? selectedWorkSections;
  static String? globalImageUrl;
  String? userName;
  String? userEmail;

  //loads
  // Function to load selected data from shared preferences
  Future<void> loadSelectedDataFromSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Retrieve the saved data from shared preferences
      String? unionRegion = prefs.getString('selected_union_region');
      String? scientificSection =
          prefs.getString('selected_scientific_section');
      List<String>? otherSections =
          prefs.getStringList('selected_other_sections');
      List<String>? workSections =
          prefs.getStringList('selected_work_sections');

      // Set the loaded data to corresponding variables
      selectedUnionRegion = unionRegion;
      selectedScientificSection = scientificSection;
      selectedOtherSections = otherSections ?? [];
      selectedWorkSections = workSections ?? [];

      print('Selected data loaded from shared preferences.');
    } catch (e) {
      print('Failed to load selected data. Error: $e');
    }
  }

  Future<void> loadAndFilterData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Retrieve the saved data as a JSON String
      String? jsonData = prefs.getString('membership_prop_categories');

      if (jsonData != null) {
        // Convert JSON String back to a Map
        Map<String, dynamic> savedData = jsonDecode(jsonData);

        // Print the entire savedData map for debugging
        print('Entire Saved Data:');
        print(savedData);

        // Iterate over keys in savedData
        savedData.forEach((key, value) {
          // Check if the value associated with the key is a List
          if (value is List) {
            // Check if the list is not empty
            if (value.isNotEmpty) {
              Map<String, dynamic> firstItem = value[0];

              // Filter specific fields
              amount = firstItem['amount'] ?? 0;
              productDescription = firstItem['product_description'] ?? '';
              lastUpdate = firstItem['last_update'] ?? '';
              createdAt = firstItem['created_at'] ?? '';

              // Print or use the filtered data
              print('Filtered Data for Key $key:');
              print('Amount: $amount');
              print('Product Description: $productDescription');
              print('Last Update: $lastUpdate');
              print('Created At: $createdAt');
            } else {
              print('The list under key $key is empty.');
            }
          } else {
            print('The value associated with key $key is not a List.');
          }
        });
      } else {
        print('No saved data found.');
      }
    } catch (e) {
      print('Error while loading and filtering data: $e');
    }
  }

  //load dates

  Future<void> loadMembershipExpiryBar() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Get the JSON String from SharedPreferences
      String membershipExpiryBarJson =
          prefs.getString('membership_expiry_bar') ?? '{}';

      // Parse the JSON String to a Map
      Map<String, dynamic> membershipExpiryBar =
          jsonDecode(membershipExpiryBarJson);

      // Extract values from the map and set them to variables
      String startDateString = membershipExpiryBar['start_date'] ?? '';
      String endDateString = membershipExpiryBar['end_date'] ?? '';

      // Handle the conversion from String to int
      int lineWidth =
          int.tryParse(membershipExpiryBar['line_width'] ?? '') ?? 0;

      // Convert date strings to DateTime objects
      startDate = DateTime.tryParse(startDateString) ?? DateTime.now();
      endDate = DateTime.tryParse(endDateString) ?? DateTime.now();

      // Print the loaded values
      print("Start Date: $startDate");
      print("End Date: $endDate");
      print("Line Width: $lineWidth");

      // Now you can use these variables as needed in your application.
    } catch (e) {
      print("Failed to load Membership Expiry Bar. Error: $e");
    }
  }

  // Assuming you want to convert the saved strings to DateTime
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  Color _getVerificationIconColor(DateTime currentDate) {
    int daysRemaining = endDate.difference(currentDate).inDays;

    if (daysRemaining <= 10) {
      return Colors.red;
    } else if (daysRemaining <= 30) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  // Calculate percent based on the color and remaining days
  double calPresentDay(DateTime currentDate) {
    int daysRemaining = endDate.difference(currentDate).inDays;
    double startPercent, endPercent;

    if (_getVerificationIconColor(currentDate) == Colors.green) {
      startPercent = 0.01;
      endPercent = 0.39;
    } else if (_getVerificationIconColor(currentDate) == Colors.yellow) {
      startPercent = 0.40;
      endPercent = 0.59;
    } else {
      startPercent = 0.60;
      endPercent = 1.0;
    }

    int totalDays = endDate.difference(startDate).inDays;

    // Ensure that totalDays is not zero to avoid division by zero
    double present = totalDays != 0
        ? startPercent +
            (endPercent - startPercent) * (1 - (daysRemaining / totalDays))
        : 0.0;

    return present;
  }

  Future<void> loadUserDataAndSetImage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String userDataKey = 'user';

      final String? userDataJson = prefs.getString(userDataKey);

      if (userDataJson != null) {
        final Map<String, dynamic> userData = json.decode(userDataJson);
        print('user data loaded locally: $userData');

        // Extract the image URL
        String? imageUrl = userData['image'];

        if (imageUrl != null) {
          print('Image URL: $imageUrl');

          // Set the global variable
          globalImageUrl = imageUrl;

          // Update the state to trigger a rebuild
          setState(() {});
        } else {
          print('Image URL is null or not found in user data.');
        }
      } else {
        print('No user data found locally.');
      }
    } catch (e) {
      print('Error loading user data locally: $e');
    }
  }

  ImageProvider<Object>? getImageProvider() {
    if (globalImageUrl != null) {
      // Check if globalImageUrl is a network URL
      if (globalImageUrl!.startsWith('http') ||
          globalImageUrl!.startsWith('https')) {
        return NetworkImage(globalImageUrl!);
      } else {
        // It's a local file path, construct the full URL using ApiConstantsProfileImage
        String fullImageUrl =
            ApiConstantsProfileImage.getProfileImageUrl(globalImageUrl!);
        return NetworkImage(fullImageUrl);
      }
    } else {
      return const AssetImage('assets/images/profile/no_profile.png');
    }
  }

  Future<void> loadUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String userDataKey = 'user_data';

      final String? userJson = prefs.getString(userDataKey);

      if (userJson != null) {
        final Map<String, dynamic> userMap = json.decode(userJson);

        setState(() {
          userName = userMap['first_name'];

          userEmail = userMap['email'];
        });

        print('User data loaded successfully: $userMap');
      } else {
        print('No user data found in shared preferences.');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    loadUserData();
    loadAndFilterData();
  }

  Future<void> _initializeData() async {
    await loadMembershipExpiryBar();

    await loadSelectedDataFromSharedPreferences();
    await loadUserDataAndSetImage();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.userData;

    final sceintific = widget.userData['prop_scientific_section'];

    final other = widget.userData['prop_list_serves'];

    final work = widget.userData['prop_working_groups'];

    final union = widget.userData['union_region'];

    final dayCount = widget.userData['day_count'];

    print('Dat Count : $dayCount');
    final aValidationStartDate =
        widget.userData['membershi_expipiry_bar']['start_date'];
    print('Start Date :$aValidationStartDate');

    final aValidationEndDate =
        widget.userData['membershi_expipiry_bar']['end_date'];
    print('End date : $aValidationEndDate');

    // date
    DateTime currentDate = DateTime.now();
    Color verificationIconColor = _getVerificationIconColor(currentDate);
    double percent = calPresentDay(currentDate);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: newKBgColor,
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
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(8, 16, 0, 0),
                              child: Text(
                                "Memebrship\nDetails",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Adamina',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 40,
                                left: 18,
                              ),
                              child: SvgPicture.asset('assets/Group.svg'),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 18),
                              child: CircularPercentIndicator(
                                radius: 45.0,
                                lineWidth: 6.0,
                                percent: percent,
                                center: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "$dayCount Days",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      "only",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                progressColor: verificationIconColor,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.8,
                )
              ],
            ),

            Positioned(
              top: 220,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Container(
                height: screenHeight * 0.37,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 23, left: 16, right: 20),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                              color: Colors.black.withOpacity(0.1), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 65,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scientific Section',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              Text(
                                '${sceintific.join(', ')}',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                              color: Colors.black.withOpacity(0.1), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 65,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Other Data ',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              Text('${other.join(', ')}',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                              color: Colors.black.withOpacity(0.1), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 65,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Work Data: ',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              Text('${work.join(', ')}',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                              color: Colors.black.withOpacity(0.1), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 65,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Union Data ',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              Text(
                                '${union.join(', ')}',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
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

            //Validation Dates section
            Positioned(
              top: screenHeight * 0.64,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: const Row(
                children: [
                  Text(
                    'Validation Dates',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 16),
                  )
                ],
              ),
            ),
            Positioned(
              top: screenHeight * 0.69,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Container(
                height: 100,
                width: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFFC7DCE2).withOpacity(0.5),
                            ),
                            height: 60,
                            width: 150,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    child: SvgPicture.asset(
                                      'assets/icon _calendar_.svg',
                                      fit: BoxFit.fill,
                                      height: screenHeight * 0.03,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    aValidationStartDate != ''
                                        ? aValidationEndDate
                                        : 'Sorry..\nComplete Payments.',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFFC7DCE2).withOpacity(0.5),
                            ),
                            height: 60,
                            width: 150,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    child: SvgPicture.asset(
                                      'assets/icon _calendar_.svg',
                                      fit: BoxFit.fill,
                                      height: screenHeight * 0.03,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    aValidationEndDate != ''
                                        ? aValidationEndDate
                                        : 'Sorry..\nComplete Payments.',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //Prop catergories Dates section
            Positioned(
              top: screenHeight * 0.85,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: const Row(
                children: [
                  Text(
                    'Prop catergories',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 16),
                  )
                ],
              ),
            ),
            Positioned(
              top: screenHeight * 0.89,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Container(
                height: screenHeight * 0.35,
                width: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Column(
                  children: [
                    DataTable(
                      columns: <DataColumn>[
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'CATERGORY',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'START\nDATE',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              ' END\n DATE',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        // DataColumn(
                        //   label: Expanded(
                        //     child: Text(
                        //       'PRIZE',
                        //       style: TextStyle(
                        //         fontSize: 10,
                        //         color: Theme.of(context)
                        //             .colorScheme
                        //             .primary
                        //             .withOpacity(0.8),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                      rows: <DataRow>[
                        DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Text(
                                productDescription,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            ),
                            DataCell(
                              Text(
                                createdAt,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            ),
                            DataCell(
                              Text(
                                lastUpdate,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            ),
                            // DataCell(
                            //   InkWell(
                            //     onTap: () {
                            //       print('Clicked');
                            //     },
                            //     child: Row(
                            //       children: [
                            //         const Text(
                            //           '\$',
                            //           style: TextStyle(
                            //               fontSize: 12, color: Colors.black),
                            //         ),
                            //         Text(
                            //           amount.toString(),
                            //           style: const TextStyle(
                            //               fontSize: 12, color: Colors.black),
                            //         ),
                            //         const SizedBox(
                            //             width: 5), // Adjust spacing as needed
                            //         const Icon(Icons.navigate_next_sharp,
                            //             size: 15),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
