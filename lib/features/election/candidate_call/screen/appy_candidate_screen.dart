// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_app/constant/base_img_api.dart';
import 'package:mobile_app/constant/election/election_base_api.dart';
import 'package:mobile_app/features/membership/auth/provider/country.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';

class ApplyCandidateScreen extends ConsumerStatefulWidget {
  const ApplyCandidateScreen({
    super.key,
    required this.poId,
    required this.electionId,
    required this.postionName,
  });

  final dynamic poId;
  final dynamic electionId;
  final dynamic postionName;

  @override
  ConsumerState<ApplyCandidateScreen> createState() =>
      _ApplyCandidateScreenState();
}

class _ApplyCandidateScreenState extends ConsumerState<ApplyCandidateScreen> {
  // int _aggrementValue = 2;
  // int _activeValue = 2;
  // int _approveValue = 2;
  String? selectedCountry;
  int? postionID;
  int? elnID;
  String? uploadedFileName;
  final _applyKey = GlobalKey<FormState>();
  String? electionPostion;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController involementController = TextEditingController();
  final TextEditingController futurePlansController = TextEditingController();
  String? _presentFile;
  String? _endorsementCv;
  String? firstName;
  String? city;
  String? email;
  String? other;
  static String? profileImage;
  String? _presentFileName;
  String? _endorsementCvFileName;
  String? loadedMembershipId;

//file picking
// Function to pick present file
  Future<void> pickPresentFile() async {
    String? filePath = await pickPresentFile1();
    if (filePath != null) {
      setState(() {
        _presentFile = filePath;
        _presentFileName = _getFileNameFromPath(filePath);
      });
    }
  }

// Function to pick endorsement CV file
  Future<void> pickEndorsementCv() async {
    String? filePath = await pickEndorsementCv2();
    if (filePath != null) {
      setState(() {
        _endorsementCv = filePath;
        _endorsementCvFileName = _getFileNameFromPath(filePath);
      });
    }
  }

