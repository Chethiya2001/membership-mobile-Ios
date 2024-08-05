class Product {
  final int id;
  final String productName;
  final int lastPrice;
  final String productFamily;
  final String productFamilyCode;
  final String productCode;
  final String paymentType;
  final int? minimumPrice;
  final int? maximumPrice;
  final int customPrice;

  Product({
    required this.id,
    required this.productName,
    required this.lastPrice,
    required this.productFamily,
    required this.productFamilyCode,
    required this.productCode,
    required this.paymentType,
    this.minimumPrice,
    this.maximumPrice,
    required this.customPrice,
  });
}
