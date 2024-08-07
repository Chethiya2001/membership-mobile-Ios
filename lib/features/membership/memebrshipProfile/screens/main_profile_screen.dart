import 'dart:convert';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/constant/base_img_api.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/countact_us/screens/main_contact_us_screen.dart';
import 'package:mobile_app/features/membership/faqs/screens/main_faqs_screen.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/screens/invoices/invoice_screen.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/screens/profile_screen.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/screens/user_profile_screen.dart';
import 'package:mobile_app/features/membership/tearms&condition/screens/main_tearms_and_condition_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProfilePage extends StatefulWidget {
  const MainProfilePage({super.key});

  @override
  State<MainProfilePage> createState() => _MainProfilePageState();
}

class _MainProfilePageState extends State<MainProfilePage> {
  // File? _selectedProfileImage;
  // Variables to store extracted values
  List<String> itemNames = [];
  List<int> quantities = [];
  List<double> amounts = [];
  List<String> priceBookNames = [];
  final log = Logger();
  final profDetailsKey = GlobalKey<FormState>();
  String? loadedMembershipId;
  static String? globalImageUrl;
  List<Map<String, dynamic>> membershipDetails = [];

  String? email;

  Future<void> loadUserDataAndSetImage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String userDataKey = 'user';

      final String? userDataJson = prefs.getString(userDataKey);

      if (userDataJson != null) {
        final Map<String, dynamic> userData = json.decode(userDataJson);
        print('user data loaded locally: $userData');
        // Extract the email
        String? email = userData['email'];

        if (email != null) {
          print('Email: $email');

          // Update the state to trigger a rebuild
          setState(() {
            this.email = email;
          });
        } else {
          print('Email is null or not found in user data.');
        }
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

  Future<void> loadInvoiceSummery() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String invoiceKey = 'membership_invoice';

      // Load invoice data from shared preferences
      String? invoiceJson = prefs.getString(invoiceKey);

      if (invoiceJson != null) {
        // Parse the JSON string to get the invoice data as a Map
        Map<String, dynamic> invoice = json.decode(invoiceJson);

        // Get and parse the invoice summary
        String? invoiceSummaryJson = invoice['invoice_summary'];
        if (invoiceSummaryJson != null) {
          Map<String, dynamic> invoiceSummary = json.decode(invoiceSummaryJson);

          // Extract values from the invoiceSummary map
          List<dynamic> invoiceItems = invoiceSummary['invoice_items'];

          for (var item in invoiceItems) {
            String itemName = item['item_name'].toString();
            int quantity = item['quantity'];
            double amount = item['amount'].toDouble(); // Convert to double
            String priceBookName = item['price_book_name'].toString();

            // Assign values to respective lists or variables
            itemNames.add(itemName);
            quantities.add(quantity);
            amounts.add(amount);
            priceBookNames.add(priceBookName);
          }

          // Example: Print the first item's name
          if (itemNames.isNotEmpty) {
            print('First Item Name: ${itemNames[0]}');
          }

          // Debug: Print the values of lists
          print('Item Names: $itemNames');
          print('Quantities: $quantities');
          print('Amounts: $amounts');
          print('Price Book Names: $priceBookNames');
        }
      }
    } catch (e) {
      print('Error loading invoice locally: $e');
    }
  }

  Future<bool> getValidateDates() async {
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
        var decodedBody = json.decode(resBody);

        log.d("Submit Successfully");
        print(decodedBody);
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => ProfileScreen(
                  userData: decodedBody,
                )));

        // Check if 'membership_prop_categories' is present and not empty
        if (decodedBody.containsKey('membership_prop_categories') &&
            (decodedBody['membership_prop_categories'] as Map).isNotEmpty) {
          // Save the membership expiry bar data
          saveMembershipExpiryBar(decodedBody['membershi_expipiry_bar']);
          saveMembershipPropCategories(
              decodedBody['membership_prop_categories']);
        } else {
          print(
              'No or empty "membership_prop_categories" in the API response.');
        }
      } else {
        log.e(
            "Failed to submit. Check the response body for details. Response Body: $resBody");
      }

      return true;
    } catch (e) {
      print("Failed to get validate dates. Error: $e");
      return false;
    }
  }

  Future<bool> getInvoiceData() async {
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
      const String apiEndpoint = '$apiBaseUrl/incoice-list';

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

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => InvoiveScreen(
                invoiceData: invoiceData,
              ),
            ),
          );
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveMembershipPropCategories(Map<String, dynamic> data) async {
    try {
      // Convert the data to a JSON String
      String jsonData = jsonEncode(data);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save the data
      await prefs.setString('membership_prop_categories', jsonData);

      // Convert JSON String back to a Map
      Map<String, dynamic> savedData = jsonDecode(jsonData);

      // Print the saved data
      print("Saved Membership Prop Categories: $savedData");

      print("Membership Prop Categories saved successfully.");
    } catch (e) {
      print("Failed to save Membership Prop Categories. Error: $e");
    }
  }

