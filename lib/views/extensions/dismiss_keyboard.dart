import 'package:flutter/material.dart' show Widget, FocusManager;

extension DismissKeyboard on Widget {
  void dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
}
