// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WinnerScreen extends ConsumerStatefulWidget {
  const WinnerScreen({
    super.key,
    required this.data,
  });

  final dynamic data;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends ConsumerState<WinnerScreen> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final electionName = data[0]['election'];
    final positions = data[0]['positions'];
    final type = data[0]['election_type'];

    print('Election name : $electionName');
    print('Positions : $positions');
    print('Election type : $type');

// Filter positions based on election type "Majority" and progress value >= 50%
    final majorityPositions = positions.values.where((position) =>
        position['election_type'] == ' Majority Voting' &&
        position['candidates'].any(
            (candidate) => double.parse(candidate['progressValue']) >= 50));

    print('Majority=$majorityPositions');

// Iterate through each position
    positions.forEach((positionKey, positionData) {
      // Extract position information
      final position = positionData['position'];
      final vacancy = positionData['vacancy'];
      print('Position: $position');
      print('Vacancy: $vacancy');

      // Extract and iterate through candidates
      final candidates = positionData['candidates'];
      candidates.forEach((candidate) {
        final name = candidate['name'];
        final count = candidate['count'];
        final place = candidate['place'];
        final progressColor = candidate['progressColor'];
        final progressValue = candidate['progressValue'];
        print('Candidate: $name');
        print('Count: $count');
        print('Place: $place');
        print('Progress Color: $progressColor');
        print('Progress Value: $progressValue');
      });

      print('-------------------------');
    });
    Color getBorderColor(String progressColor) {
      switch (progressColor) {
        case 'danger':
          return Colors.red;
        case 'warning':
          return Theme.of(context).colorScheme.secondary;
        case 'info':
          return Theme.of(context).colorScheme.primary;
        default:
          return Colors.green;
      }
    }

    IconData getIcon(String progressColor) {
      switch (progressColor) {
        case 'danger':
          return Icons.error;
        case 'warning':
          return Icons.warning;
        case 'info':
          return Icons.info;
        default:
          return Icons.done_all_outlined;
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Winners',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        electionName,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  // Iterate through each position and display its details
                  for (final positionKey in positions.keys) ...[
                    // Display position details
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align children to the start of the column
                        children: [
                          // Display position name and vacancy

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  30), // Adjust border radius as needed
                              border: Border.all(
                                  color: Colors.white), // Border color
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  ' ${positions[positionKey]['position']}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text('Vacancy: ${positions[positionKey]['vacancy']}',
                              style: const TextStyle(color: Colors.white)),

                          // Iterate through candidates and display their details
                          for (final candidate in positions[positionKey]
                              ['candidates']) ...[
                            // Display candidate details
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: getBorderColor(
                                      candidate['progressColor']),
                                  borderRadius: BorderRadius.circular(
                                      30), // Adjust border radius as needed
                                  border: Border.all(
                                    color: getBorderColor(
                                        candidate['progressColor']),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        children: [
                                          const Spacer(),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Icon(
                                              getIcon(
                                                  candidate['progressColor']),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Candidate: ${candidate['name']}',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text('Count: ${candidate['count']}',
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      Text('Place: ${candidate['place']}',
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: double.parse(candidate[
                                                      'progressValue']) /
                                                  100,
                                              backgroundColor: Colors.white,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.green[600]!,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Progress Value: ${candidate['progressValue']}',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const Divider(),
                          // Add a divider between positions
                        ],
                      ),
                    )
                  ],
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
