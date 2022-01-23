import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/models/locationPoint.dart';
import 'package:map_app/providers/appDataProvider.dart';
import 'package:provider/provider.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapController mapController = MapController();
  late bool centerOnLocationUpdate;
  late StreamController<double> _centerCurrentLocationStreamController;

  List<LocationPoint> points = [];

  @override
  void initState() {
    super.initState();
    _centerCurrentLocationStreamController = StreamController<double>();
    centerOnLocationUpdate = true;
  }

  @override
  void dispose() {
    _centerCurrentLocationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double myLat =
        Provider.of<AppDataProvider>(context, listen: true).currentLat;
    double myLon =
        Provider.of<AppDataProvider>(context, listen: true).currentLon;
    mapController.onReady.then((v) {
      if (centerOnLocationUpdate) {
        mapController.move((LatLng(myLat, myLon)), 15);
      }
    });
    var markersList =
        Provider.of<AppDataProvider>(context, listen: true).markers;

    List<Marker> markers = markersList
        .map((pt) => Marker(
              point: LatLng(pt.lat, pt.lon),
              builder: (context) => Container(
                child: Text((markersList.indexOf(pt) + 1).toString()),
              ),
            ))
        .toList();

    markers.insert(
      markers.length,
      Marker(
        point: LatLng(myLat, myLon),
        builder: (context) => Container(
          child: Icon(
            Icons.circle,
            size: 15,
            color: Colors.blue,
          ),
        ),
      ),
    );

    var polylines = [
      Polyline(
          color: Colors.red,
          strokeWidth: 2.0,
          points: Provider.of<AppDataProvider>(context, listen: true)
              .route
              .map((pt) => LatLng(pt[0], pt[1]))
              .toList())
    ];
    return Scaffold(
      floatingActionButton: Visibility(
        visible: !centerOnLocationUpdate,
        child: FloatingActionButton(
          onPressed: () {
            centerOnLocationUpdate = true;
            setState(() {});
          },
          child: Icon(Icons.location_on_outlined),
          backgroundColor: Colors.blue,
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            layers: [
              PolylineLayerOptions(polylines: polylines),
              MarkerLayerOptions(
                markers: markers,
              ),
            ],
            options: MapOptions(
                center: LatLng(myLat, myLon),
                zoom: 15,
                // Stop centering the location marker on the map if user interacted with the map.
                onPositionChanged: (MapPosition position, bool hasGesture) {
                  if (hasGesture) {
                    centerOnLocationUpdate = false;
                    setState(() {});
                  }
                }),
            children: [
              TileLayerWidget(
                options: TileLayerOptions(
                    urlTemplate:
                        "https://api.mapbox.com/styles/v1/samuelezraberry/cksu4fbc13cgz18pfalg7dkkl/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic2FtdWVsZXpyYWJlcnJ5IiwiYSI6ImNrc3UzODd5eDFjanEydG1kZnZpNjYwZngifQ.kKLofNEMgAvb4zrsdWdMHw",
                    additionalOptions: {
                      'accessToken':
                          'pk.eyJ1Ijoic2FtdWVsZXpyYWJlcnJ5IiwiYSI6ImNrc3UzODd5eDFjanEydG1kZnZpNjYwZngifQ.kKLofNEMgAvb4zrsdWdMHw',
                      'id': 'mapbox.mapbox-streets-v8',
                    },
                    minZoom: 3),
              ),

              // Positioned(
              //   right: 20,
              //   bottom: 20,
              //   child: FloatingActionButton(
              //     onPressed: () {
              //       // Automatically center the location marker on the map when location updated until user interact with the map.
              //       setState(() =>
              //           _centerOnLocationUpdate = CenterOnLocationUpdate.always);
              //       // Center the location marker on the map and zoom the map to level 18.
              //       _centerCurrentLocationStreamController.add(18);
              //     },
              //     child: Icon(
              //       Icons.my_location,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
