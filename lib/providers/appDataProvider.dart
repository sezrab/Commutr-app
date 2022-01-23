import 'dart:io';

import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/models/locationPoint.dart';
import 'package:map_app/utils/haversine.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDataProvider extends ChangeNotifier {
  double lastLat = 0;
  double lastLon = 0;

  double currentLat = 0;
  double currentLon = 0;

  List<LocationPoint> markers = [];

  List<dynamic> route = [];

  void setMarkers(List<LocationPoint> points) async {
    markers = points;
    notifyListeners();
  }

  void setRoute(List<dynamic> r) {
    route = r;
    notifyListeners();
  }

  void unsetMarkers() {
    markers = [];
    notifyListeners();
  }

  Future<bool> deleteLocationDB() async {
    File dbFile = File(join(await getDatabasesPath(), 'locations.db'));
    lastLat = 0;
    lastLon = 0;

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

  Future<void> updateLocation(double lat, double lon) async {
    currentLat = lat;
    currentLon = lon;
    notifyListeners();
    await addLocationPoint(lat, lon);
  }

  Future<void> addLocationPoint(double lat, double lon) async {
    double distFromLast =
        HaversineFormula.fromDegrees(lat, lon, lastLat, lastLon).distance();
    if (!ListEquality().equals([lat, lon], [lastLat, lastLon]) &
        (distFromLast > 0.5)) {
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

  List<LocationPoint> decluster(List<LocationPoint> li) {
    List<LocationPoint> declustered = List.from(li);

    for (var point1 in li) {
      if (declustered.contains(point1)) {
        for (var point2 in li) {
          if (declustered.contains(point1) & (point2 != point1)) {
            if (HaversineFormula.fromDegrees(
                        point1.lat, point1.lon, point2.lat, point2.lon)
                    .distance() <
                60) {
              if (declustered.contains(point2)) {
                declustered.remove(point2);
                point1.frequency += point2.frequency;
              }
            }
          }
        }
      }
    }
    return declustered;
  }

  Future<List<LocationPoint>> getMostVisitedPoints({int n = 5}) async {
    // To qualify, a point must have > 60 frequency ticks, and must be above the 70th percentile of all the frequencies
    List<LocationPoint> locations = await getLocationPoints();

    var Q1 = (0.25 * locations.length).toInt();

    // int(.7*locations.length) : locations.length
    List<LocationPoint> inQ1 = locations.sublist(0, Q1);

    List<LocationPoint> mostVisited = [];

    for (var locationPoint in inQ1) {
      if (locationPoint.frequency > 30) {
        mostVisited.add(locationPoint);
      }
    }

    var mostVisitedDeclustered = decluster(mostVisited);

    if (mostVisitedDeclustered.length < 2) {
      return [];
    } else {
      return mostVisitedDeclustered.sublist(0, n - 1);
    }
  }

  Future<List<LocationPoint>> getLocationPoints() async {
    // Get a reference to the database.
    final db = await openLocationDB();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
        await db.query('locationPoints ORDER BY frequency DESC');
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return decluster(List.generate(maps.length, (i) {
      return LocationPoint(
        id: maps[i]['id'],
        lat: maps[i]['lat'],
        lon: maps[i]['lon'],
        frequency: maps[i]['frequency'],
      );
    }));
  }
}
