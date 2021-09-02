import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location/flutter_map_location.dart';
import 'package:latlong2/latlong.dart' as latLng;

void main() {
  runApp(MyApp());
}

//  TileLayerOptions(
//               urlTemplate:
//                   "https://api.mapbox.com/styles/v1/samuelezraberry/cksu4g14111q217piovoa6ivm/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic2FtdWVsZXpyYWJlcnJ5IiwiYSI6ImNrc3UzODd5eDFjanEydG1kZnZpNjYwZngifQ.kKLofNEMgAvb4zrsdWdMHw",
//               additionalOptions: {
//                 'accessToken':
//                     'pk.eyJ1Ijoic2FtdWVsZXpyYWJlcnJ5IiwiYSI6ImNrc3UzODd5eDFjanEydG1kZnZpNjYwZngifQ.kKLofNEMgAvb4zrsdWdMHw',
//                 'id': 'mapbox.mapbox-streets-v8',
//               }),

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final MapController mapController = MapController();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Default'),
        ),
        body: Center(
          child: FlutterMap(
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
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: <String>['a', 'b', 'c'],
              ),
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
          ),
        ));
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