//save expier bar thigns
  Future<void> saveMembershipExpiryBar(
      Map<String, dynamic> membershipExpiryBar) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Convert the Map to a JSON String
      String membershipExpiryBarJson = jsonEncode(membershipExpiryBar);

      // Save the JSON String to SharedPreferences
      await prefs.setString('membership_expiry_bar', membershipExpiryBarJson);

      print("Membership Expiry Bar saved successfully.");
      print("Saved Membership Expiry Bar: $membershipExpiryBarJson");
    } catch (e) {
      print("Failed to save Membership Expiry Bar. Error: $e");
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

  Future<List<Map<String, dynamic>>> loadMembershipDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const key = 'membership_prop_categories';

      // Retrieve the JSON string from SharedPreferences
      String categoriesJson = prefs.getString(key) ?? '';

      // Parse the JSON string to a map
      Map<String, dynamic> categories = json.decode(categoriesJson);

      // List to store extracted details
      List<Map<String, dynamic>> membershipDetailsList = [];

      // Iterate over each category and extract details
      categories.forEach((categoryId, categoryDetails) {
        // Iterate over each item in the category and extract details
        List<dynamic> items = categoryDetails as List<dynamic>;
        for (var item in items) {
          // Extract specific details (e.g., product_description and quantity)
          Map<String, dynamic> details = {
            'product_description': item['product_description'],
            'quantity': item['quantity'],
          };

          // Print the details
          print('Load prop catergory success');
          print('Product Description: ${details['product_description']}');
          print('Quantity: ${details['quantity']}');
          print('----------------------');

          // Add details to the list
          membershipDetailsList.add(details);
        }
      });

      return membershipDetailsList;
    } catch (e) {
      print('Error loading membership details: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    loadInvoiceSummery();
    getInvoiceData();
    initializeData();
    loadUserDataAndSetImage();
    loadMembershipDetails().then((data) {
      setState(() {
        membershipDetails = data;
      });
    });
  }

  Future<void> initializeData() async {
    await loadMembershipDetails();
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
                                "Memebrship\nProfile",
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
                height: screenHeight * 0.285,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.grey.withOpacity(0.5), // Color of the shadow
                      offset: const Offset(
                          1, 2), // Offset of the shadow [horizontal, vertical]
                      blurRadius: 4, // Spread radius of the shadow
                      spreadRadius: 2, // Extend the shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.280,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 22, left: 16, right: 20),
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: screenHeight * 0.01,
                            );
                          },
                          scrollDirection: Axis.vertical,
                          itemCount: itemNames.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 250,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            itemNames[index],
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                fontFamily: 'Poppins'),
                                          ),
                                          Text(
                                            'Quantity: ${quantities[index]}',
                                            style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            priceBookNames[index],
                                            style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          getValidateDates();
                                        },
                                        icon: const Icon(
                                            Icons.arrow_forward_ios_sharp),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //comment section
            Positioned(
              top: screenHeight * 0.58,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Container(
                height: 100,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: const Offset(1, 3),
                    ),
                  ],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 26, left: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: getImageProvider(),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          email != null
                              ? Text(
                                  ' $email',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: 'Poppins'),
                                )
                              : const Text(
                                  'Loading user data...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w200,
                                      fontSize: 10,
                                      fontFamily: 'Poppins'),
                                ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //invoice section
            Positioned(
              top: screenHeight * 0.74,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Container(
                height: 80,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: const Offset(1, 3),
                    ),
                  ],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await getInvoiceData();
                            },
                            child: const Text(
                              'Invoices',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  fontFamily: 'Poppins'),
                            ),
                          )
                        ],
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

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }
}
