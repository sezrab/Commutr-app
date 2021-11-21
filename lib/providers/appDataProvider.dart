import 'dart:io';

import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/models/locationPoint.dart';
import 'package:map_app/utils/haversine.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDataProvider extends ChangeNotifier {
  double lastLat = 0;
  double lastLon = 0;

  List<LocationPoint> points = [];
  bool markerToggle = false;

  void toggleMarkers() async {
    if (markerToggle == false) {
      points = await getLocationPoints();
      markerToggle = points.isNotEmpty;
    } else {
      points = [];
      markerToggle = false;
    }
    notifyListeners();
  }

  Future<bool> deleteLocationDB() async {
    File dbFile = File(join(await getDatabasesPath(), 'locations.db'));
    if (!dbFile.existsSync()) {
      return false;
    }
    try {
      final db = await openLocationDB();
      db.close();
      await dbFile.delete();
      notifyListeners();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<Database> openLocationDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    String dbPath = await getDatabasesPath();
    // print('db location : ' + join(dbPath, 'locations.db'));
    return openDatabase(
      join(dbPath, 'locations.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE locationPoints(id INTEGER PRIMARY KEY NOT NULL, lat DOUBLE NOT NULL, lon DOUBLE NOT NULL, frequency INT NOT NULL);)',
        );
      },
      version: 1,
    );
  }

  Future<void> addLocationPoint(double lat, double lon) async {
    if ([lat, lon] != [lastLat, lastLon]) {
      lastLat = lat;
      lastLon = lon;

      print("Adding " + lat.toString() + ", " + lon.toString());
      List<LocationPoint> points = await getLocationPoints();

      List<LocationPoint> nearbyPoints = [];

      for (var point in points) {
        double distance =
            HaversineFormula.fromDegrees(lat, lon, point.lat, point.lon)
                .distance();
        // print("distance was " + distance.toString());
        if (distance <= 10) {
          nearbyPoints.add(point);
        }
      }

      final db = await openLocationDB();
      if (nearbyPoints.isEmpty) {
        // insert new
        await db.insert(
          'locationPoints',
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
          print(
              "Incremented frequency for point with id " + point.id.toString());
        }
      }
    }
  }

  Future<List<LocationPoint>> getLocationPoints() async {
    // Get a reference to the database.
    final db = await openLocationDB();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
        await db.query('locationPoints ORDER BY frequency DESC');
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
