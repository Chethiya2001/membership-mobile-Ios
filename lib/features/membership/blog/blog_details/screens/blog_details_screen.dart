import 'dart:convert';
import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/constant/base_img_api.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/countact_us/screens/main_contact_us_screen.dart';
import 'package:mobile_app/features/membership/faqs/screens/main_faqs_screen.dart';
import 'package:mobile_app/features/membership/tearms&condition/screens/main_tearms_and_condition_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BlogDetailsScreen extends StatefulWidget {
  const BlogDetailsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BlogDetailsScreenState createState() => _BlogDetailsScreenState();
}

class _BlogDetailsScreenState extends State<BlogDetailsScreen> {
  late SharedPreferences prefs;
  final blogForm = GlobalKey<FormState>();
  final log = Logger();
  String? title;
  String? imageUrl;
  String? description;
  int? pageID;
  List<Map<String, dynamic>> discussionsWithStatus1 = [];
  List<Map<String, dynamic>> discussionsWithStatus0 = [];
  final commentController = TextEditingController();
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

  Future<bool> submitComment() async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        print("User not authenticated. Please log in.");
        return false;
      }

      final comment = commentController.text;
      const String apiBaseUrl = ApiConstants.baseUrl;
      const String apiEndpoint = '$apiBaseUrl/blog-comments';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(apiEndpoint),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['message'] = comment
        ..fields['reply_page_id'] = pageID.toString();

      // Validate if file is selected
      if (fileTodisplay != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', fileTodisplay!.path),
        );
      }

      var response = await request.send();
      var resBody = json.decode(await response.stream.bytesToString());

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $resBody');

      if (response.statusCode == 200) {
        try {
          print("Success add comment");
          print(resBody);

          _successMsg("Send");
        } catch (e) {
          print("Error handling: $e");
        }
      } else {
        log.e("Fails submitting");
        _showErrorDialog('Try again');
      }

      return true;
    } catch (e) {
      print(e);
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
                  color: Color.fromARGB(255, 19, 58, 150),
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    prefs = await SharedPreferences.getInstance();
    final String savedTitle =
        prefs.getString('selected_blog_title') ?? 'Default Title';
    final String savedImageUrl =
        prefs.getString('selected_blog_imageUrl') ?? 'No image';
    final String savedDescription = prefs.getString('selected_blog') ?? '';
    final int? savedPageId = prefs.getInt('selected_page_id');

    setState(() {
      title = savedTitle;
      imageUrl = savedImageUrl;
      description = savedDescription;
      pageID = savedPageId;
    });

    final List<String>? savedBlogDiscussion =
        prefs.getStringList('selected_blog_discussion');

    if (savedBlogDiscussion != null) {
      final List<Map<String, dynamic>> loadedBlogDiscussion =
          savedBlogDiscussion.map<Map<String, dynamic>>((discussion) {
        return Map<String, dynamic>.from(json.decode(discussion));
      }).toList();

      discussionsWithStatus1 = loadedBlogDiscussion
          .where((discussion) => discussion['status'] == 1)
          .toList();

      discussionsWithStatus0 = loadedBlogDiscussion
          .where((discussion) => discussion['status'] == 0)
          .toList();

      print('Discussions with status 0: $discussionsWithStatus0');
      print('Discussions with status 1: $discussionsWithStatus1');
      print('loaded Discussions: $loadedBlogDiscussion');
      print('loaded Title: $savedTitle');
      print('loaded ImageUrl: $savedImageUrl');
      print('loaded Description: $savedDescription');
      print('loaded pageID: $savedPageId');
    }
    await loadUserDataAndSetImage();
  }

  _clearData() async {
    // Clear individual keys
    prefs.remove('selected_blog_title');
    prefs.remove('selected_blog_imageUrl');
    prefs.remove('selected_blog');
    prefs.remove('selected_blog_discussion');

    // Alternatively, you can clear all data
    prefs.clear();

    setState(() {
      // Reset variables to default values
      title = 'No Title';
      imageUrl = 'No image';
      description = '';
      discussionsWithStatus1 = [];
      discussionsWithStatus0 = [];
    });

    print('Data cleared successfully');
  }

  @override
  Widget build(BuildContext context) {
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
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 16, 0, 0),
                              child: Text(
                                "Details",
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
                  height: screenHeight * 1.0,
                )
              ],
            ),

            Positioned(
              top: 160,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Container(
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 500,
                            width: double.maxFinite,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Html(
                                data: description.toString(),
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

            Positioned(
                top: screenHeight * 0.79,
                left: (screenWidth - screenWidth * 0.9) / 2,
                right: (screenWidth - screenWidth * 0.9) / 2,
                child: Container(
                  height: 300,
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          children: [
                            const Text(
                              'Verified Comments',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'Poppins'),
                            ),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                  itemCount: discussionsWithStatus1.length +
                                      discussionsWithStatus0.length,
                                  itemBuilder: (context, index) {
                                    bool isStatus1 =
                                        index < discussionsWithStatus1.length;
                                    int adjustedIndex = isStatus1
                                        ? index
                                        : index - discussionsWithStatus1.length;
                                    Map<String, dynamic> discussion = isStatus1
                                        ? discussionsWithStatus1[index]
                                        : discussionsWithStatus0[adjustedIndex];

                                    return ListTile(
                                      title: Text(discussion['discussion']),
                                      leading: isStatus1
                                          ? const Icon(
                                              Icons.verified,
                                              color: Colors.blue,
                                            )
                                          : const Icon(
                                              Icons.verified_outlined,
                                              color: Colors.grey,
                                            ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
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
          ],
        ),
      ),
    );
  }

  static String? globalImageUrl;
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
}
