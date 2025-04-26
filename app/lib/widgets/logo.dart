import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Logo extends StatelessWidget {
  final int logoType; // 0: w/ text; 1: w/o text
  final double width;
  final double height;

  const Logo({super.key, required this.logoType, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      getLogoTypeString(),
      width: width,
      height: height,
    );
  }

  String getLogoTypeString(){
    switch (logoType) {
      case 0:
        return 'lib/assets/kr-logo-text.svg';
      case 1:
        return 'lib/assets/kr-logo.svg';
      default:
        return 'lib/assets/kr-logo-text.svg';
    }
  }
}