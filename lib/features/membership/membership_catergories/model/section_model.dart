class Section {
  final String title;
  final String code;

  Section({required this.title, required this.code});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      title: json['title'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'code': code,
    };
  }
}
