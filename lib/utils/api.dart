import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:map_app/models/locationPoint.dart';

class API {
  static final String server = 'http://192.168.5.150';

  static Future<List<dynamic>> getRoute(
      LocationPoint a, LocationPoint b) async {
    var response = await http.post(
      Uri.parse(server + "/route"),
      body: {
        'a': a.coords(),
        'b': b.coords(),
        'mode': 'cycling',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["route"];
    } else {
      return [];
    }
  }
}
