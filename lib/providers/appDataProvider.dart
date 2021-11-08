import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/models/locationPoint.dart';
import 'package:map_app/utils/locationFunctions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDataProvider extends ChangeNotifier {
  Color mainColor = Colors.blue;
  void changeThemeColor(Color color) {
    mainColor = color;
    notifyListeners();
  }

  Future<Database> openLocationDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    String dbPath = await getDatabasesPath();

    return openDatabase(
      join(dbPath, 'locations.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE locationPoints(id INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT, lat DOUBLE NOT NULL, lon DOUBLE NOT NULL, frequency INT NOT NULL);)',
        );
      },
      version: 1,
    );
  }

  Future<void> addLocationPoint(double lat, double lon) async {
    List<LocationPoint> points = await locationPoints();

    List<LocationPoint> nearbyPoints = [];

    for (var point in points) {
      double distance =
          LocationFunctions.haversine(lat, lon, point.lat, point.lon);
      if (distance <= 20) {
        nearbyPoints.add(point);
      }
    }

    final db = await openLocationDB();
    if (nearbyPoints.isEmpty) {
      // insert new
      await db.insert(
        'locations',
        {
          'lat': lat,
          'lon': lon,
          'frequency': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Created new entry for point at " + [lat, lon].toString());
    } else {
      // increment frequency for existing
      for (var point in nearbyPoints) {
        await db.rawQuery(
            "UPDATE locationPoints SET frequency = frequency + 1 WHERE id = " +
                point.id.toString());
        print("Incremented frequency for point with id " + point.id.toString());
      }
    }
  }

  Future<List<LocationPoint>> locationPoints() async {
    // Get a reference to the database.
    final db = await openLocationDB();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('locationPoints');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return LocationPoint(
        id: maps[i]['id'],
        lat: maps[i]['lat'],
        lon: maps[i]['lon'],
        frequency: maps[i]['frequency'],
      );
    });
  }
}
