import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/membership/auth/screen/login_auth.dart';

void main() {
  testWidgets('Login Screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: LoginAuthScreen(),
      ),
    );
  });
  testWidgets('Register Screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: LoginAuthScreen(),
      ),
    );
  });
}
