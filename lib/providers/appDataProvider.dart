import 'dart:io';
import 'dart:math';

import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/models/locationPoint.dart';
import 'package:map_app/utils/haversine.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDataProvider extends ChangeNotifier {
  String _dbFileName = 'locations.db';

  // previous updated position
  double lastLat = 0;
  double lastLon = 0;

  // most up to date position
  double currentLat = 0;
  double currentLon = 0;

  // the list of markers to plot
  List<LocationPoint> markers = [];

  // the list of coordinates on a polyline
  List<dynamic> route = [];

  void setMarkers(List<LocationPoint> points) async {
    // set the list of markers to plot and notify listeners
    markers = points;
    notifyListeners();
  }

  void setRoute(List<dynamic> r) {
    // set the route (polyline coordinates) list and notify listners
    route = r;
    notifyListeners();
  }

  void unsetMarkers() {
    // unset the markers list and notify listeners
    markers = [];
    notifyListeners();
  }

  Future<bool> deleteLocationDB() async {
    // delete the location database file and notify listeners
    File dbFile = File(
        join(await getDatabasesPath(), _dbFileName)); // obtain db file mame

    lastLat = 0;
    lastLon = 0;
    // reset lastLat and lastLon

    // stop if the database doesn't exist
    if (!dbFile.existsSync()) {
      return false;
    }

    // defensively try to delete the db
    try {
      final db = await openLocationDB();
      // try to close the database if its open
      db.close();

      // delete the file and notify listeners
      await dbFile.delete();
      notifyListeners();

      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<Database> openLocationDB() async {
    // open the location database
    // if there is not an existing database, create it and the relevant tables

    WidgetsFlutterBinding.ensureInitialized();
    String dbPath = await getDatabasesPath();
    // get the directory where the system standardly stores databases

    return openDatabase(
      join(dbPath, _dbFileName), // obtain db file mame
      onCreate: (db, version) {
        // if the database didn't exist, create the locationPoints table using the query below.
        return db.execute(
          'CREATE TABLE locationPoints(id INTEGER PRIMARY KEY NOT NULL, lat DOUBLE NOT NULL, lon DOUBLE NOT NULL, frequency INT NOT NULL);)',
        );
      },
      version: 1,
    );
  }

  Future<void> updateLocation(double lat, double lon) async {
    // notifies all listeners that current lat and lon have been updates. refreshes all geographic map layers and any UI listening.
    currentLat = lat;
    currentLon = lon;

    notifyListeners();
    await addLocationPoint(lat, lon);
  }

  Future<void> addLocationPoint(double lat, double lon) async {
    var threshDistance = 10; // min distance for realtime clustering

    double distFromLast =
        HaversineFormula.fromDegrees(lat, lon, lastLat, lastLon).distance();
    // the distance from the last location point that was added

    if (!ListEquality().equals([lat, lon], [lastLat, lastLon]) &
        (distFromLast > 0.5)) {
      // if we have actually moved away from the last point

      lastLat = lat;
      lastLon = lon;

      print("Adding " + lat.toString() + ", " + lon.toString());
      List<LocationPoint> points = await getLocationPoints();

      // below: realtime clustering (avoid adding unnecessary noise to the data)
      // creates a list of points that are less than the threshold distance away
      List<LocationPoint> nearbyPoints = [];
      for (var point in points) {
        double distance =
            HaversineFormula.fromDegrees(lat, lon, point.lat, point.lon)
                .distance();
        if (distance <= threshDistance) {
          nearbyPoints.add(point);
        }
      }

      final db = await openLocationDB();
      // init the db

      // if there are no nearby points
      if (nearbyPoints.isEmpty) {
        // store this location point as a new point with freq 1
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
        // there are nearby points, so increment their frequencies instead of creating a new location point
        // (realtime clustering)
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
    double threshDistance = 50;
    // distance at which a point is merged with a neighboring point

    List<LocationPoint> declustered = List.from(li);
    // make a copy of "li"

    for (var point1 in li) {
      // iterate over points in li

      if (declustered.contains(point1)) {
        for (var point2 in li) {
          // calculate distance from this point to every other point

          if (declustered.contains(point1) & (point2 != point1)) {
            if (HaversineFormula.fromDegrees(
                        point1.lat, point1.lon, point2.lat, point2.lon)
                    .distance() <
                threshDistance) {
              if (declustered.contains(point2)) {
                declustered.remove(point2);
                // if less than the threshold distance, remove from copy list.

                declustered
                    .firstWhere((dpoint) => dpoint.id == point1.id)
                    .frequency += point2.frequency;
                // increase the frequency of point1 in the declustered list              }
              }
            }
          }
        }
      }
    }
    return declustered;
  }

  Future<List<LocationPoint>> getMostVisitedPoints({int n = 5}) async {
    // To qualify, a point must have > 30 frequency ticks, and must be in the top quartile of all the frequencies
    var threshFreq = 30;

    List<LocationPoint> locations = await getLocationPoints();
    // get all location points

    var Q1 = (0.25 * locations.length).toInt();
    // calculate Q1

    List<LocationPoint> inQ1 = locations.sublist(0, Q1);
    // get the items in the list of Q1

    List<LocationPoint> mostVisited = [];
    for (var locationPoint in inQ1) {
      // if a location point is in the top quartile and has a frequency above the threshhold
      if (locationPoint.frequency > threshFreq) {
        mostVisited.add(locationPoint);
        // add it to the most visited list
      }
    }

    var mostVisitedDeclustered = decluster(mostVisited);
    // decluster the list

    if (mostVisitedDeclustered.length < 2) {
      return [];
      // if there aren't more than two points in the list, the data is not useful, so return an empty list
    } else {
      // return the list up to n (unless the list length is smaller than n)
      return mostVisitedDeclustered.sublist(
          0, min(n - 1, mostVisitedDeclustered.length - 1));
    }
  }

  Future<List<LocationPoint>> getLocationPoints() async {
    // open the database
    final db = await openLocationDB();

    // get the location points in descending order by frequency as a list of string:dynamic maps.
    final List<Map<String, dynamic>> maps =
        await db.query('locationPoints ORDER BY frequency DESC');

    // convert the list of maps to a list of LocationPoint objects, and apply the decluster algorithm
    // return this list
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
