import 'package:flutter/material.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';

class DetailsHome extends StatelessWidget {
  const DetailsHome({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          children: [
            //color container vertical one
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,

                    blurRadius: 10,
                    offset: const Offset(1, 3), // Offset shadow for more depth
                  ),
                ],
                color: newKMainColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              height: 200,
              width: 50,
              child: const Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'Webinars',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,

                    blurRadius: 10,
                    offset: const Offset(1, 3), // Offset shadow for more depth
                  ),
                ],
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              height: 200,
              width: screenWidth * 0.75,
              child: Column(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 8, 0),
                      child: Text(
                        'laboris nisi aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  newKMainColor, // Background color
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20), // Border radius
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'View',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        //second one
        const SizedBox(
          height: 15,
        ),
        Row(
          children: [
            //color container vertical one
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,

                    blurRadius: 10,
                    offset: const Offset(1, 3), // Offset shadow for more depth
                  ),
                ],
                color: secondbg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              height: 200,
              width: 50,
              child: const Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'Memberships',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,

                    blurRadius: 10,
                    offset: const Offset(1, 3), // Offset shadow for more depth
                  ),
                ],
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              height: 200,
              width: screenWidth * 0.75,
              child: Column(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 8, 0),
                      child: Text(
                        'laboris nisi aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondbg, // Background color
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20), // Border radius
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'View',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        //Third one
        const SizedBox(
          height: 15,
        ),
        Row(
          children: [
            //color container vertical one
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,

                    blurRadius: 10,
                    offset: const Offset(1, 3), // Offset shadow for more depth
                  ),
                ],
                color: Color.fromARGB(255, 67, 67, 67),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              height: 200,
              width: 50,
              child: const Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'Jornals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,

                    blurRadius: 10,
                    offset: const Offset(1, 3), // Offset shadow for more depth
                  ),
                ],
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              height: 200,
              width: screenWidth * 0.75,
              child: Column(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 8, 0),
                      child: Text(
                        'laboris nisi aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:const Color.fromARGB(255, 67, 67, 67), // Background color
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20), // Border radius
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'View',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        //fourth one
        const SizedBox(
          height: 15,
        ),
        Row(
          children: [
            //color container vertical one
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,

                    blurRadius: 10,
                    offset: const Offset(1, 3), // Offset shadow for more depth
                  ),
                ],
                color: const Color.fromARGB(255, 40, 7, 86),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              height: 200,
              width: 50,
              child: const Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'Blogs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,

                    blurRadius: 10,
                    offset: const Offset(1, 3), // Offset shadow for more depth
                  ),
                ],
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              height: 200,
              width: screenWidth * 0.75,
              child: Column(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 8, 0),
                      child: Text(
                        'laboris nisi aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255, 40, 7, 86), // Background color
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20), // Border radius
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'View',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
