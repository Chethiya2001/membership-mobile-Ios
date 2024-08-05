import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/constant/base_img_api.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/auth/services/login_token_service.dart';
import 'package:mobile_app/features/membership/blog/blog_details/screens/blog_details_screen.dart';
import 'package:mobile_app/features/membership/blog/providers/blog_list_provider.dart';
import 'package:mobile_app/features/membership/home/screen/widgets/List_drawer.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/screens/user_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlogScreen extends ConsumerStatefulWidget {
  const BlogScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BlogScreenState createState() => _BlogScreenState();
}

class _BlogScreenState extends ConsumerState<BlogScreen> {
  String? loadedMembershipId;
  Future<String> loadMembershipIdLocally() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      const String membershipKey = 'membership';

      // Get membership ID from shared preferences
      final String? loadedId = pref.getString(membershipKey);

      return loadedId ?? ''; // Return an empty string if null
    } catch (e) {
      log.e('Error loading membership ID locally: $e');
      return ''; // Return an empty string in case of an error
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    loadMembershipIdLocally().then((loadedId) {
      setState(() {
        loadedMembershipId = loadedId;
      });
      log.d('Loaded Membership ID in initState: $loadedId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final membershipId = loadedMembershipId ?? '';
    if (membershipId.isEmpty) {
      return Scaffold(
        backgroundColor: newKBgColor,
        body: Center(
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 0, // Set elevation to 0 to remove the default shadow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Still not a member!',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(), // Add a divider between title and content
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Please join with us,',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => const UserProfileScreen(),
                          ));
                        },
                        child: Text(
                          'Join now',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary, // Use primary color for the button text
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
      );
    } else {
      return Scaffold(
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
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 60, 0, 2),
                              child: Text(
                                "Blogs",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Adamina',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 1.8,
                    width: screenWidth * 0.9,
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
                  width: screenWidth * 1.0,
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
                            Consumer(
                              builder: (context, watch, child) {
                                final AsyncValue<Map<String, dynamic>?>
                                    blogListFuture =
                                    ref.watch(blogListProvider);
                                return blogListFuture.when(
                                  data: (blogData) {
                                    print(
                                        'Data loaded successfully: $blogData');

                                    final dynamic successData =
                                        blogData?['success'];
                                    if (successData != null &&
                                        successData is Map<String, dynamic>) {
                                      final dynamic blogs =
                                          successData['blogs'];
                                      if (blogs != null &&
                                          blogs is List<dynamic> &&
                                          blogs.isNotEmpty) {
                                        final dynamic blog = blogs[0];
                                        if (blog != null &&
                                            blog is Map<String, dynamic>) {
                                          print('Blog: $blog');
                                          final String? title =
                                              blog['title']?.toString();
                                          final String? seoTitle =
                                              blog['seo_title']?.toString();
                                          final String? blogbody =
                                              blog['body']?.toString();
                                          int? pageId = blog['id'];
                                          final String? imageUrl =
                                              blog['image']?.toString();
                                          final String fullImageUrl =
                                              imageUrl != null
                                                  ? ApiConstantsBlogImage
                                                      .getCoverImageUrl(
                                                          imageUrl)
                                                  : '';

                                          return Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 0, top: 0),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4, bottom: 4),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.2), // Shadow color with opacity
                                                            spreadRadius:
                                                                5, // The spread radius
                                                            blurRadius:
                                                                7, // The blur radius
                                                            offset: Offset(1,
                                                                3), // The offset of the shadow
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          imageUrl != null
                                                              ? Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              10),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              10),
                                                                    ),
                                                                  ),
                                                                  height: 100,
                                                                  width: double
                                                                      .infinity, // Adjust the width as needed
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              10),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              10),
                                                                    ),
                                                                    child: Image
                                                                        .network(
                                                                      fullImageUrl,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      errorBuilder: (BuildContext context,
                                                                          Object
                                                                              exception,
                                                                          StackTrace?
                                                                              stackTrace) {
                                                                        return const Center(
                                                                          child:
                                                                              Text(
                                                                            'Image not found',
                                                                            style:
                                                                                TextStyle(color: Colors.red),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                )
                                                              : const Text(
                                                                  'No image found!'),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  title ?? '',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(seoTitle ??
                                                                    ''),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                ElevatedButton(
                                                                    style:
                                                                        ButtonStyle(
                                                                      backgroundColor:
                                                                          MaterialStateProperty.all(
                                                                              newKMainColor),
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      // Get the authentication token
                                                                      final token =
                                                                          await AuthManager
                                                                              .getToken();

                                                                      if (token ==
                                                                          null) {
                                                                        print(
                                                                            "User not authenticated. Please log in.");
                                                                      }
                                                                      // Print the full image URL
                                                                      print(
                                                                          'Full Image URL: $fullImageUrl');

                                                                      // Save the selected blog details to SharedPreferences
                                                                      SharedPreferences
                                                                          prefs =
                                                                          await SharedPreferences
                                                                              .getInstance();
                                                                      prefs.setString(
                                                                          'selected_blog_title',
                                                                          title!);
                                                                      prefs.setString(
                                                                          'selected_blog_imageUrl',
                                                                          fullImageUrl);
                                                                      prefs.setString(
                                                                          'selected_blog_description',
                                                                          seoTitle ??
                                                                              "");
                                                                      prefs.setString(
                                                                          'selected_blog',
                                                                          blogbody ??
                                                                              "");
                                                                      prefs.setInt(
                                                                          'selected_page_id',
                                                                          pageId!);

                                                                      final List<
                                                                              Map<String, dynamic>>
                                                                          blogDiscussion =
                                                                          (blog['discussion'] as List<dynamic>?)?.map<Map<String, dynamic>>((discussion) {
                                                                                if (discussion is String) {
                                                                                  return {
                                                                                    'discussion': discussion,
                                                                                    'parent_id': 0,
                                                                                    'status': 0,
                                                                                    'page_id': 0,
                                                                                  };
                                                                                } else if (discussion is Map<String, dynamic>) {
                                                                                  return {
                                                                                    'discussion': discussion['discussion'],
                                                                                    'parent_id': discussion['parent_id'] ?? 0,
                                                                                    'status': discussion['status'] ?? 0,
                                                                                    'page_id': discussion['page_id'],
                                                                                  };
                                                                                }
                                                                                return {};
                                                                              }).toList() ??
                                                                              [];

                                                                      prefs
                                                                          .setStringList(
                                                                        'selected_blog_discussion',
                                                                        blogDiscussion
                                                                            .map<String>((discussion) =>
                                                                                json.encode(discussion))
                                                                            .toList(),
                                                                      );

                                                                      // Print the saved data
                                                                      print(
                                                                          'Selected Blog Title: ${prefs.getString('selected_blog_title')}');
                                                                      print(
                                                                          'Selected Blog ImageUrl: ${prefs.getString('selected_blog_imageUrl')}');
                                                                      print(
                                                                          'Selected Body: ${prefs.getString('selected_blog')}');
                                                                      print(
                                                                          'Selected Blog Discussion: ${prefs.getStringList('selected_blog_discussion')}');

                                                                      // Navigate to the BlogDetailsScreen
                                                                      if (mounted) {
                                                                        Navigator.of(
                                                                            // ignore: use_build_context_synchronously
                                                                            context).push(
                                                                          MaterialPageRoute(
                                                                            builder: (ctx) =>
                                                                                const BlogDetailsScreen(),
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "View",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    )),
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
                                          );
                                        } else {
                                          print(
                                              'Invalid blog data structure: $blog');
                                          return const Text(
                                              'Invalid blog data structure');
                                        }
                                      } else {
                                        print(
                                            'Empty or invalid blogs list: $blogs');
                                        return const Text(
                                            'Empty or invalid blogs list');
                                      }
                                    } else {
                                      print(
                                          'Invalid success data structure: $successData');
                                      return const Text(
                                          'Invalid success data structure');
                                    }
                                  },
                                  loading: () =>
                                      const CircularProgressIndicator(),
                                  error: (error, stackTrace) {
                                    print('Error: $error');
                                    return Text('Error: $error');
                                  },
                                );
                              },
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
  }
}
