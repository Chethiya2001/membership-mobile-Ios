// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_app/constant/election/election_base_api.dart';
import 'package:mobile_app/features/election/candidate_profile/screens/candidate_profile_screen.dart';
import 'package:mobile_app/features/election/vote/screens/pdf_view_candidate_screen.dart';
import 'package:mobile_app/features/election/vote/screens/voterd_summery.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelecterdElectionScreen extends ConsumerStatefulWidget {
  const SelecterdElectionScreen({
    super.key,
    required this.data,
    required this.id,
  });

  final dynamic data;
  final dynamic id;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelecterdElectionScreenState();
}

class _SelecterdElectionScreenState
    extends ConsumerState<SelecterdElectionScreen> {
  List<Map<String, dynamic>> selectedCandidates = [];
  late int positionId;
  late int electionId;
  late int candidateId;
  int? id;
  String? po;
  String? loadedMembershipId;

  Future<bool> createVote() async {
    const String baseUrl = ApiConstantsElection.baseUrl;
    String apiEndpoint = '$baseUrl/create-vote/$id';

    final token = await TokenManager.getToken();

    if (token == null) {
      print("User not authenticated. Please log in.");
      return false; // Return false as user is not authenticated
    }
    printSelectedCandidates();
    print(loadedMembershipId);

    final body = jsonEncode(
      {
        "votesData": [
          {
            "voter_id": loadedMembershipId,
            "election_id": electionId.toString(),
            "position_id": positionId.toString(),
            "candidate_id": candidateId.toString(),
            'user_role': "user"
          }
        ]
      },
    );

    try {
      final response = await http.post(Uri.parse(apiEndpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Cookie': 'access_token=$token'
          },
          body: body);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 201) {
        var resBody = json.decode(response.body);
        _successMsg(resBody['message']);
        print('Vote created successfully');
        if (mounted) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => VotedSummeryScreen(
                    data: selectedCandidates,
                  )));
        }

        return true;
      } else {
        print('Failed to create vote: ${response.statusCode}');
        _errorMsg('Already Voted.');
        // You can handle error scenarios here
        return false;
      }
    } catch (error) {
      print('Error creating vote: $error');

      return false;
      // Handle errors such as network issues or invalid response format
    }
  }
  //candidate navigate

  Future<bool> getCandidateData(int cId) async {
    const String baseUrl = ApiConstantsElection.baseUrl;
    final String apiEndpoint = '$baseUrl/get-candidate?id=$cId';

    final token = await TokenManager.getToken();

    if (token == null) {
      print("User not authenticated. Please log in.");
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
        print('candidate data = $resBody');

        print('success');

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => CandidateProfileScreen(profile: resBody)),
          );
        }
      } else {
        print('Failed to fetch election data: ${response.statusCode}');
        if (mounted) {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  ' Try another election!',
                  style: TextStyle(color: Colors.red),
                ),
                content: const Text("No data here ..."),
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
      }
      return true;
    } catch (e) {
      print('Exception during HTTP request: $e');
      return false; // or handle the exception as per your requirement
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
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _errorMsg(String successMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Text('Faild'),
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

  Future<void> initializeData() async {
    loadMembershipIdLocally().then((loadedId) {
      setState(() {
        loadedMembershipId = loadedId;
      });
      print('Loaded Membership ID in initState: $loadedId');
    });
    print('Initialized Membership ID: $loadedMembershipId');
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final elid = widget.id;
    id = elid;
    print(id);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Postions',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {}),
            IconButton(
                icon:
                    const Icon(Icons.how_to_vote_rounded, color: Colors.white),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.supervised_user_circle,
                    color: Colors.white),
                onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        hoverColor: Colors.blue,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        // Set background color to purple
        foregroundColor: Colors.white,
        splashColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(60), // You can adjust the radius as needed
        ),
        child: const Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, positionIndex) {
                      final position = data[positionIndex]['position'];

                      final candidates = data[positionIndex]['candidates'];
                      final String? document =
                          data[positionIndex]['position_File'];
                      print(document);

                      data.forEach((item) {
                        Map<String, dynamic> position = item['position'];
                        String label = position['label'];
                        int minAnswers = position['min_answ'];
                        int maxAnswers = position['max_answ'];

                        // Print out the position label and its minimum and maximum answers
                        print('Position: $label');
                        print('Minimum Answers: $minAnswers');
                        print('Maximum Answers: $maxAnswers');
                        print('-----------------------------');
                      });

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 6.0,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary, // Set card background color to yellow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  position['label'] ?? 'No Postion',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Colors.white, // Set text color to white
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: candidates.length,
                                itemBuilder: (context, candidateIndex) {
                                  final candidate = candidates[candidateIndex];
                                  final cid = candidate["id"];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(
                                            25), // Set border radius
                                      ),
                                      child: ListTile(
                                        leading: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Checkbox(
                                            //   value: selectedCandidates
                                            //       .contains(candidate),
                                            //   onChanged: (bool? value) {
                                            //     setState(() {
                                            //       if (value != null && value) {
                                            //         selectedCandidates
                                            //             .add(candidate);
                                            //       } else {
                                            //         selectedCandidates
                                            //             .remove(candidate);
                                            //       }
                                            //     });
                                            //   },
                                            // ),
                                            // Inside your ListView.builder itemBuilder for candidates
                                            Checkbox(
                                              value: selectedCandidates
                                                  .contains(candidate),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value != null && value) {
                                                    // Check if selecting this candidate exceeds the maximum allowed
                                                    if (selectedCandidates
                                                            .where((c) =>
                                                                c['position_id'] ==
                                                                position['id'])
                                                            .length <
                                                        position['max_answ']) {
                                                      selectedCandidates
                                                          .add(candidate);
                                                    } else {
                                                      // If the maximum is reached, show an error message or handle it accordingly
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title:
                                                                const Text("Warning"),
                                                            content: const Text(
                                                                "You have already selected the maximum number of candidates for this position."),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    const Text("OK"),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }
                                                  } else {
                                                    selectedCandidates
                                                        .remove(candidate);
                                                  }
                                                });
                                              },
                                            ),

                                            GestureDetector(
                                              onTap: () {
                                                getCandidateData(cid);
                                              },
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundImage: NetworkImage(
                                                  candidate['avatar'] ??
                                                      'https://uxwing.com/wp-content/themes/uxwing/download/peoples-avatars/no-profile-picture-icon.png',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        title: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${candidate['first_name']} ',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Row(
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                if (document != null) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PDFViewCandidate(
                                                              pdfUrl: document),
                                                    ),
                                                  );
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            "Sorry!"),
                                                        content: const Text(
                                                            "No document available."),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ); // Handle the case where document is null, maybe show an error message or handle it gracefully.
                                                }
                                                print('First icon tapped');
                                              },
                                              icon: const Icon(
                                                Icons.edit_document,
                                                color: Colors.white,
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
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: SizedBox(
                    width: 250,
                    height: 50, // Expand button to full width
                    child: ElevatedButton(
                      onPressed: createVote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white, // Set text color to white
                          fontSize: 16.0, // Set font size
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void printSelectedCandidates() {
    for (var candidate in selectedCandidates) {
      positionId = candidate['position_id'];
      electionId = candidate['election_id'];
      candidateId = candidate['id'];

      print(
          'Position ID: $positionId, Election ID: $electionId, Candidate ID: $candidateId');
    }
  }
}
