import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/countact_us/screens/main_contact_us_screen.dart';
import 'package:mobile_app/features/membership/faqs/screens/main_faqs_screen.dart';
import 'package:mobile_app/features/membership/fees&Join/providers/fees_provider.dart';
import 'package:mobile_app/features/membership/fees&Join/widgets/packageItems_widget.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:mobile_app/features/membership/tearms&condition/screens/main_tearms_and_condition_screen.dart';

class FeesAnfJoiningScreen extends ConsumerStatefulWidget {
  const FeesAnfJoiningScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FeesAnfJoiningScreenState();
}

class _FeesAnfJoiningScreenState extends ConsumerState<FeesAnfJoiningScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final feesData = ref.watch(feesProvider);
    return Scaffold(
      backgroundColor: newKBgColor,
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
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ListDrawer(),
                  ));
                }),
            IconButton(
                icon: const Icon(Icons.phone, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ContactUsScreen(),
                  ));
                }),
            IconButton(
                icon: const Icon(Icons.format_quote, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const FaqsScreen(),
                  ));
                }),
            IconButton(
                icon: const Icon(Icons.rule_sharp, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const TearmsAndConditionScreen(),
                  ));
                }),
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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  color: newKMainColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Back button

                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_rounded,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(8, 16, 0, 0),
                              child: Text(
                                "Price &\nPlans",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Adamina',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 50, left: 1),
                              child:
                                  SvgPicture.asset('assets/contactUs-Svg.svg'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.50,
                )
              ],
            ),

            Positioned(
              top: 160,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Container(
                height: 550,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 500,
                      child: feesData.when(
                        data: (data) {
                          final packages = data['success']['packages-details']
                              as List<dynamic>;
                          return ListView.builder(
                            itemCount: packages.length,
                            itemBuilder: (context, index) {
                              final package = packages[index];
                              final clr = getColor(index);
                              return PackageItem(
                                package: package,
                                color: clr,
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
                      ),
                    )
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 100,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: SizedBox(
                width: 250,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.only(left: 35, right: 35),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Register",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            //Curcles Blue 01
            Positioned(
              top: 245,
              left: 5,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: newKMainColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 245,
              right: 8,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: newKMainColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            //Blue  02
            Positioned(
              top: 415,
              left: 5,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: newKMainColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 415,
              right: 8,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: newKMainColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            //white  02
            Positioned(
              top: 580,
              left: 5,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: newKBgColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 580,
              right: 8,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: newKBgColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color getColor(int index) {
  const colors = [
    Color(0xFF7882E0),
    Color(0xFF5B59CB),
    Color(0xFF73B5DB),
  ];
  return colors[index % colors.length];
}
