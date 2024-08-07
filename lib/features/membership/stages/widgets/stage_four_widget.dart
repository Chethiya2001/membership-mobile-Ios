// ignore_for_file: public_member_api_docs, sort_constructors_first, deprecated_member_use
import 'dart:convert';
import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mobile_app/constant/base_img_api.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/countact_us/screens/main_contact_us_screen.dart';
import 'package:mobile_app/features/membership/faqs/screens/main_faqs_screen.dart';
import 'package:mobile_app/features/membership/home/screen/home_screen.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:mobile_app/features/membership/tearms&condition/screens/main_tearms_and_condition_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/stages/data/payment_dummy.dart';
import 'package:mobile_app/features/membership/stages/models/payment_model.dart';

class PaymentWidget extends StatefulWidget {
  const PaymentWidget({
    super.key,
    // required this.id,
    required this.data,
  });

  // final dynamic id;
  final dynamic data;

  @override
  State<PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  List<TableDataModel> data = getDummyData();
  final paymentForm = GlobalKey<FormState>();
  final commentController = TextEditingController();
  final coponController = TextEditingController();
  List<TextEditingController> replyControllers = [];
  final log = Logger();
  bool showReplyForm = false;
  String? displayComment;
  //String? globalAmount;
  String? globalEnvID;
  bool _isPaymentInProgress = false;
  static String? globalImageUrl;

  int total = 0;

  Map<String, dynamic>? paymentIntent;

