import 'package:flutter/material.dart';
import 'package:map_app/pages/home.dart';
import 'package:map_app/views/map_view.dart';
import 'package:map_app/utils/theme_data.dart';

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
          Card(
              color: CustomTheme.accent,
              shadowColor: CustomTheme.accent,
              elevation: 15,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.white,
                      ),
                    ),
                    // Spacer(),
                    Text(
                      "My Places",
                      style: CustomTheme.regular,
                    ),
                  ],
                ),
              )),
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
          Spacer()
        ],
      ),
    );
  }
}
