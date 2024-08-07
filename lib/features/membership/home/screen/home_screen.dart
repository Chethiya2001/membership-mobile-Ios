import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/countact_us/screens/main_contact_us_screen.dart';
import 'package:mobile_app/features/membership/faqs/screens/main_faqs_screen.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/details_home_widget.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/list_drawer.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/screens/user_profile_screen.dart';
import 'package:mobile_app/features/membership/tearms&condition/screens/main_tearms_and_condition_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.signOutCallback,
  });

  final VoidCallback signOutCallback;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Images Slid Show
  final List<String> imageListShow = [
    'assets/images/home_comany_img/1.jpeg',
    'assets/images/home_comany_img/2.jpeg',
    'assets/images/home_comany_img/3.jpg',
    'assets/images/home_comany_img/3.jpg',
  ];

  String? userName;

  Future<void> loadUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String userDataKey = 'user_data';

      final String? userJson = prefs.getString(userDataKey);

      if (userJson != null) {
        final Map<String, dynamic> userMap = json.decode(userJson);

        setState(() {
          userName = userMap['first_name'];
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
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
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
        hoverColor: Colors.black,
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
        child: IntrinsicHeight(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue,
                      Colors.white,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Back button
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 0, 0),
                            child: Text(
                              "Hi, WELCOME \n$userName\uD83D\uDC4B",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AutofillHints.impp),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ListDrawer(),
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
                                      Icons.menu,
                                      color: Colors.black,
                                    ),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageListShow.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Image.asset(
                                  imageListShow[index],
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width *
                                      0.8, // adjust the width as needed
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
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
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        height: screenHeight * 0.10,
                        width: screenWidth * 0.87,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 15, 2, 2),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print('Text clicked!');
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          const UserProfileScreen(),
                                    ));
                                  },
                                  child: const Text(
                                    'GET A MEMBERSHIP',
                                    style: TextStyle(
                                      color: newKMainColor,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                const Text(
                                  'GET A MEMEBRSHIP AND ACCESS ALL FEATURES',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: DetailsHome(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Positioned to White part of the widget
        ),
      ),
    );
  }
}
