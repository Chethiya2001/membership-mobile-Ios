import 'dart:convert';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/constant/election/election_base_api.dart';
import 'package:mobile_app/features/election/election_list/screens/election_list_screen.dart';
import 'package:mobile_app/features/membership/home/data/navigation_list_data_01.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/constant/base_img_api.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';

class ListDrawer extends StatefulWidget {
  const ListDrawer({
    super.key,
  });

  @override
  State<ListDrawer> createState() => _ListDrawerState();
}

class _ListDrawerState extends State<ListDrawer> {
  String? userName;
  String? userEmail;
  static String? globalImageUrl;
  String? loadedMembershipId;
  String? globalOrgId;

  Future<void> loadOrgIdFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    globalOrgId = prefs.getString('org_id');
    if (globalOrgId != null) {
      print("Loaded group id: $globalOrgId");
    } else {
      print('No Organization ID found $globalOrgId');
    }
  }

  //get election token

  Future<String?> getElectionToken() async {
    if (userEmail == null) {
      print('User email is null');
      return null;
    } else {
      print(userEmail);
    }

    const String apiBaseUrl = ApiConstantsElection.baseUrl;
    const String apiEndpoint = '$apiBaseUrl/generate-token';
    try {
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": userEmail,
        }),
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final token = data['token'];
        await TokenManager.saveToken(token);

        print("Token saved successfully");

        print("success");
        return token;
      }
    } catch (e) {
      print('Error while getting token: $e');
      return null;
    }
    return null;
  }

  //load Org Id

  //get election list
  Future<bool> getElectionData() async {
    const String baseUrl = ApiConstantsElection.baseUrl;
    String apiEndpoint = '$baseUrl/get-election?orgId=$globalOrgId';

    final token = await TokenManager.getToken();

    if (token == null) {
      print("User not authenticated. Please log in.");
      return false;
    }
    if (globalOrgId == null) {
      print("Organization ID is null. Please set an organization ID.");
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Organization ID Found. Please get an organization ID.'),
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

      return false;
    }

    try {
      // Make HTTP GET request
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cookie': 'access_token=$token'
        },
      );
      print(response.statusCode);
      print(response.body);

      // Check the response status code
      if (response.statusCode == 200) {
        var resBody = json.decode(response.body);
        print(resBody);

        print('success');

        if (mounted) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => ElectionListScreen(
                    data: resBody,
                  )));
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text(
                    'Failed to fetch election data. Please try again later.'),
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

        print('Failed to fetch election data: ${response.statusCode}');
        // or handle the error as per your requirement
      }
      return true;
    } catch (e) {
      print('Exception during HTTP request: $e');
      return false; // or handle the exception as per your requirement
    }
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

  ImageProvider<Object>? getImageProvider() {
    if (globalImageUrl != null) {
      if (globalImageUrl!.startsWith('http') ||
          globalImageUrl!.startsWith('https')) {
        return NetworkImage(globalImageUrl!);
      } else {
        String fullImageUrl =
            ApiConstantsProfileImage.getProfileImageUrl(globalImageUrl!);
        return NetworkImage(fullImageUrl);
      }
    } else {
      return const AssetImage('assets/images/profile/no_profile.png');
    }
  }

  //get data profile

  Future<String> loadMembershipIdLocally() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String membershipKey = 'membership';

      // Get membership ID from shared preferences
      final String? loadedId = prefs.getString(membershipKey);

      return loadedId ?? ''; // Return an empty string if null
    } catch (e) {
      print('Error loading membership ID locally: $e');
      return ''; // Return an empty string in case of an error
    }
  }

  Future<bool> getData() async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        print("User not authenticated. Please log in.");
        return false;
      }

      if (loadedMembershipId == null) {
        print("Membership ID is null. Please set a membership ID.");
        return false;
      }

      const String apiBaseUrl = ApiConstants.baseUrl;
      final String apiEndpoint =
          '$apiBaseUrl/membership-profile-details/$loadedMembershipId';

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
        var userData = json.decode(response.body);
        print("Success get user data");
        saveMembershipCategories(userData['membership_prop_categories']);

        // Check if 'day_count' exists and is not null
        if (userData.containsKey('day_count') &&
            userData['day_count'] != null) {
          saveDayCount(userData['day_count']);
          print('Day count saved: ${userData['day_count']}');
        } else {
          print('Day count is null or not found in userData');
        }
        print(userData);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void saveMembershipCategories(Map<String, dynamic> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const key = 'membership_prop_categories';

      // Convert the map to a JSON string
      String categoriesJson = json.encode(categories);

      // Save the JSON string to SharedPreferences
      prefs.setString(key, categoriesJson);

      print('Membership categories saved successfully.');

      // Retrieve the saved data and print it
      String savedCategoriesJson = prefs.getString(key) ?? '';
      Map<String, dynamic> savedCategories = json.decode(savedCategoriesJson);

      print('Saved Membership Categories:');
      print("Saved prop catergories $savedCategories");
    } catch (e) {
      print('Error saving or printing membership categories: $e');
    }
  }

