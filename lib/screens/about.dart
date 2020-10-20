import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:samaritans/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:http/http.dart' as http;
import 'package:group_radio_button/group_radio_button.dart';

enum Pet { customration, fullration }

class About extends StatefulWidget {
  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  final _status = ["Pending", "Released", "Blocked"];
  String _verticalGroupValue = "Pending";
  Pet _pet = Pet.fullration;

  // TextEditingController wheat = new TextEditingController();
  // TextEditingController pulse = new TextEditingController();
  // TextEditingController oil = new TextEditingController();
  // TextEditingController fafa = new TextEditingController();
  Distribute(double wheat, double oil, double pulse, double fafa) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('wheat', wheat);
    await prefs.setDouble('oil', oil);
    await prefs.setDouble('pulse', pulse);
    await prefs.setDouble('fafa', fafa);
  }

  double wheatdata = 0.0;
  double oildata = 0.0;
  double pulsedata = 0.0;
  double fafadata = 0.0;

  @override
  initState() {
    GetData();
    // final baseURL1 = "http://192.168.43.59:8000/api/master_list/50000";

    // final url = Uri.parse(baseURL1);
    // print(url);
    // final response = await http.get(url);
    // if (response.statusCode == 200) {
    //   var main = jsonDecode(response.body);
    //   print(main);

    // }
  }

  GetData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      wheatdata = prefs.getDouble('wheat')!;
      oildata = prefs.getDouble('oil')!;
      pulsedata = prefs.getDouble('pulse')!;
      fafadata = prefs.getDouble('fafa')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.white,
          ),
          onPressed: () {
            // Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (BuildContext context) {
            //   return MyApp();
            // }));
            // _incrementCounter();

            // showModalBottomSheet(
            //   context: context,
            //   isScrollControlled: true,
            //   builder: (context) {
            //     return Wrap(
            //       children: [
            //         Padding(
            //           padding: const EdgeInsets.symmetric(
            //               horizontal: 8.0, vertical: 2.0),
            //           child: TextField(
            //             controller: wheat,
            //             decoration: InputDecoration(
            //               hintText: "enter wheat",
            //             ),
            //           ),
            //         ),
            //         Padding(
            //           padding: const EdgeInsets.symmetric(
            //               horizontal: 8.0, vertical: 2.0),
            //           child: TextField(
            //             controller: pulse,
            //             decoration: InputDecoration(
            //               hintText: "enter pulse",
            //             ),
            //           ),
            //         ),
            //         Padding(
            //           padding: const EdgeInsets.symmetric(
            //               horizontal: 8.0, vertical: 2.0),
            //           child: TextField(
            //             controller: oil,
            //             decoration: InputDecoration(
            //               hintText: "enter oil",
            //             ),
            //           ),
            //         ),
            //         TextField(
            //           controller: fafa,
            //           decoration: InputDecoration(
            //             hintText: "enter fafa",
            //           ),
            //         ),
            //         Center(
            //             child: ElevatedButton(
            //           child: Text('Distribute'),
            //           //color: Theme.of(context).primaryColor,
            //           onPressed: () {
            //             Distribute(
            //                 double.parse(wheat.text),
            //                 double.parse(oil.text),
            //                 double.parse(pulse.text),
            //                 double.parse(fafa.text));
            //           },
            //         ))
            //       ],
            //     );
            //   },
            // );
          },
        ),
        title: Text('About samaritan'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Card(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      children: [
                        Text(
                            'Samaritan purse is humanitrian organization that works on emergency issues on more than  157 countries '),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
