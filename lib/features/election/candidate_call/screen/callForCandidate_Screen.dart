// ignore: file_names
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:mobile_app/features/election/candidate_call/screen/appy_candidate_screen.dart';

class CallForCandidateScreen extends StatefulWidget {
  const CallForCandidateScreen({
    super.key,
    required this.candiData,
  });

  final dynamic candiData;

  @override
  State<CallForCandidateScreen> createState() => _CallForCandidateScreenState();
}

class _CallForCandidateScreenState extends State<CallForCandidateScreen> {
  @override
  Widget build(BuildContext context) {
    final data = widget.candiData;

    print('Loaded candidate call =  $data');
    int globalIndex = 0;

    data.forEach((item) {
      final index = data.indexOf(item) + 1;
      globalIndex = index;
      print('Index: $globalIndex');
    });

    print('Global index value: $globalIndex');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Call for Candidate',
          style: TextStyle(color: Colors.white),
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
              icon: const Icon(Icons.how_to_vote_rounded, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon:
                  const Icon(Icons.supervised_user_circle, color: Colors.white),
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
          borderRadius:
              BorderRadius.circular(60), // You can adjust the radius as needed
        ),
        child: const Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final callForCandidate = data[index];
                  final postionId = callForCandidate['id'];
                  final elcId = callForCandidate['election_id'];
                  final name = callForCandidate['label'];

                  return Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 20,
                            left: 70,
                            child: Container(
                              width: 260,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 35,
                            child: Container(
                              width: 280,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 300,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          callForCandidate['label'] != null &&
                                                  callForCandidate['label']
                                                      .isNotEmpty
                                              ? '${callForCandidate['label']![0].toUpperCase()}${callForCandidate['label']!.substring(1)}'
                                              : '',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 80,
                                          width: 250,
                                          child: SingleChildScrollView(
                                            child: Text(
                                              callForCandidate['guidance'] !=
                                                          null &&
                                                      callForCandidate[
                                                              'guidance']
                                                          .isNotEmpty
                                                  ? '${callForCandidate['guidance']![0].toUpperCase()}${callForCandidate['guidance']!.substring(1)}'
                                                  : '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    SizedBox(
                                      width: 170,
                                      height: 35,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          minimumSize:
                                              const Size(double.infinity, 50),
                                        ),
                                        onPressed: () {
                                          if (postionId != null &&
                                              elcId != null) {
                                            print(postionId);
                                            print(elcId);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (ctx) =>
                                                    ApplyCandidateScreen(
                                                  poId: postionId!,
                                                  electionId: elcId!,
                                                  postionName: name,
                                                ),
                                              ),
                                            );
                                          } else {
                                            print(
                                                'postionId or elcId is null.');
                                          }
                                        },
                                        child: const Text(
                                          'Apply for position',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
