import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/constant/base_api.dart';
import 'package:mobile_app/constant/base_img_api.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/constant/shapes/memebrship_shape.dart';
import 'package:mobile_app/features/membership/auth/provider/country.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/home/screen/home_screen.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/models/user_model.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/provider/user_data_provider.dart';
import 'package:mobile_app/features/membership/stages/widgets/stage_one_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final userUpdateKey = GlobalKey<FormState>();
  late TextEditingController firstNameController = TextEditingController();
  late TextEditingController lastNameController = TextEditingController();
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
  File? _selectedProfileImage;
  File? _selectedBackgroundImage;

  Future<void> pickProfileImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedProfileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> pickBackgroundImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedBackgroundImage = File(pickedImage.path);
      });
    }
  }

  Future<bool> updateData() async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        _showErrorDialog("User not authenticated. Please log in.");
        return false;
      }
      const String apiBaseUrl = ApiConstants.baseUrl;

      const String apiEndpoint = '$apiBaseUrl/user-profile-update';

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

      // Create a new multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiEndpoint));
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields to the request
      request.fields.addAll({
        "first_name": firstName,
        "second_name": secondName,
        "surname": lastName,
        "email": email,
        "mobile": mobile,
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
      });

      if (_selectedProfileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _selectedProfileImage!.path,
        ));
      }

      // Add background image to the request
      if (_selectedBackgroundImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'cover_image',
          _selectedBackgroundImage!.path,
        ));
      }
      // Send the request
      final response = await request.send();
      // Process the response
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 202) {
        if (mounted) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const RegisterStageWidget()));
        }
        print('Profile update successful!');
        final Map<String, dynamic> responseData = json.decode(responseString);

        // Extract image names from the server response
        String profileImageName = responseData['profile_image'] ?? '';
        String coverImageName = responseData['cover_image'] ?? '';

        // Create full URLs using the base URLs and image names
        String fullProfileImageUrl =
            ApiConstantsProfileImage.baseUrlProfile + profileImageName;
        String fullCoverImageUrl =
            ApiConstantsCoverImage.baseUrlCover + coverImageName;

        print('Full Profile Image URL: $fullProfileImageUrl');
        print('Full Cover Image URL: $fullCoverImageUrl');
        UserUpdate user = UserUpdate(
          firstName: firstName,
          secondName: secondName,
          lastName: lastName,
          email: email,
          mobile: mobile,
          country: country,
          state: state,
          title: title,
          gender: gender,
          ageRange: ageRange,
          jobCatergory: jobCategory,
          jobtitle: jobTitle,
          qualification: qualification,
          language: language,
          department: department,
          addressline1: addressline1,
          addressline3: addressline3,
          addressline2: addressline2,
          fax: fax,
          typeOfInstitution: typeInstitution,
          postalCode: postalcode,
          institiution: institution,
          coverImage: fullCoverImageUrl,
          profileImg: fullProfileImageUrl,
          nationality: nationality,
        );

        await saveUserDataLocally(user);
        _successMsg("Profile updated successfully.");
      } else {
        // Handle failure
        print('Profile update failed: ${response.statusCode}');
        print('Response body: $responseString');
        _showErrorDialog("Failed to update profile. Please try again.");
        return false;
      }
    } catch (e) {
      print('Error during profile update: $e');
      _showErrorDialog("Yoour Token is Expierd.\nPlease Relogin. ");
      return false;
    }

    return true;
  }

  Future<void> saveUserDataLocally(UserUpdate user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String userDataKey = 'user_updated_data';

      final Map<String, dynamic> userMap = user.toMap();

      // Add image and background image identifiers to the userMap
      userMap['profile_image'] =
          _selectedProfileImage?.path.split('/').last ?? '';
      userMap['cover_image'] =
          _selectedBackgroundImage?.path.split('/').last ?? '';

      // Convert Map to JSON string
      final String userJson = json.encode(userMap);

      // Save JSON string to shared preferences
      await prefs.setString(userDataKey, userJson);

      print('User data saved locally: $userJson');
    } catch (e) {
      print('Error saving user data locally: $e');
    }
  }

  //  cache directory path
  Future<String> getCacheDirectoryPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    print('Profile Image Path: ${_selectedProfileImage?.path}');
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

  Future<void> loadUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String userDataKey = 'user_data';

      final String? userJson = prefs.getString(userDataKey);

      if (userJson != null) {
        final Map<String, dynamic> userMap = json.decode(userJson);

        setState(() {
          firstNameController.text = userMap['first_name'];
          lastNameController.text = userMap['second_name'];
          emailController.text = userMap['email'];
          mobileNumberController.text = userMap['mobile'];
          selectedCountry = userMap['country'];
        });

        print('User data loaded successfully: $userMap');
      } else {
        print('No user data found in shared preferences.');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> loadImageData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String userDataKey = 'user_updated_data';

      final String? userJson = prefs.getString(userDataKey);

      if (userJson != null) {
        final Map<String, dynamic> userMap = json.decode(userJson);

        setState(() {
          loadImages(userMap['profile_image'], userMap['cover_image']);
        });

        print('User data loaded successfully: $userMap');
      } else {
        print('No user data found in shared preferences.');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> loadImages(
      String imageIdentifier, String backgroundImageIdentifier) async {
    _selectedProfileImage =
        File('${await getCacheDirectoryPath()}/$imageIdentifier');
    _selectedBackgroundImage =
        File('${await getCacheDirectoryPath()}/$backgroundImageIdentifier');
    print('Profile Image Path: ${_selectedProfileImage?.path}');
    print('Background Image Path: ${_selectedBackgroundImage?.path}');
  }

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

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadImageData();
    loadMembershipExpiryBar();
  }

  late DateTime startDate =
      DateTime.now(); // Initialize startDate with the current date and time
  late DateTime endDate = DateTime.now();

  int _calculateDaysRemaining(DateTime startDate, DateTime endDate) {
    final today = DateTime.now();
    final startDifference = today.difference(startDate).inDays;
    final endDifference = endDate.difference(today).inDays;
    return startDifference > endDifference ? startDifference : endDifference;
  }

  Color _getDaysColor(int daysRemaining) {
    if (daysRemaining <= 10) {
      return Colors.red;
    } else if (daysRemaining <= 30) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = _calculateDaysRemaining(startDate, endDate);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.phone, color: Colors.black),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.format_quote, color: Colors.black),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.rule_sharp, color: Colors.black),
                onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomeScreen(signOutCallback: () {}),
          ));
        },
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
      backgroundColor: newKBgColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  color: newKMainColor,
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 60, 0, 0),
                            child: Text(
                              "EDIT PROFILE",
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
                  height: screenHeight * 1.6,
                )
              ],
            ),
            Positioned(
              top: 220,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Form(
                key: userUpdateKey,
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
                        SizedBox(
                          height: screenHeight * 0.1,
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
                            onPressed: updateData,
                            child: const Text(
                              'Update',
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
              //Profile picture
            ),
            Positioned(
              top: screenHeight / 6,
              width: screenWidth / 1,
              child: Container(
                width: 120, // Adjust the width as needed
                height: 120, // Adjust the height as needed
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: _selectedProfileImage != null
                        ? FileImage(_selectedProfileImage!)
                        : const AssetImage(
                                'assets/images/profile/no_profile.png')
                            as ImageProvider,
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight / 3.5,
              width: screenWidth / 1,
              child: IconButton(
                onPressed: pickProfileImage,
                icon: const Icon(
                  Icons.camera_alt_rounded,
                  color: homeclr,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
