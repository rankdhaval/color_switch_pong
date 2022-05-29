import 'package:flutter/material.dart';

class SizeConfig {
  static double? alignmentWidth;

  void init(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    alignmentWidth = screenWidth / 20;
  }

  static double getAlignmentOfScoringObject(double width) {
    return ((width / 2) / alignmentWidth!) / 10;
  }
}
