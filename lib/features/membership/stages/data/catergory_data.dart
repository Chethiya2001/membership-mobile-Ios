import 'package:mobile_app/features/membership/stages/models/memebrship_model.dart';

class ProductsData {
  static List<ProductModel> getProducts() {
    return [
      ProductModel(
        id: 34,
        productName: "Gold benefactor member 1 YEAR (print + online Journal)",
        productFamily: "Individual Membership",
        productFamilyCode: "IM",
        productCode: "BG",
        paymentType: "calendar",
        lastPrice: 1000,
      ),
      ProductModel(
        id: 150,
        productName: "Benefactor Member",
        productFamily: "Individual Membership",
        productFamilyCode: "IM",
        productCode: "BP",
        paymentType: "calendar",
        lastPrice: 2000,
      ),
      ProductModel(
        id: 159,
        productName: "Honorary Member",
        productFamily: "Individual Membership",
        productFamilyCode: "IM",
        productCode: "HM",
        paymentType: "calendar",
        lastPrice: 200,
      ),
      ProductModel(
        id: 165,
        productName: "Member with online Journal",
        productFamily: "Individual Membership",
        productFamilyCode: "IM",
        productCode: "MO1",
        paymentType: "calendar",
        lastPrice: 25,
      ),
      ProductModel(
        id: 176,
        productName:
            "Student member (online Journal - first time member in training and under 35 years old)",
        productFamily: "Individual Membership",
        productFamilyCode: "IM",
        productCode: "ST",
        paymentType: "calendar",
        lastPrice: 25,
      ),
    ];
  }
}
