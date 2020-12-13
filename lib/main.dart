import 'package:flutter/material.dart';
import 'package:here_sdk/mapview.dart';
import 'package:tracking_location/gesture.dart';
import 'package:tracking_location/main_page.dart';
import 'package:here_sdk/core.dart';

void main() {
  SdkContext.init(IsolateOrigin.main);
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HereMap(onMapCreated: _onMapCreated)
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (MapError error) {
      if (error == null) {
        GesturesExample(_context, hereMapController);
      } else {
        print("Map scene not loaded. MapError: " + error.toString());
      }
    });
  }
}
