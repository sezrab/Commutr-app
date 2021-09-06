import 'package:flutter/material.dart';
import 'package:map_app/home.dart';
import 'package:map_app/theme_data.dart';

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
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Sam Berry",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Trueno"),
                ),
                Spacer(),
                IconButton(
                    onPressed: () {},
                    color: Colors.white,
                    icon: Icon(Icons.settings_rounded)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
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
                    Spacer(),
                  ],
                ),
                Row(
                  children: [
                    Spacer(),
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
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
