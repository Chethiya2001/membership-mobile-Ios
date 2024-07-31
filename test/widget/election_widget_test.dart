import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/election/candidate_call/screen/appy_candidate_screen.dart';
import 'package:mobile_app/features/election/candidate_call/screen/callForCandidate_Screen.dart';
import 'package:mobile_app/features/election/election_list/screens/election_list_screen.dart';
import 'package:mobile_app/features/election/vote/screens/main_selecterd_election_screen.dart';
import 'package:mobile_app/features/membership/home/screen/home_screen.dart';

void main() {
  testWidgets(
    'Election Screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: ElectionListScreen(
            data: "data",
          ),
        ),
        duration: const Duration(seconds: 2),
      );
      final data = find.text('Test');
      expect(find.byType(HomeScreen), data);
    },
  );
  testWidgets(
    'Call for candidate Screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
            textDirection: TextDirection.ltr,
            child: CallForCandidateScreen(candiData: "Test")),
        duration: const Duration(seconds: 2),
      );
      final data = find.text('Test');
      expect(find.byType(HomeScreen), data);
    },
  );
   testWidgets(
    'Vote for candidate Screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
            textDirection: TextDirection.ltr,
            child: ApplyCandidateScreen(poId: 1, electionId: 1, postionName: "Test")),
        duration: const Duration(seconds: 2),
      );
      final data = find.text('Test');
      expect(find.byType(HomeScreen), data);
    },
  );
    testWidgets(
    'Votes',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
            textDirection: TextDirection.ltr,
            child: SelecterdElectionScreen(data: "Test", id:"1")),
        duration: const Duration(seconds: 2),
      );
      final data = find.text('Test');
      expect(find.byType(HomeScreen), data);
    },
  );
}
