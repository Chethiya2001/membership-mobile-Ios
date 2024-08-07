// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';

import 'package:mobile_app/features/membership/countact_us/screens/main_contact_us_screen.dart';
import 'package:mobile_app/features/membership/faqs/screens/main_faqs_screen.dart';
import 'package:mobile_app/features/membership/home/data/navigation_list_data_01.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:mobile_app/features/membership/stages/models/product_list_.dart';
import 'package:mobile_app/features/membership/stages/widgets/stage_three_widget.dart';
import 'package:mobile_app/features/membership/tearms&condition/screens/main_tearms_and_condition_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/features/membership/auth/provider/country.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/provider/user_data_provider.dart';

class MemebrshipStatageWidget extends ConsumerStatefulWidget {
  const MemebrshipStatageWidget({
    super.key,
    required this.response,
  });
  final dynamic response;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MemebrshipStatageWidgetState();
}

class _MemebrshipStatageWidgetState
    extends ConsumerState<MemebrshipStatageWidget> {
  final memberKey = GlobalKey<FormState>();
  final log = Logger();
  Color buttonColor = Colors.black;
  int selectedIndex = -1;

  /// Addons
  List<Map<String, dynamic>> tableDataList = [];
  List<int> selectedRow = [];
  Map<int, int> quantityMap = {};
  List<int> totalQuantity = [];

  late SharedPreferences prefs;

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveTotalQuantity() async {
    try {
      if (totalQuantity.isNotEmpty) {
        await prefs.setString('total_quantity_list', totalQuantity.join(','));
      }
    } catch (e) {
      print('Error saving total quantity list: $e');
    }
  }

  Future<void> loadTotalQuantity() async {
    try {
      String? savedTotalQuantityList = prefs.getString('total_quantity_list');
      if (savedTotalQuantityList != null) {
        setState(() {
          totalQuantity =
              savedTotalQuantityList.split(',').map(int.parse).toList();
        });

        print('Loaded total quantity list: $totalQuantity');
      }
    } catch (e) {
      print('Error loading total quantity list: $e');
    }
  }

  void updateQuantity(int index, int delta) {
    setState(() {
      quantityMap[index] =
          ((quantityMap[index] ?? 0) + delta).clamp(0, double.infinity).toInt();
      updateTotalQuantity();
    });
  }

  void updateTotalQuantity() {
    totalQuantity = [
      quantityMap.values.reduce((sum, quantity) => sum + quantity)
    ];
  }

  Future<void> saveSelectedData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String selectedDataKey = 'selected_addons';

      final List<String> selectedDataJsonList = selectedRow.map((index) {
        final Map<String, dynamic> selectedData = tableDataList[index];
        return json.encode(selectedData);
      }).toList();

      await prefs.setStringList(selectedDataKey, selectedDataJsonList);
    } catch (e) {
      print('Error saving selected data: $e');
    }
  }

  /// Billing
  bool checkBoxYes = false;
  bool checkBoxNo = false;
  final userKey = GlobalKey<FormState>();
  String? selectedmobileCode = '';
  String? selectedCountry = '';
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final mobileNumberController = TextEditingController();
  String? selectedProductId;
  String? selectedProductCode;
  String? selectedProductLastPrice;

  Future<bool> submitSecondForm() async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        print("User not authenticated. Please log in.");
        return false;
      }

      const String apiBaseUrl = ApiConstants.baseUrl;
      const String apiEndpoint = '$apiBaseUrl/user-membership-2nd-form-update';

      final String address = emailController.text;
      final String city = cityController.text;
      final String mobile = mobileNumberController.text;
      final String country = selectedCountry ?? "";
      final String email = emailController.text;
      final String mobileCode = selectedmobileCode ?? "";

      // await saveSelectedDataLocally();
      // await loadProductData();
      final addons = widget.response['data']['addons'];

      final formData = {
        "address1": address,
        "city": city,
        "country": country,
        "mobile": mobile,
        "email": email,
        "mobileCode": mobileCode,
        "price_book_entry_id": selectedProductId ?? "",
        "product_custom_price": selectedProductLastPrice ?? "",
        "membership_category": selectedProductCode ?? "",
        "item_ids": addons != null && addons.isNotEmpty
            ? {
                "179": totalQuantity.isNotEmpty ? totalQuantity[0] : 0,
              }
            : ""
      };

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(formData),
      );

      log.d('Response Status Code: ${response.statusCode}');

      log.d('Response Body: ${response.body}');

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        try {
          var resBody = json.decode(response.body);
          log.d('saved Data$resBody');
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
                builder: (ctx) => MembershipDetailsWidget(
                      catgoryData: resBody,
                    )));
          }
          // Save scientific section locally
          if (resBody['success']['scientific_section'] != null) {
            saveScientificSectionLocally(
                resBody['success']['scientific_section']);
          }

          if (resBody['success']['membership'] != null) {
            final membershipData = resBody['success']['membership'];
            if (membershipData is Map<String, dynamic>) {
              log.d('Membership Data: $membershipData');
              saveMembershipIdLocally(membershipData);
            } else {
              log.e('Invalid Membership Data format: $membershipData');
            }
          } else {
            log.e('Membership Data is null.');
          }
          _successMsg("Updated successfully.");
        } catch (e) {
          log.d('Error decoding response body: $e');
        }
      } else {
        log.d('Error submitting data. Status Code: ${response.statusCode}');
        log.d('Error Response Body: ${response.body}');
        _showErrorDialog('Please select a memebrship type');
      }

      return true;
    } catch (e) {
      log.e('Error submitting data: $e');
      return false;
    }
  }

  //SAVE SCIENTIFIC
  Future<void> saveScientificSectionLocally(List<dynamic> scientific) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String scientificKey = 'scientific_section';

      // Convert addons data to JSON string
      final List<Map<String, dynamic>> scientificList =
          scientific.cast<Map<String, dynamic>>();
      final String scientificJson = json.encode(scientificList);

      // Save JSON string to shared preferences
      await prefs.setString(scientificKey, scientificJson);

      log.d('scientific section data saved locally: $scientificJson');
    } catch (e) {
      log.e('Error saving addons data locally: $e');
    }
  }

  Future<void> saveInvoiceIdLocally(int invoiceId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String invoiceIdKey = 'invoice_id';

      // Save invoice_id to shared preferences
      await prefs.setInt(invoiceIdKey, invoiceId);

      print('Invoice ID saved locally: $invoiceId');
    } catch (e) {
      print('Error saving invoice_id locally: $e');
    }
  }

  Future<void> saveMembershipIdLocally(Map<String, dynamic> membership) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String membershipKey = 'membership';

      // Check if 'membership_id' key exists in the membership map
      final String membershipId = membership.containsKey('membership_id')
          ? membership['membership_id'].toString()
          : '';

      // Save 'membership_id' to shared preferences
      await prefs.setString(membershipKey, membershipId);

      log.d('Membership ID saved locally: $membershipId');
    } catch (e) {
      log.e('Error saving membership ID locally: $e');
    }
  }

  Future<void> loadUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String userDataKey = 'billing';

      final String? userJson = prefs.getString(userDataKey);

      if (userJson != null) {
        final Map<String, dynamic> userMap = json.decode(userJson);

        setState(() {
          emailController.text = userMap['email'];
          mobileNumberController.text = userMap['mobile'];
          addressController.text = userMap['address_line1'];
          cityController.text = userMap['city'];
          postalCodeController.text = userMap['po_code'];
        });

        print('Billing data loaded successfully: $userMap');
      } else {
        print('No Billing data found in shared preferences.');
      }
    } catch (e) {
      print('Error loading Billing data: $e');
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

    // loadSelectedProducts();
    initSharedPreferences();
  }

  String _getPrice(dynamic data) {
    if (data is List && data.isNotEmpty && data[0]['last_price'] is int) {
      return data[0]['last_price'].toString();
    } else if (data is Map && data['last_price'] is int) {
      return data['last_price'].toString();
    }
    return '';
  }

  List<Product> getAllProducts(Map<String, dynamic> individualMembership) {
    List<Product> allProducts = [];

    individualMembership.forEach((productKey, productValue) {
      if (productValue is Map) {
        productValue.forEach((innerKey, innerValue) {
          if (innerValue is List) {
            for (var item in innerValue) {
              allProducts.add(Product(
                id: item['id'],
                productName: item['product_name'],
                lastPrice: item['last_price'],
                productFamily: item['product_family'],
                productFamilyCode: item['product_family_code'],
                productCode: item['product_code'],
                paymentType: item['payment_type'],
                minimumPrice: item['minimum_price'],
                maximumPrice: item['maximum_price'],
                customPrice: item['custom_price'],
              ));
            }
          } else if (innerValue is Map) {
            innerValue.forEach((key, value) {
              allProducts.add(Product(
                id: value['id'],
                productName: value['product_name'],
                lastPrice: value['last_price'],
                productFamily: value['product_family'],
                productFamilyCode: value['product_family_code'],
                productCode: value['product_code'],
                paymentType: value['payment_type'],
                minimumPrice: value['minimum_price'],
                maximumPrice: value['maximum_price'],
                customPrice: value['custom_price'],
              ));
            });
          }
        });
      }
    });

    return allProducts;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final addons = widget.response['data']['addons'];
    final id = widget.response['success'];
    print(id);
    print('Response addons Data: $addons');

    final Map<String, dynamic> individualMembership = widget.response['data']
            ['mb_category']['2023 LI Conference Promotion']
        ['Individual Membership'];
    var allProducts = getAllProducts(individualMembership);
    print(allProducts);

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
                                "Membership Stage",
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
                  height: screenHeight * 1.28,
                )
              ],
            ),

            Positioned(
              top: screenHeight * 0.18,
              left: (screenWidth - screenWidth * 0.92) / 2,
              right: (screenWidth - screenWidth * 0.92) / 2,
              child: Container(
                height: 300,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.grey.withOpacity(0.5), // Color of the shadow
                        offset: const Offset(1,
                            2), // Offset of the shadow [horizontal, vertical]
                        blurRadius: 4, // Spread radius of the shadow
                        spreadRadius: 2, // Extend the shadow
                      ),
                    ]),
                child: Column(
                  children: [
                    //memebrships
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 210,
                      width: 310,
                      child: ListView.separated(
                        itemCount: allProducts.length,
                        itemBuilder: (context, index) {
                          Product product = allProducts[index];

                          return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                              child: GestureDetector(
                                // Wrap the ListTile with GestureDetector to handle tap events
                                onTap: () {
                                  setState(() {
                                    selectedProductId = product.id.toString();
                                    selectedProductCode = product.productCode;
                                    selectedProductLastPrice =
                                        product.lastPrice.toString();
                                    selectedIndex = index;
                                  });
                                  print(selectedProductId);
                                  print(selectedProductCode);
                                  print(selectedProductLastPrice);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(
                                            0.5), // Color of the shadow
                                        offset: const Offset(1,
                                            2), // Offset of the shadow [horizontal, vertical]
                                        blurRadius:
                                            4, // Spread radius of the shadow
                                        spreadRadius: 2, // Extend the shadow
                                      ),
                                    ],
                                    color: index == selectedIndex
                                        ? secondbg
                                        : maingbg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      product.productName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily:
                                            AutofillHints.transactionAmount,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'EUR ${product.lastPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 15,
                                        fontFamily:
                                            AutofillHints.transactionAmount,
                                      ),
                                    ),
                                  ),
                                ),
                              ));
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              height: 2,
                              child: DottedLine(
                                alignment: WrapAlignment.center,
                                dashColor: Colors.black.withOpacity(0.5),
                                direction: Axis.horizontal,
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
            //Addons
            Positioned(
              top: screenHeight * 0.57,
              left: (screenWidth - screenWidth * 0.92) / 2,
              right: (screenWidth - screenWidth * 0.92) / 2,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        'Addons',
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
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
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
                      ],
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      height: 150,
                      child: SizedBox(
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: addons.length,
                          itemBuilder: (context, index) {
                            final addon = addons[index];
                            final quantity = quantityMap[index] ?? 0;
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            addon['product_name'],
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  if (quantity > 0) {
                                                    updateQuantity(index, -1);
                                                  }
                                                },
                                                icon: const Icon(Icons.remove),
                                                color: Colors.black,
                                              ),
                                              Text(
                                                (quantity > 0 ? quantity : 0)
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  updateQuantity(index, 1);
                                                },
                                                icon: const Icon(Icons.add),
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            "EUR ${addon['last_price']}",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Checkbox(
                                          checkColor: Colors.white,
                                          activeColor: secondbg,
                                          value: selectedRow.contains(index),
                                          onChanged: (value) {
                                            setState(() {
                                              if (value != null && value) {
                                                selectedRow.add(index);
                                              } else {
                                                selectedRow.remove(index);
                                              }

                                              updateTotalQuantity();

                                              print(
                                                  'Total Quantity: $totalQuantity');
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //Billing
            Positioned(
                top: screenHeight * 0.80,
                left: (screenWidth - screenWidth * 0.92) / 2,
                right: (screenWidth - screenWidth * 0.92) / 2,
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Billing Address',
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
                      height: 620,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Would you like to add billing details?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Will your billing & home address \nbe the same?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ToggleButtons(
                                  borderColor: Colors.black26,
                                  selectedBorderColor: secondbg,
                                  fillColor: secondbg,
                                  borderWidth: 1,
                                  selectedColor: Colors.white,
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                  constraints: const BoxConstraints(
                                    minHeight: 40.0,
                                    minWidth: 80.0,
                                  ),
                                  isSelected: [checkBoxYes, checkBoxNo],
                                  onPressed: (int index) async {
                                    setState(() {
                                      checkBoxYes = index == 0;
                                      checkBoxNo = index == 1;
                                    });

                                    if (checkBoxYes) {
                                      await loadUserData();
                                    } else {
                                      emailController.clear();
                                      addressController.clear();
                                      postalCodeController.clear();
                                      cityController.clear();
                                      mobileNumberController.clear();
                                    }
                                  },
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        'Yes',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: AutofillHints.username,
                                            fontWeight: FontWeight.bold,
                                            color: checkBoxYes
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        'No',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: AutofillHints.username,
                                            fontWeight: FontWeight.bold,
                                            color: checkBoxNo
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 33),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 2,
                                child: DottedLine(
                                  alignment: WrapAlignment.center,
                                  dashColor: Colors.black.withOpacity(0.5),
                                  direction: Axis.horizontal,
                                ),
                              ),
                            ),
                            //form
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Form(
                                      key: userKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 15),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            height: 60,
                                            child: TextFormField(
                                              enabled: !checkBoxYes,
                                              controller: emailController,
                                              decoration: const InputDecoration(
                                                labelText: 'Email',
                                                labelStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins',
                                                    color: Colors.black38,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                contentPadding: EdgeInsets.only(
                                                    left: 20,
                                                    top: 5,
                                                    bottom: 5),
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                              ),
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.040,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500),
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
                                          const SizedBox(height: 15),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            height: 60,
                                            child: TextFormField(
                                              enabled: !checkBoxYes,
                                              controller: addressController,
                                              decoration: const InputDecoration(
                                                labelText: 'Address ',
                                                labelStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins',
                                                    color: Colors.black38,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                contentPadding: EdgeInsets.only(
                                                    left: 20,
                                                    top: 5,
                                                    bottom: 5),
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                              ),
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.040,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Please enter your job title.';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    border: Border.all(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  height: 60,
                                                  child: TextFormField(
                                                    enabled: !checkBoxYes,
                                                    controller:
                                                        postalCodeController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'Postal code',
                                                      labelStyle: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: 'Poppins',
                                                          color: Colors.black38,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 20,
                                                              top: 5,
                                                              bottom: 5),
                                                      border: InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                    ),
                                                    textAlignVertical:
                                                        TextAlignVertical
                                                            .center,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.040,
                                                        fontFamily: 'Poppins',
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value
                                                              .trim()
                                                              .isEmpty) {
                                                        return 'Please enter postal code.';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    border: Border.all(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  height: 60,
                                                  child: TextFormField(
                                                    enabled: !checkBoxYes,
                                                    controller: cityController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'City',
                                                      labelStyle: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: 'Poppins',
                                                          color: Colors.black38,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 20,
                                                              top: 5,
                                                              bottom: 5),
                                                      border: InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                    ),
                                                    textAlignVertical:
                                                        TextAlignVertical
                                                            .center,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.040,
                                                        fontFamily: 'Poppins',
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value
                                                              .trim()
                                                              .isEmpty) {
                                                        return 'Please enter city.';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                      if (!countryList.any(
                                                          (title) =>
                                                              title['code_ISO']
                                                                  .toString() ==
                                                              selectedCountry)) {
                                                        selectedCountry =
                                                            countryList.first[
                                                                    'code_ISO']
                                                                .toString();
                                                      }
                                                    }

                                                    return DropdownButtonFormField<
                                                        String>(
                                                      value: selectedCountry,
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText: 'Country',
                                                        labelStyle: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Poppins',
                                                            color:
                                                                Colors.black38,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left: 20),
                                                        border:
                                                            InputBorder.none,
                                                        enabledBorder:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                      ),
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.040,
                                                          fontFamily: 'Poppins',
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      dropdownColor:
                                                          Colors.white,
                                                      items: countryList.map<
                                                          DropdownMenuItem<
                                                              String>>((title) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value:
                                                              title['code_ISO']
                                                                  .toString(),
                                                          child: Text(
                                                            title['label_eng']
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedCountry =
                                                              value;
                                                        });
                                                      },
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
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
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              Container(
                                                height: 60,
                                                width: 105,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Consumer(
                                                  builder:
                                                      (context, ref, child) {
                                                    final moCodeAsyncValue = ref
                                                        .watch(moCodeProvider);

                                                    return moCodeAsyncValue
                                                        .when(
                                                      data: (moCodeList) {
                                                        print(
                                                            'Mobile code Type Data: $moCodeList');

                                                        if (moCodeList
                                                            .isEmpty) {
                                                          selectedmobileCode =
                                                              '';
                                                        } else {
                                                          selectedmobileCode ??=
                                                              moCodeList
                                                                  .first['id']
                                                                  .toString();

                                                          if (!moCodeList.any(
                                                              (gender) =>
                                                                  gender['id']
                                                                      .toString() ==
                                                                  selectedmobileCode)) {
                                                            selectedmobileCode =
                                                                moCodeList
                                                                    .first['id']
                                                                    .toString();
                                                          }
                                                        }

                                                        return DropdownButtonFormField<
                                                            String>(
                                                          value:
                                                              selectedmobileCode,
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: '+14',
                                                            labelStyle: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Poppins',
                                                                color: Colors
                                                                    .black38,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    left: 20),
                                                            border: InputBorder
                                                                .none,
                                                            enabledBorder:
                                                                InputBorder
                                                                    .none,
                                                            focusedBorder:
                                                                InputBorder
                                                                    .none,
                                                          ),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.040,
                                                              fontFamily:
                                                                  'Poppins',
                                                              color: Colors
                                                                  .black87,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                          dropdownColor:
                                                              Colors.white,
                                                          items: moCodeList.map<
                                                                  DropdownMenuItem<
                                                                      String>>(
                                                              (moCode) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: moCode[
                                                                      'id']
                                                                  .toString(),
                                                              child: Text(moCode[
                                                                      'phonecode']
                                                                  .toString()),
                                                            );
                                                          }).toList(),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedmobileCode =
                                                                  value!;
                                                            });
                                                          },
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Please select a Phone code.';
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
                                                            'Error loading phon Code data: $error');
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    border: Border.all(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  height: 60,
                                                  child: TextFormField(
                                                    enabled: !checkBoxYes,
                                                    controller:
                                                        mobileNumberController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText:
                                                          'Mobile Number',
                                                      labelStyle: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: 'Poppins',
                                                          color: Colors.black38,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 20,
                                                              top: 5,
                                                              bottom: 5),
                                                      border: InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                    ),
                                                    textAlignVertical:
                                                        TextAlignVertical
                                                            .center,
                                                    style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.040,
                                                        fontFamily: 'Poppins',
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value
                                                              .trim()
                                                              .isEmpty) {
                                                        return 'Please enter your mobile number.';
                                                      }
                                                      return null;
                                                    },
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
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            Positioned(
              bottom: 80,
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
                  onPressed: submitSecondForm,
                  child: const Text(
                    "Next",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            //Curcles Blue
            Positioned(
              top: screenHeight * 0.336,
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
              top: screenHeight * 0.336,
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
              top: screenHeight * 1.04,
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
              top: screenHeight * 1.04,
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
