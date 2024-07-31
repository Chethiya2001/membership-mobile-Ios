import 'dart:convert';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/screens/user_profile_screen.dart';
import 'package:mobile_app/features/membership/webinars/providers/webinar_provider.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/membership/webinars/screens/download_webinar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebinarScreen extends ConsumerStatefulWidget {
  const WebinarScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WebinarScreenState createState() => _WebinarScreenState();
}

class _WebinarScreenState extends ConsumerState<WebinarScreen> {
  Future<Map<String, dynamic>> getWebinarData(int webinarId) async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        print("User not authenticated. Please log in.");
        return {}; // or return an empty Map
      }

      const String apiBaseUrl = ApiConstants.baseUrl;
      final String apiEndpoint =
          '$apiBaseUrl/directory-webinar-item-viwe/$webinarId';

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
        var webinarDownloadData = json.decode(response.body);
        print("Success get data");
        print(webinarDownloadData);
        return webinarDownloadData;
      } else {
        print(
            'Error getting webinar download  data. Status Code: ${response.statusCode}');
        return {}; // or return an empty Map
      }
    } catch (e) {
      print('Error getting webinar download data: $e');
      return {}; // or return an empty Map
    }
  }

  String? loadedMembershipId;
  Future<String> loadMembershipIdLocally() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      const String membershipKey = 'membership';

      // Get membership ID from shared preferences
      final String? loadedId = pref.getString(membershipKey);

      return loadedId ?? ''; // Return an empty string if null
    } catch (e) {
      log.e('Error loading membership ID locally: $e');
      return ''; // Return an empty string in case of an error
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
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
    final membershipId = loadedMembershipId ?? '';
    if (membershipId.isEmpty) {
      return Scaffold(
        backgroundColor: newKBgColor,
        body: Center(
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 0, // Set elevation to 0 to remove the default shadow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Still not a member!',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(), // Add a divider between title and content
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Please join with us,',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => const UserProfileScreen(),
                          ));
                        },
                        child: Text(
                          'Join now',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary, // Use primary color for the button text
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        bottomNavigationBar: BottomAppBar(
          color: Colors.white12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon:
                    const Icon(Icons.how_to_vote_rounded, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.supervised_user_circle,
                    color: Colors.black),
                onPressed: () {},
              ),
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
            borderRadius: BorderRadius.circular(
                60), // You can adjust the radius as needed
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
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 60, 0, 2),
                              child: Text(
                                "Webinars",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Adamina',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 50, left: 18),
                              child:
                                  SvgPicture.asset('assets/contactUs-Svg.svg'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.8,
                  )
                ],
              ),
              Positioned(
                top: 180,
                left: (screenWidth - screenWidth * 0.9) / 2,
                right: (screenWidth - screenWidth * 0.9) / 2,
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
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Select Category",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 20,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: DottedLine(
                                alignment: WrapAlignment.center,
                                dashColor: Colors.black.withOpacity(0.5),
                                direction: Axis.horizontal,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 200,
                              child: Consumer(
                                builder: (context, watch, child) {
                                  final webinarListData =
                                      ref.watch(webinarListProvider);
                                  return webinarListData.when(
                                    data: (data) {
                                      // Handle the loaded data here
                                      final webinarList = data['success'];
                                      return ListView.separated(
                                        itemCount: webinarList.length,
                                        itemBuilder: (context, index) {
                                          final webinar = webinarList[index];

                                          if (webinar.containsKey('children') &&
                                              webinar['children'].isNotEmpty) {
                                            // Use ExpansionTile for items with children
                                            return Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              margin: const EdgeInsets.all(8.0),
                                              elevation:
                                                  5.0, // Set elevation for the Card
                                              child: ExpansionTile(
                                                title: Row(
                                                  children: [
                                                    Text(
                                                      webinar['title'],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const Icon(
                                                        Icons
                                                            .arrow_right_outlined,
                                                        color: Colors.black)
                                                  ],
                                                ),
                                                tilePadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 8.0,
                                                ),
                                                children: const [],
                                              ),
                                            );
                                          } else {
                                            return Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              margin: const EdgeInsets.all(8.0),
                                              elevation: 5.0,
                                              child: ListTile(
                                                title: Row(
                                                  children: [
                                                    Text(
                                                      webinar['title'],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    const Icon(
                                                        Icons
                                                            .arrow_right_outlined,
                                                        color: Colors.black)
                                                  ],
                                                ),
                                                tileColor: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                onTap: () async {
                                                  var webinarId = webinar["id"];

                                                  Map<String, dynamic>
                                                      webinarDownloadData =
                                                      await getWebinarData(
                                                          webinarId);

                                                  if (mounted) {
                                                    // ignore: use_build_context_synchronously
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (ctx) =>
                                                                WebinarDownloadScreen(
                                                                    selecterdCatergory:
                                                                        webinarDownloadData)));
                                                  }
                                                  print(
                                                      "Button clicked for webinar ID: $webinarId");
                                                },
                                              ),
                                            );
                                          }
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 10, 0, 10),
                                            child: DottedLine(
                                              alignment: WrapAlignment.center,
                                              dashColor:
                                                  Colors.black.withOpacity(0.2),
                                              direction: Axis.horizontal,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    loading: () => const Center(
                                        child: CircularProgressIndicator()),
                                    error: (error, stackTrace) {
                                      // Handle error
                                      return Text('Error: $error');
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //Curcles Blue
              Positioned(
                top: 250,
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
                top: 250,
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
            ],
          ),
        ),
      );
    }
  }
}
