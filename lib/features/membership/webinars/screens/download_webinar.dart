import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:path_provider/path_provider.dart';

class WebinarDownloadScreen extends StatelessWidget {
  const WebinarDownloadScreen({
    super.key,
    required this.selecterdCatergory,
  });

  final dynamic selecterdCatergory;

  @override
  Widget build(BuildContext context) {
    var downloadWebinar = selecterdCatergory['data'];
    print(downloadWebinar);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.white12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.how_to_vote_rounded, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon:
                  const Icon(Icons.supervised_user_circle, color: Colors.black),
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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  color: newKMainColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 26, 8, 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ListDrawer(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 60, 0, 2),
                            child: Text(
                              "Webinars",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Adamina',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 50, left: 18),
                            child: SvgPicture.asset('assets/contactUs-Svg.svg'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.7,
                )
              ],
            ),
            Positioned(
              top: 180,
              left: (screenWidth - screenWidth * 0.9) / 2,
              right: (screenWidth - screenWidth * 0.9) / 2,
              child: Container(
                decoration: const BoxDecoration(
                  //color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: 600,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Column(
                                        children: [
                                          // Your existing content here
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: downloadWebinar.length,
                                            itemBuilder: (context, index) {
                                              final webinar =
                                                  downloadWebinar[index];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .black26, // Shadow color
                                                        blurRadius:
                                                            10.0, // Amount of blur
                                                        spreadRadius:
                                                            1.0, // Spread radius
                                                        offset: Offset(0,
                                                            4), // Offset in x and y direction
                                                      ),
                                                    ],
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          webinar['title'] ??
                                                              '',
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          height: 100,
                                                          child:
                                                              SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            child: Text(
                                                              webinar['description'] ??
                                                                  '',
                                                              style: const TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w200),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    newKMainColor, // Change the background color
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                // Implement your download logic here using the 'downloadable_url'
                                                                String
                                                                    downloadUrl =
                                                                    webinar['downloadable_url'] ??
                                                                        '';
                                                                String
                                                                    downloadName =
                                                                    webinar['title'] ??
                                                                        '';

                                                                if (downloadUrl
                                                                    .isNotEmpty) {
                                                                  _downloadFile(
                                                                      downloadUrl,
                                                                      downloadName);
                                                                }
                                                              },
                                                              child: const Text(
                                                                'Download',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _downloadFile(String url, String fileName) async {
  //   Dio dio = Dio();
  //   try {
  //     var dir =
  //         await getApplicationDocumentsDirectory(); // Get the application documents directory
  //     String savePath = "${dir.path}/$fileName";

  //     // Retrieve the authentication token
  //     String? authToken = await AuthManager.getToken();

  //     // Set up Dio with headers, including the authentication token
  //     dio.options.headers["Authorization"] = "Bearer $authToken";

  //     // Download the file
  //     await dio.download(
  //       url,
  //       savePath,
  //       onReceiveProgress: (received, total) {
  //         print('Progress: $received out of $total');
  //       },
  //     );

  //     print(
  //         'Download successful! File saved to: $savePath'); // Print the save path
  //   } catch (e) {
  //     print('Error during download: $e');
  //   }
  void _downloadFile(String url, String fileName) async {
    try {
      // Get current time for unique file naming
      var time = DateTime.now();

      // Get application document directory
      var downloadDir = await getApplicationDocumentsDirectory();

      // Determine file extension from the URL
      var uri = Uri.parse(url);
      var fileExtension = uri.pathSegments.last.split('.').last;

      // Construct the full file path
      var path =
          "${downloadDir.path}/$fileName-${time.toIso8601String()}.$fileExtension";
      var file = File(path);

      // Get authentication token (if needed)
      final token = await AuthManager.getToken();
      if (token == null) {
        print('No authentication token found.');
        return;
      }

      // Set headers with the token
      var headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      // Make the HTTP GET request
      var response = await http.get(uri, headers: headers);

      // Log the request details for debugging
      print('Request URL: $url');
      print('Request Headers: $headers');

      if (response.statusCode == 200) {
        // Write the response bytes to the file
        await file.writeAsBytes(response.bodyBytes);
        print('Download successful! File saved to: $path');
      } else {
        print('Error during download: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      print('Error during download: ${e.toString()}');
    }
  }
}
