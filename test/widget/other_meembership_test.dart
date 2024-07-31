import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/membership/home/screen/home_screen.dart';
import 'package:mobile_app/features/membership/organization_membership/screens/main_org_register_screen.dart';

void main() {
  testWidgets(
    'Org Register Screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: OrganizationRegisterScreen(),
        ),
        duration: const Duration(seconds: 2),
      );

      expect(find.byType(HomeScreen), "Done");
    },
  );
}
