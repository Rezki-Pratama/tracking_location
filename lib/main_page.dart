import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/routing.dart';
import 'package:tracking_location/service/location_service.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  HereMapController _controller;
  MapPolyline _mapPolyLine;
  bool activePolyline = false;
  LocationService locationService = LocationService();
  double latitude = 0;
  double longitude = 0;

  @override
  void initState() {
    super.initState();
    locationService.locationStream.listen((userLocation) {
      setState(() {
        latitude = userLocation.latitude;
        longitude = userLocation.longitude;
      });
      print(latitude);
      print(longitude);
    });
  }

  @override
  void dispose() {
    //ketika controllernya tidak null, maka jalankan finalize / akhiri
    _controller?.finalize();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      HereMap(
        onMapCreated: _onMapCreated,
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: RaisedButton(
          child: Text('Remove route'),
          onPressed: () {
            if(activePolyline == false) {
              _controller.mapScene.removeMapPolyline(_mapPolyLine);
              // _mapPolyLine = null;
              activePolyline = true;
            } else {
              _controller.mapScene.addMapPolyline(_mapPolyLine);
              activePolyline = false;
            }
          }
        ),
      )
    ]));
  }

  Future<void> drawRedDot(HereMapController hereMapController, int drawOrder,
      GeoCoordinates geoCoordinates) async {
    //load gambar
    ByteData fileData = await rootBundle.load('assets/images/circle.png');
    //ubah menjadi pixel data / unsign integer
    Uint8List pixelData = fileData.buffer.asUint8List();
    //format gambar
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);

    MapMarker mapMarker = MapMarker(geoCoordinates, mapImage);
    mapMarker.drawOrder = drawOrder;
    hereMapController.mapScene.addMapMarker(mapMarker);
  }

  Future<void> drawPin(HereMapController hereMapController, int drawOrder,
      GeoCoordinates geoCoordinates) async {
    //load gambar
    ByteData fileData = await rootBundle.load('assets/images/pin.png');
    //ubah menjadi pixel data / unsign integer
    Uint8List pixelData = fileData.buffer.asUint8List();
    //format gambar
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);

    Anchor2D anchor2d = Anchor2D.withHorizontalAndVertical(0.5, 1);

    MapMarker mapMarker =
        MapMarker.withAnchor(geoCoordinates, mapImage, anchor2d);
    mapMarker.drawOrder = drawOrder;
    hereMapController.mapScene.addMapMarker(mapMarker);
  }

  Future<void> drawRoute(GeoCoordinates start, GeoCoordinates end,
      HereMapController hereMapController) async {
    //inisialisasi routing engine yang bertugas menghitung jarak
    RoutingEngine routingEngine = RoutingEngine();

    //buat waypoint
    Waypoint startWaypoint = Waypoint.withDefaults(start);
    Waypoint endWaypoint = Waypoint.withDefaults(end);

    //list waypoint
    List<Waypoint> waypoints = [startWaypoint, endWaypoint];
    routingEngine.calculateCarRoute(waypoints, CarOptions.withDefaults(),
        (RoutingError routingError, List routes) {
      if (routingError == null) {
        var route = routes.first;

        //inisialisasi polyline / garis
        GeoPolyline reouteGeoPolyLine = GeoPolyline(route.polyline);

        //buat visualisasi representasi untuk polyline / garis

        //ketebalan
        double depth = 20;

        _mapPolyLine = MapPolyline(reouteGeoPolyLine, depth, Colors.blue);

        //pasang di controller untuk digambar di peta
        hereMapController.mapScene.addMapPolyline(_mapPolyLine);
      }
    });

    //Hitung rutenya
  }

  void _onMapCreated(HereMapController hereMapController) {
    _controller = hereMapController;
    // Mengatur tema peta
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.greyNight,
        (MapError error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        //return kosong , untuk mengentikan fungsi
        return;
      }

      drawRedDot(hereMapController, 0, GeoCoordinates(-3.0078827,104.757845));
      drawPin(hereMapController, 0, GeoCoordinates(-3.0078827,104.757845));
      drawRoute(GeoCoordinates(-3.0078827,104.757845),
          GeoCoordinates(latitude, longitude), hereMapController);

      const double distanceToEarthInMeters = 8000;
      hereMapController.camera.lookAtPointWithDistance(
          GeoCoordinates(-3.0078827,104.757845), distanceToEarthInMeters);
    });
  }
}
