// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserUpdate {
  final String profileImg;
  final String coverImage;
  final String firstName;
  final String secondName;
  final String lastName;
  final String email;
  final String mobile;
  final String country;
  final String nationality;
  final String state;
  final String title;
  final String gender;
  final String ageRange;
  final String jobCatergory;
  final String jobtitle;
  final String qualification;
  final String language;
  final String department;
  final String addressline1;
  final String addressline3;
  final String addressline2;
  final String fax;
  // late String status = "PENDING";
  final String institiution;
  final String typeOfInstitution;
  final String postalCode;

  UserUpdate({
    required this.profileImg,
    required this.coverImage,
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.country,
    required this.nationality,
    required this.state,
    required this.title,
    required this.gender,
    required this.ageRange,
    required this.jobCatergory,
    required this.jobtitle,
    required this.qualification,
    required this.language,
    required this.department,
    required this.addressline1,
    required this.addressline3,
    required this.addressline2,
    required this.fax,
    required this.institiution,
    required this.typeOfInstitution,
    required this.postalCode,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'first_name': firstName,
      'second_name': secondName,
      'profile_image': profileImg,
      'cover_image': coverImage,
      'surname': lastName,
      'email': email,
      'mobile': mobile,
      'country': country,
      'nationality': nationality,
      'state': state,
      'title': title,
      'gender': gender,
      'age_range': ageRange,
      'job_category': jobCatergory,
      'job_title': jobtitle,
      'qualification': qualification,
      'language': language,
      'department': department,
      'address_line1': addressline1,
      'address_line3': addressline3,
      'address_line2': addressline2,
      'fax': fax,
      // 'status': status,
      'type_of_institution': typeOfInstitution,
      'institution': institiution,
      'po_code': postalCode,
    };
  }

  factory UserUpdate.fromMap(Map<String, dynamic> map) {
    return UserUpdate(
      firstName: map['first_name'] as String? ?? '',
      secondName: map['second_name'] as String? ?? '',
      lastName: map['surname'] as String? ?? '',
      email: map['email'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
      country: map['country'] as String? ?? '',
      nationality: map['nationality'] as String? ?? '',
      state: map['state'] as String? ?? '',
      title: map['title'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      ageRange: map['age_range'] as String? ?? '',
      jobCatergory: map['job_category'] as String? ?? '',
      jobtitle: map['jobtitle'] as String? ?? '',
      qualification: map['qualification'] as String? ?? '',
      language: map['language'] as String? ?? '',
      department: map['department'] as String? ?? '',
      addressline1: map['address_line1'] as String? ?? '',
      addressline3: map['address_line3'] as String? ?? '',
      addressline2: map['address_line2'] as String? ?? '',
      fax: map['fax'] as String? ?? '',
      // status: map['status'] as String? ?? '',
      typeOfInstitution: map['type_of_institution'] as String? ?? '',
      postalCode: map['po_code'] as String? ?? '',
      institiution: map['institution'] as String? ?? '',
      profileImg: map['profile_image'] as String? ?? '',
      coverImage: map['cover_image'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserUpdate.fromJson(String source) =>
      UserUpdate.fromMap(json.decode(source) as Map<String, dynamic>);
}
