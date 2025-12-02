import 'package:flutter/material.dart';

class LayoutVisibilityProvider extends ChangeNotifier {
  bool _useLayout = true;

  bool get useLayout => _useLayout;

  void disableLayout() {
    if (_useLayout) {
      _useLayout = false;
      notifyListeners();
    }
  }

  void enableLayout() {
    if (!_useLayout) {
      _useLayout = true;
      notifyListeners();
    }
  }
}
