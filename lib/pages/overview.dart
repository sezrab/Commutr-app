import 'package:flutter/material.dart';
import 'package:map_app/models/locationPoint.dart';
import 'package:map_app/providers/appDataProvider.dart';
import 'package:map_app/utils/api.dart';
import 'package:map_app/views/map_view.dart';
import 'package:map_app/utils/theme_data.dart';
import 'package:provider/provider.dart';

class Overview extends StatefulWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  LocationPoint? selected1;
  LocationPoint? selected2;
  MapView mapView = MapView();
  bool allMarkersToggled = false;
  @override
  Widget build(BuildContext context) {
    List<LocationPoint> points =
        Provider.of<AppDataProvider>(context, listen: true).markers;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(2),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    child: Text("Get my routes"),
                    onPressed: () async {
                      Provider.of<AppDataProvider>(context, listen: false)
                          .setMarkers(await Provider.of<AppDataProvider>(
                                  context,
                                  listen: false)
                              .getMostVisitedPoints());
                    },
                  ),
                  buildRouteButtons(points),
                  Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMakeRouteButton(LocationPoint? a, LocationPoint? b) {
    return Visibility(
      child: TextButton(
          onPressed: () async {
            var dat = await API.getRoute(a!, b!);
            if (dat.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("This route couldn't be found!")));
            }
            Provider.of<AppDataProvider>(context, listen: false).setRoute(dat);
          },
          child: Text("Get route")),
      visible: ((a != null) & (b != null)),
    );
  }

  Widget buildRouteButtons(List<LocationPoint> points) {
    List<Widget> li = [];
    for (var i = 0; i < points.length; i++) {
      li.add(Padding(
        padding: const EdgeInsets.all(2.0),
        child: TextButton(
            onPressed: () {
              if (points[i] == selected1) {
                selected1 = null;
              } else if (points[i] == selected2) {
                selected2 = null;
              } else if (selected1 == null) {
                selected1 = points[i];
              } else if (selected2 == null) {
                selected2 = points[i];
              } else {
                selected2 = selected1;
                selected1 = points[i];
              }
              setState(() {});
            },
            style: ButtonStyle(
                backgroundColor:
                    ((points[i] == selected1) | (points[i] == selected2))
                        ? MaterialStateProperty.all<Color>(
                            CustomTheme.accent.withOpacity(0.1))
                        : null),
            child: Text((i + 1).toString())),
      ));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: li,
      ),
      buildMakeRouteButton(selected1, selected2),
    ]);
  }
}
