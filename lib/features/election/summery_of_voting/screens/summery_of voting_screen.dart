// ignore: file_names
import 'package:flutter/material.dart';
import 'package:mobile_app/features/election/vote/model/userProfile_Model.dart';

class SummeryOfVotingScreen extends StatefulWidget {
  const SummeryOfVotingScreen({super.key});

  @override
  State<SummeryOfVotingScreen> createState() => _SummeryOfVotingScreenState();
}

class _SummeryOfVotingScreenState extends State<SummeryOfVotingScreen> {
  @override
  Widget build(BuildContext context) {
    final List<ListItem> itemSecond = [
      ListItem(
        name: 'John Doe',
        profileImageUrl:
            'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg',
      ),
      ListItem(
        name: 'Anne',
        profileImageUrl:
            'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?cs=srgb&dl=pexels-andrea-piacquadio-733872.jpg&fm=jpg',
      ),
      ListItem(
        name: 'Smith',
        profileImageUrl:
            'https://static.vecteezy.com/system/resources/thumbnails/005/346/410/small/close-up-portrait-of-smiling-handsome-young-caucasian-man-face-looking-at-camera-on-isolated-light-gray-studio-background-photo.jpg',
      ),
      ListItem(
        name: 'Merry',
        profileImageUrl:
            'https://media.istockphoto.com/id/680322812/photo/portrait-of-a-beautiful-woman.jpg?s=612x612&w=0&k=20&c=KbCHvPAqX0w79SBvWgZa0ZDBjoNUmVW471biEOecN70=',
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Summery of voting',
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
              child: SizedBox(
                width: double.infinity,
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
                              const Center(
                                child: Text(
                                  'Position',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Stack(
                                      children: [
                                        // First Container
                                        Positioned(
                                          child: Container(
                                            width: 400,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  114, 0, 0, 0),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),

                                        // Second Container with Text
                                        Positioned(
                                          top:
                                              0, // Adjust top value as per your requirement
                                          left:
                                              0, // Adjust left value as per your requirement
                                          child: Container(
                                            width: 200,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'candidate 01',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Stack(
                                      children: [
                                        // First Container
                                        Positioned(
                                          child: Container(
                                            width: 400,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  const Color.fromARGB(114, 0, 0, 0),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),

                                        // Second Container with Text
                                        Positioned(
                                          top:
                                              0, // Adjust top value as per your requirement
                                          left:
                                              0, // Adjust left value as per your requirement
                                          child: Container(
                                            width: 200,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'candidate 02',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ClipPath(
                  child: Card(
                    color: Theme.of(context).colorScheme.secondary,
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
                              const Center(
                                child: Text(
                                  'Position',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: itemSecond.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Stack(
                                              children: [
                                                // First Container
                                                Positioned(
                                                  child: Container(
                                                    width: 400,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              114, 0, 0, 0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                  ),
                                                ),

                                                Positioned(
                                                  top: 0,
                                                  left: 0,
                                                  child: Container(
                                                    width: 200,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 0, 0, 0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      itemSecond[
                                                                              index]
                                                                          .profileImageUrl),
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Text(
                                                              itemSecond[index]
                                                                  .name,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16.0,
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
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
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
                              const Center(
                                child: Text(
                                  'Position',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Stack(
                                      children: [
                                        // First Container
                                        Positioned(
                                          child: Container(
                                            width: 400,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  114, 0, 0, 0),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),

                                        // Second Container with Text
                                        Positioned(
                                          top:
                                              0, // Adjust top value as per your requirement
                                          left:
                                              0, // Adjust left value as per your requirement
                                          child: Container(
                                            width: 200,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'candidate 01',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
