import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mobile_app/features/election/election_list/screens/election_list_screen.dart';
import 'package:mobile_app/features/membership/blog/blog_main/screens/blog_list_screen.dart';
import 'package:mobile_app/features/membership/fees&Join/screen/main_fees_screen.dart';
import 'package:mobile_app/features/membership/home/screen/home_screen.dart';
import 'package:mobile_app/features/membership/membership_catergories/screens/memebrship_section_screen.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/screens/main_profile_screen.dart';
import 'package:mobile_app/features/membership/memebrshipProfile/screens/user_profile_screen.dart';
import 'package:mobile_app/features/membership/organization_membership/screens/main_org_register_screen.dart';
import 'package:mobile_app/features/membership/stages/widgets/stage_one_widget.dart';
import 'package:mobile_app/features/membership/webinars/screens/webinar_catergory_list.dart';
import 'package:mobile_app/splash.dart';

void main() {
  Stripe.publishableKey =
      'pk_test_51PYPgaFzqpP2yZB2ar3afjZnYgrcneZ3c6YAwejKi0xi6CjzGgVCYM7pQXMlX1PLIaZ1pKNv2i1TMK1wTRekKCUy00PO5ZYdKG';
  runApp(
    const ProviderScope(
      child: MemebrshipApp(),
    ),
  );
}

class MemebrshipApp extends StatelessWidget {
  const MemebrshipApp({super.key});
  @override
  Widget build(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;

    return SafeArea(
      top: true,
      child: MaterialApp(
        supportedLocales: const [
          Locale('en', 'US'), // English
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: brightness).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF045EA0),
            // ignore: deprecated_member_use
            background: Colors.white,
            secondary: const Color(0xFFFDB814),
          ),
        ),
        themeMode: ThemeMode.system,
        routes: {
          '/editProfile': (context) => const UserProfileScreen(),
          '/blogs': (context) => const BlogScreen(),
          '/membership': (context) => const RegisterStageWidget(),
          '/membershipProfile': (context) => const MainProfilePage(),
          '/section': (context) => const MembershipSection(),
          '/fees': (context) => const FeesAnfJoiningScreen(),
          '/webinar': (context) => const WebinarScreen(),
          '/orgRegister': (context) => const OrganizationRegisterScreen(),
          
        },
        home: const Splash(),
      ),
    );
  }
}