// Function to save the day_count value
  void saveDayCount(int dayCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('day_count', dayCount);
    if (kDebugMode) {
      print('day_count saved: $dayCount');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
    loadUserData();
  }

  Future<void> initializeData() async {
    await loadUserDataAndSetImage();
    await loadOrgIdFromPreferences();
    loadMembershipIdLocally().then((loadedId) {
      getElectionToken();
      setState(() {
        loadedMembershipId = loadedId;
      });
      print('Loaded Membership ID in initState: $loadedId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    await AuthManager.logout(context);
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Icon(
                                      Icons.logout_sharp,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(8, 16, 0, 0),
                          child: Text(
                            "MY MEMBERSHIP",
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
                  ),
                ),
                const SizedBox(
                  height: 610,
                )
              ],
            ),

            Positioned(
              top: 160,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Container(
                height: 780,
                width: screenWidth * 0.9,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                  children: [
                    //profile data container
                    Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 40, 8, 2),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: getImageProvider(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName ?? '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 26,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 1,
                                      ),
                                      Text(
                                        userEmail ?? '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 33,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
                      child: DottedLine(
                        alignment: WrapAlignment.center,
                        dashColor: Colors.black.withOpacity(0.5),
                        direction: Axis.horizontal,
                      ),
                    ),

                    //second dotted line
                    SizedBox(
                      height: 290,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 30, 8, 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 2,
                            ),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: screenWidth *
                                      0.8, // Maximum width of each item
                                  mainAxisSpacing: 10.0,
                                  crossAxisSpacing: 10.0,
                                  childAspectRatio:
                                      2.5, // Aspect ratio (width / height)
                                ),
                                itemCount: menuItems
                                    .length, // Total number of items (2 rows * 4 columns)
                                itemBuilder: (BuildContext context, int index) {
                                  final firstItems = menuItems[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                          color: newKMainColor.withOpacity(0.5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: SvgPicture.asset(
                                              firstItems.svgPath,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, firstItems.route);
                                            },
                                            child: Text(
                                              firstItems.name,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    // Text('Logout'),
                    //Thierd Dotted Line
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
                      child: DottedLine(
                        alignment: WrapAlignment.center,
                        dashColor: Colors.black.withOpacity(0.5),
                        direction: Axis.horizontal,
                      ),
                    ),
                    const SizedBox(
                      height: 33,
                    ),
                    SizedBox(
                      height: 230,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: screenWidth *
                                      0.8, // Maximum width of each item
                                  mainAxisSpacing: 10.0,
                                  crossAxisSpacing: 10.0,
                                  childAspectRatio:
                                      2.5, // Aspect ratio (width / height)
                                ),
                                itemCount: menuItemsTow
                                    .length, // Total number of items (2 rows * 4 columns)
                                itemBuilder: (BuildContext context, int index) {
                                  final firstItems = menuItemsTow[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                          color: newKMainColor.withOpacity(0.5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: SvgPicture.asset(
                                              firstItems.svgPath,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, firstItems.route);
                                            },
                                            child: Text(
                                              firstItems.name,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // const SizedBox(
                            //   height: 22,
                            // ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 170,
                                  height: 70,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                          color: newKMainColor.withOpacity(0.5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: SvgPicture.asset(
                                              'assets/svg_list_draver/memebrsipProfile.svg',
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              getElectionData();
                                            },
                                            child: const Text(
                                              "Election",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
            ),
            Positioned(
              bottom: 45,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(newKMainColor),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Renew",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            //Curcles Blue
            Positioned(
              top: 300,
              left: 5,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: newKMainColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 300,
              right: 5,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: newKMainColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            //Curcles White
            Positioned(
              top: 615,
              left: 5,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: newKBgColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 615,
              right: 5,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: newKBgColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TokenManager {
  static const String _tokenKey = 'election_token';

  static Future<bool> saveToken(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      return true;
    } catch (e) {
      print('Error saving token: $e');
      return false;
    }
  }

  static Future<String?> getToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  static Future<bool> removeToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      return true;
    } catch (e) {
      print('Error removing token: $e');
      return false;
    }
  }
}
