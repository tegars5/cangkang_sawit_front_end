import 'package:flutter/material.dart';

/// Centralized border radius constants
class AppRadius {
  AppRadius._(); // Private constructor to prevent instantiation

  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xl = 20.0;
  static const double circle = 999.0;

  // BorderRadius objects for convenience
  static BorderRadius smallRadius = BorderRadius.circular(small);
  static BorderRadius mediumRadius = BorderRadius.circular(medium);
  static BorderRadius largeRadius = BorderRadius.circular(large);
  static BorderRadius xlRadius = BorderRadius.circular(xl);
}
