import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:map_app/models/locationPoint.dart';
import 'package:map_app/pages/home.dart';
import 'package:map_app/providers/appDataProvider.dart';
import 'package:map_app/views/map_view.dart';
import 'package:map_app/utils/theme_data.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  MapView mapView = MapView();
  @override
  Widget build(BuildContext context) {
    List<LocationPoint> points =
        Provider.of<AppDataProvider>(context, listen: true).points;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                    child: mapView),
              ),
            ),
            Card(
              color: CustomTheme.accent,
              shadowColor: CustomTheme.accent,
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    points.isEmpty
                        ? "No data"
                        : "Your most visited point has frequency " +
                            points[0].frequency.toString(),
                    style: CustomTheme.regular,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextButton(
                    onPressed: () {
                      Provider.of<AppDataProvider>(context, listen: false)
                          .toggleMarkers();
                    },
                    child: Text(
                      Provider.of<AppDataProvider>(context, listen: false)
                              .markerToggle
                          ? "Unload data"
                          : "Load data",
                      style: CustomTheme.regular,
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      )),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(CustomTheme.accent),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextButton(
                    onPressed: () async {
                      bool success = await Provider.of<AppDataProvider>(context,
                              listen: false)
                          .deleteLocationDB();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success
                              ? "Deleted database"
                              : "Couldn't delete database")));
                    },
                    child: Text(
                      "Delete database",
                      style: CustomTheme.regular,
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      )),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(CustomTheme.accent),
                    ),
                  ),
                ),
              ],
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}
