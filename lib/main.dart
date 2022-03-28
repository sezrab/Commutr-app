import 'package:flutter/material.dart';
import 'package:map_app/pages/home.dart';
import 'package:background_location/background_location.dart';
import 'package:map_app/providers/appDataProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<AppDataProvider>(
      // this is the root node of the widget tree
      // it sets up the provider and runs MyApp(), which is the main ui
      create: (context) => AppDataProvider(),
      child: Consumer<AppDataProvider>(
        builder: (context, themeProvider, child) => MyApp(), // run main ui
      ),
    ),
    // MyApp(),
  );
}

Future<dynamic> startBackgroundLocation(BuildContext context) async {
  // start the background location service
  await BackgroundLocation.setAndroidNotification(
    title: 'Background service is running',
    message: 'Background location in progress',
    icon: '@mipmap/ic_launcher',
  );
  await BackgroundLocation.startLocationService();
  BackgroundLocation.getLocationUpdates((location) async {
    await Provider.of<AppDataProvider>(context, listen: false)
        .updateLocation(location.latitude!, location.longitude!);
  });
  return true;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Future<dynamic> bgLocation = startBackgroundLocation(
        context); // run the background location service before anything
    return FutureBuilder(
      future: bgLocation, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Widget child;
        if (snapshot.hasData) {
          // load the homepage if the first location has come through
          child = HomePage();
        } else if (snapshot.hasError) {
          // else show error as something has gone wrong
          child = Scaffold(
              body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Error! No location data",
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(snapshot.error.toString()),
            ],
          ));
        } else {
          child = Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }
        return MaterialApp(
          // run a materialapp widget with the widget chosen above as the home
          title: 'Commutr',
          home: child,
        );
      },
    );
  }
}
