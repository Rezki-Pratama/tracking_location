import 'package:flutter/material.dart';
import 'package:tracking_location/main_page.dart';
import 'package:here_sdk/core.dart';

void main() {
  SdkContext.init(IsolateOrigin.main);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage()
    );
  }
}
