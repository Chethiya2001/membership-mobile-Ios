import 'package:flutter/foundation.dart';

class TotalQuantityProvider extends ChangeNotifier {
  int _totalQuantity = 0;

  int get totalQuantity => _totalQuantity;

  void updateTotalQuantity(int newTotalQuantity) {
    _totalQuantity = newTotalQuantity;
    notifyListeners();
  }
}