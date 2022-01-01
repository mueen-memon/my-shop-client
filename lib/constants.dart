import 'package:flutter/material.dart';

class Constants {
  static const kPrimaryTextColor = Colors.white;
  static Size? kScreenSize;
  static const kSecondaryColor = Colors.orange;
  static const thisColore = Color(0xff010425);

  void init(BuildContext context) {
    kScreenSize = MediaQuery.of(context).size;
  }

  static TextStyle kTitleTextStyle() {
    return const TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle kDescriptionTextStyle() {
    return const TextStyle(
      fontSize: 15.0,
      color: Colors.black38,
    );
  }
}
