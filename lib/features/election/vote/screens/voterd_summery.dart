import 'package:flutter/material.dart';

class VotedSummeryScreen extends StatefulWidget {
  const VotedSummeryScreen({super.key, required this.data});

  final dynamic data;

  @override
  State<VotedSummeryScreen> createState() => _VotedSummeryScreenState();
}

class _VotedSummeryScreenState extends State<VotedSummeryScreen> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    print(data);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Summery ',
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
          borderRadius: BorderRadius.circular(60),
        ),
        child: const Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          height: 100.0 * data.length,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final election = data[index];
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    // Gray color container
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Positioned(
                        top: 20,
                        left: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Checkbox.adaptive(
                                  value: true,
                                  onChanged: (value) {},
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Black color container
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(
                                    election['profileImageUrl'] ??
                                        ''), // Set profile image URL
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                election['first_name'] != null &&
                                        election['first_name'].isNotEmpty
                                    ? '${election['first_name']![0].toUpperCase()}${election['first_name']!.substring(1)}'
                                    : '',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
