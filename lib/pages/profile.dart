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
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
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
                  child: MapView()),
            ),
          ),
          Card(
            color: CustomTheme.accent,
            shadowColor: CustomTheme.accent,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                  future: highestFrequencies(context),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    String v = snapshot.data ?? "No data";
                    return Text(v);
                  }),
            ),
          ),
          Spacer()
        ],
      ),
    );
  }

  Future<String> highestFrequencies(context) async {
    List<LocationPoint> points =
        await Provider.of<AppDataProvider>(context).locationPoints();
    return "Your most visited point has f " + points[0].frequency.toString();
  }
}
