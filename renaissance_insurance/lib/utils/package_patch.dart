import 'package:flutter/material.dart';

/// This file contains fixes for the drag_and_drop_lists package
/// to make it compatible with the latest Flutter version.
/// The subtitle1 property has been deprecated and replaced with titleMedium.

extension FixDeprecation on TextTheme {
  // Add a getter for subtitle1 that actually returns titleMedium
  // This way, when the package tries to use subtitle1, it gets titleMedium instead
  TextStyle? get subtitle1 => titleMedium;
} 