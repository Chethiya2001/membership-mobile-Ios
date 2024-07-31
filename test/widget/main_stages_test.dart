import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/membership/stages/widgets/stage_four_widget.dart';
import 'package:mobile_app/features/membership/stages/widgets/stage_one_widget.dart';
import 'package:mobile_app/features/membership/stages/widgets/stage_three_widget.dart';
import 'package:mobile_app/features/membership/stages/widgets/stage_two_widget.dart';

void main() {
  testWidgets(
    'Stage 01 Screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: RegisterStageWidget(),
        ),
        duration: const Duration(seconds: 2),
      );
    },
  );
  testWidgets(
    'Stage 02 Screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: MemebrshipStatageWidget(
            response: "",
          ),
        ),
        duration: const Duration(seconds: 2),
      );
    },
  );
  testWidgets(
    'Stage 03 Screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: MembershipDetailsWidget(
            catgoryData: "",
          ),
        ),
        duration: const Duration(seconds: 2),
      );
    },
  );
  testWidgets(
    'Stage 04 Screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: PaymentWidget(data: "",),
        ),
        duration: const Duration(seconds: 2),
      );
    },
  );
}
