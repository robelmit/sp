import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:http/http.dart' as http;

class Api {
  static final baseURL = "http://192.168.43.59:8000/api/master_list";
  static var isnowdistributed = false;
  static var isnowverified = false;

//  http://192.168.43.59:8000/api/master_list/1
  Future<dynamic> fetchprofile(var id, BuildContext context) async {
    final url = Uri.parse(baseURL + "/$id");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      //return Post.fromJson(jsonDecode(response.body));
      print('fetching user was successful');
      var miki = jsonDecode(response.body);
      print(miki['full_name']);
      print(miki);
//

      //return jsonDecode(response.body);
      return jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
    } else {
      FlutterToastr.show("error loading profile details", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red,
          textStyle: TextStyle(color: Colors.white));
      print('Failed to load profile: ');
      throw Exception('Failed to load profile: ');
    }
  }
}
