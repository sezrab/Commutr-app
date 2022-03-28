import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:map_app/models/locationPoint.dart';
import 'package:map_app/pages/home.dart';
import 'package:map_app/providers/appDataProvider.dart';
import 'package:map_app/views/map_view.dart';
import 'package:map_app/utils/theme_data.dart';
import 'package:provider/provider.dart';

class Technical extends StatefulWidget {
  const Technical({Key? key}) : super(key: key);

  @override
  _TechnicalState createState() => _TechnicalState();
}

class _TechnicalState extends State<Technical> {
  MapView mapView = MapView();
  bool allMarkersToggled = false;
  @override
  Widget build(BuildContext context) {
    List<LocationPoint> points =
        Provider.of<AppDataProvider>(context, listen: true).markers;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        )
                      ]),
                  child: ClipRRect(
                    child: mapView,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
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
                              ? "Info: Load some data first"
                              : "Your most visited point has frequency " +
                                  points[0].frequency.toString(),
                          style: CustomTheme.regular,
                        ),
                      ),
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
                              ? "Info: Load some data first"
                              : "You have " +
                                  points.length.toString() +
                                  " points",
                          style: CustomTheme.regular,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: true,
                        child: TextButton(
                          onPressed: () async {
                            // on pressing the load data card
                            if (allMarkersToggled) {
                              Provider.of<AppDataProvider>(context,
                                      listen: false)
                                  .unsetMarkers();
                              // if "show all markers" is already toggled, hide all markers
                            } else {
                              Provider.of<AppDataProvider>(context,
                                      listen: false)
                                  .setMarkers(
                                      await Provider.of<AppDataProvider>(
                                              context,
                                              listen: false)
                                          .getLocationPoints());
                              // else show all markers
                            }
                            allMarkersToggled = !allMarkersToggled;
                            // change the toggle after pressing
                            setState(() {}); // refresh the state
                          },
                          child: Text(
                              allMarkersToggled
                                  ? "Unload data"
                                  : "All Data (debug)",
                              style: CustomTheme.regular),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            )),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey.shade800),
                          ),
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () async {
                          // same as above, apart from it only loads the most visited points as markers
                          if (allMarkersToggled) {
                            Provider.of<AppDataProvider>(context, listen: false)
                                .unsetMarkers();
                          } else {
                            Provider.of<AppDataProvider>(context, listen: false)
                                .setMarkers(await Provider.of<AppDataProvider>(
                                        context,
                                        listen: false)
                                    .getMostVisitedPoints());
                          }
                          allMarkersToggled = !allMarkersToggled;

                          setState(() {});
                        },
                        child: Text(
                            allMarkersToggled
                                ? "Unload data"
                                : "Load most visited points",
                            style: CustomTheme.regular),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          )),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.green.shade900),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  TextButton(
                    onPressed: () async {
                      bool success = await Provider.of<AppDataProvider>(context,
                              listen: false)
                          .deleteLocationDB();
                      Provider.of<AppDataProvider>(context, listen: false)
                          .unsetMarkers();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success
                              ? "Deleted database"
                              : "Couldn't delete database")));
                      // delete the db
                    },
                    child: Text(
                      "Delete database",
                      style: CustomTheme.regular,
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      )),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}
