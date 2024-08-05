class Election {
  int id;
  int organisationId;
  int electionTypeId;
  String title;
  String welcomeText;
  String callForVote;
  String callForCandidate;
  String targetYear;
  dynamic subSection;
  dynamic memberCategory;
  dynamic memberValidity;
  bool valid;
  bool callVote;
  bool callCandidate;
  String showDate;
  String hideDate;
  String startDate;
  String endDate;

  Election({
    required this.id,
    required this.organisationId,
    required this.electionTypeId,
    required this.title,
    required this.welcomeText,
    required this.callForVote,
    required this.callForCandidate,
    required this.targetYear,
    this.subSection,
    this.memberCategory,
    this.memberValidity,
    required this.valid,
    required this.callVote,
    required this.callCandidate,
    required this.showDate,
    required this.hideDate,
    required this.startDate,
    required this.endDate,
  });

  factory Election.fromJson(Map<String, dynamic> json) {
    return Election(
      id: json['id'],
      organisationId: json['organisation_id'],
      electionTypeId: json['election_type_id'],
      title: json['title'],
      welcomeText: json['welcome_text'],
      callForVote: json['call_for_vote'],
      callForCandidate: json['call_for_candidate'],
      targetYear: json['target_year'],
      subSection: json['sub_section'],
      memberCategory: json['member_category'],
      memberValidity: json['member_validity'],
      valid: json['valid'],
      callVote: json['call_vote'],
      callCandidate: json['call_candidate'],
      showDate: json['show_date'],
      hideDate: json['hide_date'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}