  Future<String?> pickPresentFile1() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      String filePath = file.path!;
      return filePath;
    }
    return null;
  }

  Future<String?> pickEndorsementCv2() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      String filePath = file.path!;
      return filePath;
    }
    return null;
  }

  // Function to extract file name from file path
  String _getFileNameFromPath(String path) {
    // Split the path using '/' as separator and get the last element
    List<String> pathParts = path.split('/');
    return pathParts.last;
  }

  //GET voteting data
  Future<bool> getVotePostionData() async {
    const String baseUrl = ApiConstantsElection.baseUrl;
    final String apiEndpoint = '$baseUrl/create-application/$postionID';

    final token = await TokenManager.getToken();

    if (token == null) {
      print("User not authenticated. Please log in.");
      return false;
    }

    final String description = descriptionController.text;
    final String involment = involementController.text;
    final String futurePlans = futurePlansController.text;
    final String country = selectedCountry ?? "";

    final body = jsonEncode(
      {
        "election_id": elnID.toString(),
        "position_id": postionID.toString(),
        "member_id": loadedMembershipId.toString(),
        "election_position": electionPostion,
        "country": country,
        "description": description,
        "involvement": involment,
        "future_plan": futurePlans,
        "agreement": "1",
        "active": "1",
        "approve": "1",
        "present_file": _presentFile,
        "endorsement_cv": _endorsementCv,
      },
    );
    print(body);

    try {
      // Make HTTP GET request
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cookie': 'access_token=$token'
        },
        body: body,
      );
      print(response.statusCode);
      print(response.body);

      // Check the response status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        var resBody = json.decode(response.body);
        print(resBody);
        _successMsg('Apply success');

        print('success');
      } else {
        print('Failed to fetch election data: ${response.statusCode}');
        _showErrorDialog("Faild Apply");
      }
      return true;
    } catch (e) {
      print('Exception during HTTP request: $e');
      return false; // or handle the exception as per your requirement
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(); // Use the file_picker plugin to pick a file
    if (result != null) {
      setState(() {
        uploadedFileName =
            result.files.single.name; // Update the uploaded file name
      });
    }
  }

  Future<void> _successMsg(String successMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                const Text('Done'),
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

// Function to load user data from local storage
  Future<void> loadUserDataLocally() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String userDataKey = 'user_data';

      // Retrieve user data JSON string from SharedPreferences
      final String? userDataJson = prefs.getString(userDataKey);

      if (userDataJson != null) {
        // Parse JSON string to Map
        final Map<String, dynamic> userDataMap = json.decode(userDataJson);

        // Set global variables with user data
        firstName = userDataMap['first_name'];

        email = userDataMap['email'];

        city = userDataMap['city'];
        other = userDataMap['job_title'];

        print('User data loaded from local storage');
        print(firstName);
        print(email);
      } else {
        print('No user data found in local storage');
      }
    } catch (e) {
      print('Error loading user data from local storage: $e');
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
          profileImage = imageUrl;
        } else {
          print('Image URL is null or not found in user data.');
        }
      } else {
        print('No user image data found locally.');
      }
    } catch (e) {
      print('Error loading user data locally: $e');
    }
  }

  ImageProvider<Object>? getImageProvider() {
    if (profileImage != null) {
      // Check if globalImageUrl is a network URL
      if (profileImage!.startsWith('http') ||
          profileImage!.startsWith('https')) {
        return NetworkImage(profileImage!);
      } else {
        // It's a local file path, construct the full URL using ApiConstantsProfileImage
        String fullImageUrl =
            ApiConstantsProfileImage.getProfileImageUrl(profileImage!);
        return NetworkImage(fullImageUrl);
      }
    } else {
      return const AssetImage('assets/images/profile/no_profile.png');
    }
  }

  Future<String> loadMembershipIdLocally() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String membershipKey = 'membership_id_validates';

      // Get membership ID from shared preferences
      final String? loadedId = prefs.getString(membershipKey);

      return loadedId ?? ''; // Return an empty string if null
    } catch (e) {
      print('Error loading membership ID locally: $e');
      return ''; // Return an empty string in case of an error
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
    loadUserDataLocally();
  }

  Future<void> initializeData() async {
    await loadUserDataAndSetImage();
    loadMembershipIdLocally().then((loadedId) {
      setState(() {
        loadedMembershipId = loadedId;
      });
      print('Loaded Membership ID in initState: $loadedId');
    });
    print('Initialized Membership ID: $loadedMembershipId');
  }

  @override
  Widget build(BuildContext context) {
    final pid = widget.poId;
    final eId = widget.electionId;
    final nameOfPostion = widget.postionName;
    // Check if pid and eId are not null before assigning them to postionID and elnID
    if (pid != null && eId != null) {
      postionID = pid;
      elnID = eId;
    }
    electionPostion = nameOfPostion;

    print('Position id:$postionID');
    print('Election id: $elnID');
    print('Postion Name: $electionPostion');

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Call for Candidate Apply',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromARGB(255, 33, 29, 29),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon:
                    const Icon(Icons.how_to_vote_rounded, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.supervised_user_circle,
                    color: Colors.white),
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
          child: Column(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      height: 380,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircleAvatar(
                              backgroundImage: getImageProvider(),
                              radius: 60,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            firstName ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            email ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            other ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            city ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 310,
                    left: 15.9,
                    child: Container(
                      width: 380,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: const Row(children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Enter your data",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ]),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 41,
                child: Container(
                  width: 380,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                          key: _applyKey,
                          child: Column(
                            children: [
                              Container(
                                height: 60,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.grey.shade100, // Background color
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Border radius
                                  border: Border.all(
                                    color: Colors.grey.shade300, // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                child: Center(
                                    child: TextFormField(
                                  initialValue: nameOfPostion,
                                  enabled:
                                      false, // Set to false to make it read-only
                                  decoration: const InputDecoration(
                                    hintText: 'Election Position',
                                    border: InputBorder
                                        .none, // Remove the default border
                                    // Suffix icon
                                  ),
                                )),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 60,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.grey.shade100, // Background color
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Border radius
                                  border: Border.all(
                                    color: Colors.grey.shade300, // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                child: Center(
                                  child: TextFormField(
                                    controller: descriptionController,
                                    decoration: const InputDecoration(
                                      hintText: 'Description',
                                      border: InputBorder
                                          .none, // Remove the default border
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 60,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.grey.shade100, // Background color
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Border radius
                                  border: Border.all(
                                    color: Colors.grey.shade300, // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                child: Center(
                                  child: TextFormField(
                                    controller: involementController,
                                    decoration: const InputDecoration(
                                      hintText: 'Involement',
                                      border: InputBorder
                                          .none, // Remove the default border

                                      // Suffix icon
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 60,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.grey.shade100, // Background color
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Border radius
                                  border: Border.all(
                                    color: Colors.grey.shade300, // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                child: Center(
                                  child: TextFormField(
                                    controller: futurePlansController,
                                    decoration: const InputDecoration(
                                      hintText: 'Future Plans',
                                      border: InputBorder
                                          .none, // Remove the default border
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 60,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.grey.shade100, // Background color
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Border radius
                                  border: Border.all(
                                    color: Colors.grey.shade300, // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                child: Center(
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final countriesAsyncValue =
                                          ref.watch(countryProvider);

                                      return countriesAsyncValue.when(
                                        data: (countryList) {
                                          print('Country Data: $countryList');

                                          return DropdownButtonFormField<
                                              String>(
                                            value: selectedCountry,
                                            decoration: const InputDecoration(
                                              labelText: 'Select Country',
                                              labelStyle: TextStyle(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.5),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.only(left: 20),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                            ),
                                            style: const TextStyle(
                                                color: Colors.black),
                                            items: countryList
                                                .map<DropdownMenuItem<String>>(
                                                    (country) {
                                              return DropdownMenuItem<String>(
                                                value: country['code_ISO']
                                                    .toString(),
                                                child: Text(country['label_eng']
                                                    .toString()),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedCountry = value;
                                              });
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please select a country.';
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
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text('Present File'),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons
                                          .attach_file), // Icon button for file upload
                                      onPressed: pickPresentFile,
                                    ),
                                    const SizedBox(
                                        width:
                                            10), // Add spacing between icon button and file name text
                                    Expanded(
                                      child: Text(
                                        _presentFileName ??
                                            'No file selected', // Display the file name here, or 'No file selected' if no file is selected
                                        overflow: TextOverflow
                                            .ellipsis, // Handle long file names
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text('Endosement Cv File'),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons
                                          .attach_file), // Icon button for file upload
                                      onPressed: pickEndorsementCv,
                                    ),
                                    const SizedBox(
                                        width:
                                            10), // Add spacing between icon button and file name text
                                    Expanded(
                                      child: Text(
                                        _endorsementCvFileName ??
                                            'No file selected', // Display the file name here
                                        overflow: TextOverflow
                                            .ellipsis, // Handle long file names
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Center(
                                child: SizedBox(
                                  width: 400,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: getVotePostionData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary, // Change the background color
                                    ),
                                    child: const Text(
                                      'Submit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
