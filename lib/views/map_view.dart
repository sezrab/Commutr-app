import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double> _centerCurrentLocationStreamController;

  @override
  void initState() {
    super.initState();
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double>();
  }

  @override
  void dispose() {
    _centerCurrentLocationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
              center: LatLng(0, 0),
              zoom: 15,
              // Stop centering the location marker on the map if user interacted with the map.
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture) {
                  setState(() =>
                      _centerOnLocationUpdate = CenterOnLocationUpdate.never);
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
            LocationMarkerLayerWidget(
              options: LocationMarkerLayerOptions(
                  showHeadingSector: false, showAccuracyCircle: true),
              plugin: LocationMarkerPlugin(
                centerCurrentLocationStream:
                    _centerCurrentLocationStreamController.stream,
                centerOnLocationUpdate: _centerOnLocationUpdate,
              ),
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
    );
  }
}
