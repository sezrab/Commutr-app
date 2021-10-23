import 'package:flutter/material.dart';
import 'package:map_app/pages/home.dart';
import 'package:background_location/background_location.dart';
import 'package:map_app/utils/dbManager.dart';
import 'package:map_app/utils/theme_data.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MyApp(),
    ),
  );
}

Future<dynamic> startBackgroundLocation() async {
  await BackgroundLocation.setAndroidNotification(
    title: 'Background service is running',
    message: 'Background location in progress',
    icon: '@mipmap/ic_launcher',
  );
  await BackgroundLocation.startLocationService();
  BackgroundLocation.getLocationUpdates((location) {
    print(location.latitude);
    print(location.longitude);
  });
  print("Finished");
  return true;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Future<dynamic> bgLocation = startBackgroundLocation();
    return FutureBuilder(
      future: bgLocation, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return MaterialApp(
            title: 'Commutr',
            home: HomePage(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Something went wrong"));
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
