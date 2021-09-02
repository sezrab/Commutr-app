import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location/flutter_map_location.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        plugins: <MapPlugin>[
          // USAGE NOTE 2: Add the plugin
          LocationPlugin(),
        ],
      ),
      layers: <LayerOptions>[
        TileLayerOptions(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/samuelezraberry/cksu4fbc13cgz18pfalg7dkkl/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic2FtdWVsZXpyYWJlcnJ5IiwiYSI6ImNrc3UzODd5eDFjanEydG1kZnZpNjYwZngifQ.kKLofNEMgAvb4zrsdWdMHw",
            additionalOptions: {
              'accessToken':
                  'pk.eyJ1Ijoic2FtdWVsZXpyYWJlcnJ5IiwiYSI6ImNrc3UzODd5eDFjanEydG1kZnZpNjYwZngifQ.kKLofNEMgAvb4zrsdWdMHw',
              'id': 'mapbox.mapbox-streets-v8',
            }),
      ],
      nonRotatedLayers: <LayerOptions>[
        // USAGE NOTE 3: Add the options for the plugin
        LocationOptions(
          locationButton(),
          onLocationUpdate: (LatLngData? ld) {
            print(
                'Location updated: ${ld?.location} (accuracy: ${ld?.accuracy})');
          },
          onLocationRequested: (LatLngData? ld) {
            if (ld == null) {
              return;
            }
            mapController.move(ld.location, 16.0);
          },
        ),
      ],
    );
  }

  LocationButtonBuilder locationButton() {
    return (BuildContext context, ValueNotifier<LocationServiceStatus> status,
        Function onPressed) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
          child: FloatingActionButton(
              child: ValueListenableBuilder<LocationServiceStatus>(
                  valueListenable: status,
                  builder: (BuildContext context, LocationServiceStatus value,
                      Widget? child) {
                    switch (value) {
                      case LocationServiceStatus.disabled:
                      case LocationServiceStatus.permissionDenied:
                      case LocationServiceStatus.unsubscribed:
                        return const Icon(
                          Icons.location_disabled,
                          color: Colors.white,
                        );
                      default:
                        return const Icon(
                          Icons.location_searching,
                          color: Colors.white,
                        );
                    }
                  }),
              onPressed: () => onPressed()),
        ),
      );
    };
  }
}
