import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Billing {
  String email;
  String address;
  String postalcode;
  String city;
  String country;
  String mobile;
  Billing({
    required this.email,
    required this.address,
    required this.postalcode,
    required this.city,
    required this.country,
    required this.mobile,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'address_line1': address,
      'po_code': postalcode,
      'city': city,
      'country': country,
      'mobile': mobile,
    };
  }

  factory Billing.fromMap(Map<String, dynamic> map) {
    return Billing(
      email: map['email'] as String? ?? '',
      address: map['address_line1'] as String? ?? '',
      postalcode: map['po_code'] as String? ?? '',
      city: map['city'] as String? ?? '',
      country: map['country'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Billing.fromJson(String source) =>
      Billing.fromMap(json.decode(source) as Map<String, dynamic>);
}
