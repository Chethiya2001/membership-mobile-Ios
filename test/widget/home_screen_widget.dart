import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/membership/home/screen/home_screen.dart';

void main() {
  testWidgets(
    'Home Screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: HomeScreen(signOutCallback: () {}),
        ),
        duration: const Duration(seconds: 2),
      );

      expect(find.byType(HomeScreen), "Done");
    },
  );
}
