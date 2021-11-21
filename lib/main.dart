import 'package:flutter/material.dart';
import 'package:map_app/pages/home.dart';
import 'package:background_location/background_location.dart';
import 'package:map_app/providers/appDataProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<AppDataProvider>(
      create: (context) => AppDataProvider(),
      child: Consumer<AppDataProvider>(
        builder: (context, themeProvider, child) => MyApp(),
      ),
    ),
    // MyApp(),
  );
}

Future<dynamic> startBackgroundLocation(BuildContext context) async {
  await BackgroundLocation.setAndroidNotification(
    title: 'Background service is running',
    message: 'Background location in progress',
    icon: '@mipmap/ic_launcher',
  );
  await BackgroundLocation.startLocationService(distanceFilter: 10);
  BackgroundLocation.getLocationUpdates((location) async {
    print("Location Change");
    await Provider.of<AppDataProvider>(context, listen: false)
        .addLocationPoint(location.latitude!, location.longitude!);
  });
  print("Finished");
  return true;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Future<dynamic> bgLocation = startBackgroundLocation(context);
    return FutureBuilder(
      future: bgLocation, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Widget child;
        if (snapshot.hasData) {
          child = HomePage();
        } else if (snapshot.hasError) {
          child = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "error",
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(snapshot.error.toString()),
            ],
          );
        } else {
          child = Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
        return MaterialApp(
          title: 'Commutr',
          home: Scaffold(body: child),
        );
      },
    );
  }
}
