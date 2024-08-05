import 'package:mobile_app/features/election/election_list/models/election_list_model.dart';

final List<Election> electionListITems = [
  Election(
      id: 23,
      organisationId: 1,
      electionTypeId: 1,
      title: "Test",
      welcomeText: "Test",
      callForVote: "<p>Test</p>",
      callForCandidate: "<p>Test</p>",
      targetYear: "2023-01-01T00:00:00.000Z",
      valid: true,
      callVote: true,
      callCandidate: true,
      showDate: "2024-01-15T00:00:00.000Z",
      hideDate: "2024-01-20T00:00:00.000Z",
      startDate: "2024-01-01",
      endDate: "2024-01-18"),
   Election(
      id: 40,
      organisationId: 1,
      electionTypeId: 1,
      title: "Test election",
      welcomeText: "Test Election",
      callForVote: "<p>Test Election</p>",
      callForCandidate: "<p>Test</p>",
      targetYear: "2023-01-01T00:00:00.000Z",
      valid: true,
      callVote: true,
      callCandidate: true,
      showDate: "2024-01-26",
      hideDate: "2024-02-02",
      startDate: "2024-01-26",
      endDate: "2024-01-26"),

       Election(
      id: 55,
      organisationId: 1,
      electionTypeId: 4,
      title: "PV Election 1",
      welcomeText: "Welcome to the election",
      callForVote: "<p>Test</p>",
      callForCandidate: "<p>Test</p>",
      targetYear: "2024-01-01",
      valid: true,
      callVote: true,
      callCandidate: true,
      showDate: "2024-01-30",
      hideDate: "2024-02-06",
      startDate: "2024-01-30",
      endDate: "2024-01-182024-02-06"),
];
