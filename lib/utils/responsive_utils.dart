import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static double getSidebarWidth(BuildContext context) {
    if (isDesktop(context)) return 240.0;
    return 70.0; // Compact sidebar for smaller screens
  }
}
