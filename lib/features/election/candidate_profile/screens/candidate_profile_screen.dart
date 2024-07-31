// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({
    super.key,
    required this.profile,
  });

  final dynamic profile;

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final data = widget.profile;
    final election = widget.profile['Election'];
    final position = widget.profile['Position'];
    print('GET = $data');
    print('GET = $election');
    print('GET = $position');

    String? title = position['title'];
    String titleText = title ?? 'No position available';

    String? etitle = election['title'];
    String etitleText = etitle ?? 'No election available';

    final status = data['status'];
    Color iconColor = status ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Profile',
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(data['avatar'] ??
                        const AssetImage(
                            'assets/images/profile/no_profile.png')), // Set profile image URL
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                data['first_name'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      data['last_name'],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      data['email'],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      data['country'],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    "Verification",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(
                    Icons
                        .verified_user_rounded, // Replace 'verification_icon' with your icon
                    color: iconColor,
                    size: 40,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            30), 
                        border: Border.all(
                            color: Colors.white), 
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              titleText,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 05,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 220,
                child: ClipPath(
                  child: Card(
                    color: Theme.of(context).colorScheme.primary,
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                etitleText,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 20),
                              // const SizedBox(
                              //   width: 270,
                              //   height: 100,
                              //   child: SingleChildScrollView(
                              //     scrollDirection: Axis.vertical,
                              //     child: Text(
                              //       'Go forward until higher courts rule on Trump’s claim that he enjoys blanket immunityGo forward until higher courts rule on Trump’s claim that he enjoys blanket immunity,Go forward until higher courts rule on Trump’s claim that he enjoys blanket immunity',
                              //       style: TextStyle(
                              //           fontSize: 14,
                              //           fontWeight: FontWeight.w400,
                              //           color: Colors.white),
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(height: 20),
                            ],
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
                              color: const Color.fromARGB(255, 0, 0, 0),
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
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
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
                                      print('First icon tapped');
                                    },
                                    child: const Icon(
                                      Icons.access_alarms_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Handle second icon tap here
                                      print('Second icon tapped');
                                    },
                                    child: const Icon(
                                      Icons.people,
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
            ),
          ],
        ),
      ),
    );
  }
}
