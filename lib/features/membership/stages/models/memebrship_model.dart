class ProductModel {
  final int id;
  final String productName;
  final String productFamily;
  final String productFamilyCode;
  final String productCode;
  final String paymentType;
  final int lastPrice;

  ProductModel({
    required this.id,
    required this.productName,
    required this.productFamily,
    required this.productFamilyCode,
    required this.productCode,
    required this.paymentType,
    required this.lastPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_code': productCode,
      'last_price': lastPrice,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      productName: json['product_name'],
      productFamily: json['product_family'],
      productFamilyCode: json['product_family_code'],
      productCode: json['product_code'],
      paymentType: json['payment_type'],
      lastPrice: json['last_price'],
    );
  }

  static List<Map<String, dynamic>> productsToMapList(
      List<ProductModel> products) {
    return products.map((product) => product.toMap()).toList();
  }
}
