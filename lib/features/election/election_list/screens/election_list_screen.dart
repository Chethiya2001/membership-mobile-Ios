// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/constant/election/election_base_api.dart';
import 'package:mobile_app/features/election/candidate_call/screen/callForCandidate_Screen.dart';
import 'package:mobile_app/features/election/election_list/screens/pdf_view_screen.dart';
import 'package:mobile_app/features/election/not_election_view_summery/screen/winner_screen.dart';
import 'package:mobile_app/features/election/vote/screens/main_selecterd_election_screen.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ElectionListScreen extends ConsumerStatefulWidget {
  const ElectionListScreen({
    super.key,
    required this.data,
  });

  final dynamic data;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ElectionListScreenState();
}

class _ElectionListScreenState extends ConsumerState<ElectionListScreen> {
  @override
  Widget build(BuildContext context) {
    String? calenderShowMonth = '';
    String? calenderShowdate = '';
    int? orgId;
    final currentTime = DateTime.now();

    Future<void> downloadFile(String fileUrl) async {
      try {
        final response = await http.get(Uri.parse(fileUrl));
        if (response.statusCode == 200) {
          final Directory? directory = await getExternalStorageDirectory();
          if (directory == null) {
            throw Exception('External storage directory not found');
          }
          final String filePath = '${directory.path}/election.pdf';
          final File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          AlertDialog(
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
            content: const Text('Download Success.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );

          print('File downloaded to: $filePath');
        } else {
          AlertDialog(
            title: const Center(
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_sharp,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10),
                  Text('Success'),
                ],
              ),
            ),
            content: const Text('Download faild.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
          throw Exception('Failed to download file');
        }
      } catch (e) {
        print('Error downloading file: $e');
      }
    }

    final data = widget.data;
    print("Success geting data - $data");

    //call for candidate GET
    Future<bool> getCallForCandidateData(int electionId) async {
      const String baseUrl = ApiConstantsElection.baseUrl;
      final String apiEndpoint = '$baseUrl/get-position/$electionId';

      final token = await TokenManager.getToken();

      if (token == null) {
        print("User not authenticated. Please log in.");
        return false;
      }
      final eid = electionId;

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
        print('Response body : ${response.body}');

        // Check the response status code
        if (response.statusCode == 200) {
          var resBody = json.decode(response.body);
          print(resBody);

          print('success');

          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) => CallForCandidateScreen(candiData: resBody)),
            );
          }
        } else if (response.statusCode == 204) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('No data'),
                  content: const Text('Please try again'),
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
        } else {
          print('Failed to fetch election data: ${response.statusCode}');

          // or handle the error as per your requirement
        }
        return true;
      } catch (e) {
        print('Exception during HTTP request: $e');
        return false; // or handle the exception as per your requirement
      }
    }

    //GET voteting data
    Future<bool> getVotePostionData(int electionId) async {
      const String baseUrl = ApiConstantsElection.baseUrl;
      final String apiEndpoint = '$baseUrl/get-candidates/$electionId';

      final token = await TokenManager.getToken();

      if (token == null) {
        print("User not authenticated. Please log in.");
        return false;
      }
      final eid = electionId;

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
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) => SelecterdElectionScreen(
                        data: resBody,
                        id: eid,
                      )),
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
        return false;
      }
    }

    //winner GET
    Future<bool> getWinnerData(int electionId) async {
      const String baseUrl = ApiConstantsElection.baseUrl;
      final String apiEndpoint = '$baseUrl/get-winner?election_id=$electionId';

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
        print('Response body : ${response.body}');

        // Check the response status code
        if (response.statusCode == 200) {
          var resBody = json.decode(response.body);
          print(resBody);

          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => WinnerScreen(
                    data: resBody,
                  )));

          print('success');
        } else {
          print('Failed to fetch election data: ${response.statusCode}');

          // or handle the error as per your requirement
        }
        return true;
      } catch (e) {
        print('Exception during HTTP request: $e');
        return false; // or handle the exception as per your requirement
      }
    }

    Future<void> successMsg(String successMessage) async {
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Election List',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
            color: Colors.white), // Change color of back button
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 620,
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final election = data[index];
                      final bool callForCandidate = election['call_candidate'];
                      final bool callForVote = election['call_vote'];
                      final int organizationId = election['organisation_id'];

                      orgId = organizationId;

                      // Get the election ID
                      final int electionId = election['id'];

                      final String? document = election['document'];

                      //verifications

                      final String voteStartVarification =
                          election['vote_start'];
                      final String voteEndVarification = election['vote_end'];
                      // Convert voteStartVarification and voteEndVarification to DateTime objects
                      DateTime voteEndTime =
                          DateTime.parse(voteEndVarification);

                      // Check if the current time is after the end time of the voting period
                      bool hasVotingExpired =
                          currentTime.isAfter(voteEndTime);

                      // Print whether the voting has expired or not
                      print(
                          "Voting call has ${hasVotingExpired ? 'expired' : 'not expired'}.");

                      //vote start end dates candidate
                      // final String candidateValidStartDate =
                      //     election['start_date'];
                      final String candidateValidEndDate = election['end_date'];
                      DateTime candidateEndTime =
                          DateTime.parse(candidateValidEndDate);
                      bool hasCandidateCallExpired =
                          currentTime.isAfter(candidateEndTime);
                      // print(
                      //     "Cnadidated call has ${has_candidate_call_expired ? 'expired' : 'not expired'}.");

                      // showdate hide date
                      final String showDate = election['show_date'];
                      final String hideDate = election['hide_date'];

                      DateTime dateEndTime = DateTime.parse(hideDate);

                      // Check if the current time is after the end time of the voting period
                      bool showDateExpired =
                          currentTime.isAfter(dateEndTime);

                      // Print whether the voting has expired or not
                      print(
                          "Date has ${showDateExpired ? 'expired' : 'not expired'}.");

                      final Color cardColor = callForCandidate
                          ? Theme.of(context).colorScheme.secondary
                          : callForVote
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white;

                      //button widget

                      Widget buildButtonWidgets(
                        BuildContext context,
                        bool callForCandidate,
                        bool callForVote,
                        int electionId,
                        bool hasVotingExpired,
                        bool hasCandidateExpired,
                      ) {
                        if (callForCandidate &&
                            callForVote &&
                            !hasCandidateCallExpired &&
                            !hasVotingExpired) {
                          return Column(
                            children: [
                              const SizedBox(
                                height: 1,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  getCallForCandidateData(electionId);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Call for Candidate',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  FutureBuilder(
                                    future: getVotePostionData(electionId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else {
                                        if (snapshot.hasError) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Error'),
                                                  content: const Text(
                                                      'Please try again'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          });
                                          return Container();
                                        } else {
                                          if (snapshot.data == true) {
                                            getVotePostionData(electionId);
                                          }
                                          return Container();
                                        }
                                      }
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Call for Vote',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        //
                        else if (callForCandidate &&
                            !hasCandidateCallExpired) {
                          return ElevatedButton(
                            onPressed: () {
                              getCallForCandidateData(electionId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              'Call for Candidate',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                        //
                        else if (callForVote && !hasVotingExpired) {
                          return ElevatedButton(
                            onPressed: () async {
                              FutureBuilder(
                                future: getVotePostionData(electionId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    if (snapshot.hasError) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Error'),
                                              content: const Text(
                                                  'Please try again'),
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
                                      });
                                      return Container();
                                    } else {
                                      if (snapshot.data == true) {
                                        getVotePostionData(electionId);
                                      }
                                      return Container();
                                    }
                                  }
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              'Call for Vote',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        } else {
                          return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              onPressed: () {
                                getWinnerData(electionId);
                              },
                              child: const Text(
                                'Results',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ));
                        }
                      }

                      //vote start end dates
                      final String voteStartDate = election['start_date'];
                      final String voteEndDate = election['end_date'];

                      final DateFormat formatter =
                          DateFormat('yyyy-MM-dd HH:mm:ss');

// Parse the string date into DateTime objects
                      final DateTime startDate = DateTime.parse(voteStartDate);
                      final DateTime endDate = DateTime.parse(voteEndDate);

// Format the DateTime objects into strings
                      final String formattedStartDate =
                          formatter.format(startDate);
                      final String formattedEndDate = formatter.format(endDate);

                      String getMonthName(int month) {
                        switch (month) {
                          case 1:
                            return 'JAN';
                          case 2:
                            return 'FEB';
                          case 3:
                            return 'MAR';
                          case 4:
                            return 'APR';
                          case 5:
                            return 'MAY';
                          case 6:
                            return 'JUN';
                          case 7:
                            return 'JUL';
                          case 8:
                            return 'AUG';
                          case 9:
                            return 'SEP';
                          case 10:
                            return 'OCT';
                          case 11:
                            return 'NOV';
                          case 12:
                            return 'DEC';
                          default:
                            return '';
                        }
                      }

                      final String date = election['vote_end'];
                      final String datePart = date.split('T')[0];
                      final List<String> dateParts = datePart.split('-');

                      if (dateParts.length >= 3) {
                        final String year = dateParts[0];
                        final int month = int.parse(dateParts[1]);
                        final String monthName = getMonthName(month);
                        final String day = dateParts[2];

                        calenderShowMonth = monthName;
                        calenderShowdate = day;

                        print('Year: $year'); // This will print the year part
                        print(
                            'Month: $calenderShowMonth'); // This will print the month name part
                        print(
                            'Day: $calenderShowdate'); // This will print the day part
                      } else {
                        print('Invalid date format');
                      }
                      if (showDateExpired) {
                        return Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${election['title']} dates are expired.',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 350,
                          child: ClipPath(
                            child: Card(
                              color: cardColor, // Set card color dynamically
                              elevation: 4,
                              shape: const RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            election['title'] != null &&
                                                    election['title'].isNotEmpty
                                                ? '${election['title']![0].toUpperCase()}${election['title']!.substring(1)}'
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: 200,
                                            height: 70,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Text(
                                                election['welcome_text'] !=
                                                            null &&
                                                        election[
                                                                'welcome_text']!
                                                            .isNotEmpty
                                                    ? '${election['welcome_text']![0].toUpperCase()}${election['welcome_text']!.substring(1)}'
                                                    : '',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: double.infinity,
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Election start Date - $formattedStartDate",
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Election end Date - $formattedEndDate",
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 2,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          SizedBox(
                                            width: 230,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: buildButtonWidgets(
                                                  context,
                                                  callForCandidate,
                                                  callForVote,
                                                  electionId,
                                                  hasVotingExpired,
                                                  hasCandidateCallExpired),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      child: Container(
                                        width: 70,
                                        height: 102,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 14,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 50,
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(5),
                                                    topRight:
                                                        Radius.circular(5),
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 4.0),
                                                child: Center(
                                                  child: Text(
                                                    '$calenderShowMonth',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 50,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(5),
                                                    bottomRight:
                                                        Radius.circular(5),
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 3.0),
                                                child: Center(
                                                  child: Text(
                                                    '$calenderShowdate', // Month
                                                    style: const TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      width: 50,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                          color: Colors.white,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                // Handle first icon tap here
                                                if (document != null) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PdfViewerScreen(
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
                                              child: const Icon(
                                                Icons.file_copy_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                if (document != null) {
                                                  final List<dynamic>
                                                      documents =
                                                      json.decode(document);
                                                  for (final item
                                                      in documents) {
                                                    final String fileUrl =
                                                        item['file'];
                                                    try {
                                                      await downloadFile(
                                                          fileUrl);
                                                    } catch (e) {
                                                      print(
                                                          'Error downloading file: $e');
                                                    }
                                                  }
                                                }
                                              },
                                              child: const Icon(
                                                Icons.download,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