  void makePayment() async {
    setState(() {
      _isPaymentInProgress = true;
    });

    try {
      paymentIntent = await createPaymentIntent();
      if (paymentIntent != null && paymentIntent!['client_secret'] != null) {
        var gpay = const PaymentSheetGooglePay(
          merchantCountryCode: "US",
          currencyCode: "US",
          testEnv: true,
        );
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            style: ThemeMode.system,
            merchantDisplayName: '$globalEnvID',
            googlePay: gpay,
            customerId: globalEnvID,
            primaryButtonLabel: 'EUR $total',
          ),
        );
        await displayPaymentSheet();
      } else {}
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      setState(() {
        _isPaymentInProgress = false;
      });
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      
      _successMsg('Payment Done.');

    } catch (e) {
      print('Failed');
    }
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
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => HomeScreen(
                    signOutCallback: () {},
                  ),
                ));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> createPaymentIntent() async {
    try {
      Map<String, dynamic> body = {
        'amount': total.toString(),
        'currency': 'eur',
      };

      String stripeSecretKey =
          'sk_test_51PYPgaFzqpP2yZB2Y12PpwlPXnMwF78roHl5o38kI4CScQDTHHwjZfMsa1j8R1fXTfcLEvkTxc1QpxxYusXVyp2P00XPN6XuS0';
      print(
          'Using Stripe Secret Key: $stripeSecretKey'); // Log the key being used

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-type': 'application/x-www-form-urlencoded',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      print('Error creating payment intent: ${e.toString()}');
      throw Exception(e.toString());
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

  //loaded data///
  int? loadedInvoiceId;
  int? loadDueAmount;
  int? loadDiscountAmount;
  int? loadMemebrshipID;
  int? loadReferenceID;
  String? userName;
  String? userEmail;

  // Variables to store extracted values
  List<String> itemNames = [];
  List<int> quantities = [];
  List<double> amounts = [];
  List<String> priceBookNames = [];

  //file upload
  FilePickerResult? result;
  String? fileName;
  PlatformFile? pickedFile;
  bool isLoding = false;
  File? fileTodisplay;

  void pickFile() async {
    try {
      setState(() {
        isLoding = true;
      });

      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null) {
        fileName = result!.files.first.name;
        pickedFile = result!.files.first;
        fileTodisplay = File(pickedFile!.path.toString());

        print('File name $fileName');
        print('File path ${fileTodisplay?.path}');
      }
      setState(() {
        isLoding = false;
      });
    } catch (e) {
      log.e(e);
    }
  }

//subit 4th form
  Future<bool> submitForthForm() async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        print("User not authenticated. Please log in.");
        return false;
      }

      const String apiBaseUrl = ApiConstants.baseUrl;
      const String apiEndpoint = '$apiBaseUrl/user-membership-4th-form-update';

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "id": loadedInvoiceId,
        }),
      );
      print(loadedInvoiceId);

      var resBody = response.body;
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $resBody');
      if (response.statusCode == 200) {
        var decodedBody = json.decode(resBody);
        log.d("Submit Successfully");

        print(decodedBody);

        // Extract amount and currency from invoice_data
        var invoiceData = decodedBody['invoice_data'];

        if (invoiceData != null && invoiceData.containsKey('amount')) {
          String amountString = invoiceData['amount'].toString();
          String envid = invoiceData['invoice_id'].toString();

          // Set the amount to a global variable
          total = amountString as int;
          globalEnvID = envid;

          print('Amount: $total, id = $globalEnvID');
        } else {
          print("Response does not contain amount.");
          return false;
        }
      } else {
        print("Failed with status code: ${response.statusCode}");
        return false;
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> loadInvoiceIdLocally() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String invoiceKey = 'membership_invoice';

      // Load invoice data from shared preferences
      String? invoiceJson = prefs.getString(invoiceKey);

      if (invoiceJson != null) {
        // Parse the JSON string to get the invoice data as a Map
        Map<String, dynamic> invoice = json.decode(invoiceJson);

        // Get and set the invoice ID
        int? invoiceId = invoice['id'];
        int? dueAmount = invoice['due_amount'];
        int? discoutAmount = invoice['discount_amount'];
        int? memebrshipId = invoice['membership_id'];
        int? referenceId = invoice['reference'];
        if (invoiceId != null) {
          print('Loaded Invoice ID: $invoiceId');
          log.d('Due Amount:$dueAmount Discount Amount:$discoutAmount \n');

          setState(() {
            loadedInvoiceId = invoiceId;
            loadDueAmount = dueAmount;
            loadDiscountAmount = discoutAmount;
            loadMemebrshipID = memebrshipId;
            loadReferenceID = referenceId;
          });

          // Return true if the update is successful
          return true;
        }
      }
    } catch (e) {
      print('Error loading invoice locally: $e');
    }

    // Return false if the update is unsuccessful
    return false;
  }

  Future<bool> submitComment() async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        print("User not authenticated. Please log in.");
        return false;
      }

      final comment = commentController.text;
      const String apiBaseUrl = ApiConstants.baseUrl;
      const String apiEndpoint = '$apiBaseUrl/user-membership-add-comment';

      // Validate if file is selected
      if (fileTodisplay == null) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Please upload a document.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
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

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(apiEndpoint),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['comment'] = comment
        ..fields['reference_id'] = loadedInvoiceId.toString()
        ..fields['user_id'] = loadMemebrshipID.toString();

      request.files.add(
        await http.MultipartFile.fromPath('file', fileTodisplay!.path),
      );

      var response = await request.send();
      var resBody = json.decode(await response.stream.bytesToString());

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $resBody');

      if (response.statusCode == 200) {
        try {
          print("Success add comment");
          print(resBody);

          String commentValue = resBody["comment"];

          // Save the comment locally
          await saveCommentLocally(commentValue);
        } catch (e) {
          print("Error handling: $e");
        }
      } else {
        log.e("Fails submitting");
      }

      return true;
    } catch (e) {
      print(e);
      return false;
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

// save cmnt locally
  Future<void> saveCommentLocally(String comment) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String commentKey = 'comment';

      // Save comment to shared preferences
      await prefs.setString(commentKey, comment);

      print('Comment saved locally: $comment');
    } catch (e) {
      print('Error saving comment locally: $e');
    }
  }

  Future<String?> loadCommentLocally() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String commentKey = 'comment';

      // Load comment from shared preferences
      String? comment = prefs.getString(commentKey);

      if (comment != null) {
        setState(() {
          displayComment = comment;
        });
        print('Comment loaded locally: $comment');
      } else {
        print('Comment is null or empty');
      }

      return comment;
    } catch (e) {
      print('Error loading comment locally: $e');
      return null;
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

  @override
  void initState() {
    super.initState();
    loadInvoiceIdLocally();
    loadInvoiceSummery();
    loadCommentLocally();
    makePayment();
    initializeData();
  }

  Future<void> initializeData() async {
    await loadUserDataAndSetImage();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final aData = widget.data;
    print("Data:${aData}");
    if (aData != null && aData.containsKey('success')) {
      var successData = aData['success'];
      if (successData.containsKey('billing_address_list')) {
        var billingAddressList = successData['billing_address_list'];

        if (billingAddressList is List && billingAddressList.isNotEmpty) {
          var firstAddress = billingAddressList[0];

          // Extracting the email
          var email = firstAddress['email'];
          print("Email: $email");

          // Assuming first name is part of the address or some other key, you would access it similarly
          var city = firstAddress[
              'city']; // Replace 'first_name' with the correct key if it exists
          print("First Name: $city");

          setState(() {
            userEmail = email;
            userName = city;
          });
        }
      }
    }
    int totalAmount = loadDueAmount! + loadDiscountAmount!;
    // print("-----------------------------");
    // print("Total Amount: $totalAmount");
    // print("-----------------------------");
    setState(() {
      total = totalAmount;
    });
    print(total);

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
                              padding: EdgeInsets.fromLTRB(8, 16, 0, 0),
                              child: Text(
                                "Payment",
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
                  height: screenHeight * 1.16,
                )
              ],
            ),

            Positioned(
              top: 160,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Container(
                height: screenHeight * 0.41,
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
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: getImageProvider(),
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userEmail ?? '',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(
                                height: 1,
                              ),
                              Text(
                                userName ?? '',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 20, 16, 8),
                            child: DottedLine(
                              alignment: WrapAlignment.center,
                              dashColor: Colors.black.withOpacity(0.5),
                              direction: Axis.horizontal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 22, 16, 1),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  "User",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      color: Colors.black),
                                ),
                                SvgPicture.asset(
                                  "assets/Arrow 4.svg",
                                  width: 40,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/Group 2140.svg',
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ),
                                SvgPicture.asset(
                                  "assets/Arrow 4.svg",
                                  width: 40,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                                const Text(
                                  "Member",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 36, 0),
                      child: Row(
                        children: [
                          Text(
                            'From',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'To',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: itemNames.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0.8),
                              child: Container(
                                width: 250,
                                height: 200,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              120, 8, 0, 8),
                                          child: SvgPicture.asset(
                                            'assets/icon _calendar_.svg',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(itemNames[index],
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                          Text('Quantity: ${quantities[index]}',
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                          Text('Amount: \$${amounts[index]}',
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                          Text(priceBookNames[index],
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
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
            //Addons
            Positioned(
              top: screenHeight * 0.63,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        'Discounts',
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
                  Row(
                    children: [
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
                            bottomLeft: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                        ),
                        height: 200,
                        width: 50,
                        child: const Center(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              'Coupon Code',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
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
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        height: 200,
                        width: screenWidth * 0.75,
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 8, 0),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        height: 60,
                                        child: TextFormField(
                                          controller: coponController,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.only(
                                                left: 20, top: 5, bottom: 5),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            labelText: 'Enter Coupon',
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
                                          keyboardType:
                                              TextInputType.emailAddress,
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
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 150,
                                            height: 80,
                                            child: Text(
                                              "Can Access to Discount Please Enter Your Code.",
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black45),
                                            ),
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: newKMainColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            onPressed: () {
                                              _successMsg("Added Successful.");
                                            },
                                            child: const Text(
                                              'Reedem',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
                top: screenHeight * 0.98,
                left: (screenWidth - screenWidth * 0.9) / 2,
                right: (screenWidth - screenWidth * 0.9) / 2,
                child: Container(
                  height: 100,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
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
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(22.0),
                        child: Text(
                          'Total',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Poppins'),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Text(
                          'EUR $totalAmount',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'Poppins'),
                        ),
                      ),
                    ],
                  ),
                )),
            //comment section
            Positioned(
                top: screenHeight * 1.16,
                left: (screenWidth - screenWidth * 0.9) / 2,
                right: (screenWidth - screenWidth * 0.9) / 2,
                child: Container(
                  height: 230,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black54),
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
                    padding: const EdgeInsets.all(16.0),
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
                            Text('$userEmail'),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            SizedBox(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.1),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 60,
                                child: TextFormField(
                                  controller: commentController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        left: 20, top: 5, bottom: 5),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    labelText: 'Enter Your Comment Here..',
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
                                  maxLines: 5,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a comment.';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              child: IconButton(
                                onPressed: pickFile,
                                icon: const Icon(
                                  Icons.upload_file_outlined,
                                  size: 30,
                                ),
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 110,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: newKMainColor, // text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () async {
                                  await submitComment();
                                  // await loadCommentLocally();
                                },
                                child: const Text(
                                  'Send',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )),
            Positioned(
              bottom: 80,
              left: (screenWidth - screenWidth * 0.92) / 2,
              right: (screenWidth - screenWidth * 0.92) / 2,
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: () {
                    submitForthForm();
                    makePayment();
                  },
                  child: const Text(
                    "Pay",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            //Curcles Blue
            Positioned(
              top: 243,
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
              top: 243,
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
