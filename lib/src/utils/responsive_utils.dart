import 'package:flutter/widgets.dart';

class ResponsiveUtils {
  static double getResponsivePadding(BoxConstraints constraints) {
    return constraints.maxWidth * 0.05;
  }

  static double getResponsiveSpacing(BoxConstraints constraints) {
    return constraints.maxHeight * 0.02;
  }

  static double getResponsiveButtonHeight(BoxConstraints constraints) {
    return constraints.maxHeight * 0.08;
  }

  static double getResponsiveFontSize(BoxConstraints constraints) {
    return constraints.maxWidth * 0.04;
  }

  static double getResponsiveIconSize(BoxConstraints constraints) {
    return constraints.maxWidth * 0.06;
  }
}
