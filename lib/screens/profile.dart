import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:samaritans/models/verify.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api.dart';
import '../main.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class Profile extends StatefulWidget {
  var id;
  var type;

  Profile({Key? key, required this.id, required this.type});

  @override
  State<Profile> createState() => _ProfileState();
}

enum Pet { customration, fullration }

class _ProfileState extends State<Profile> {
  TextEditingController wheat = new TextEditingController();
  TextEditingController pulse = new TextEditingController();
  TextEditingController oil = new TextEditingController();
  TextEditingController fafa = new TextEditingController();
  Pet _pet = Pet.fullration;

  final Api api = Api();
  var isnowdistributed = false;
  var isnowverified = false;
  String nowverifytext = "not verified";
  TextStyle verifystyle = TextStyle(
      fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.redAccent);
  TextStyle distributstyle = TextStyle(
      fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.redAccent);
  String nowdistributetext = "not distibuted";
  static final baseURL1 = "http://192.168.43.59:8000/master_list";
  double wheatdata = 0.0;
  double oildata = 0.0;
  double pulsedata = 0.0;
  double fafadata = 0.0;
  int countervalue = 0;
  bool shouldcontinue = false;
  var _scanBarcode;

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      if (_scanBarcode != "-1") {
        print('this is right');
        var myid = barcodeScanRes.substring(11);
        // var myid = 11;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    Profile(id: myid, type: widget.type)),
            ModalRoute.withName("/profile"));
      }
    });
  }

  @override
  initState() {
    GetData();
    mountask();
  }

  _resetCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', 0);
    int value = prefs.getInt('counter')!;
    setState(() {
      countervalue = value;
    });
  }

  mountask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dbvalue = prefs.getInt('counter')!;
    setState(() {
      if (dbvalue == null) {
        countervalue = 0;
      } else {
        countervalue = dbvalue;
      }
    });
  }

  Future<String> checkstorage(int counter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dbvalue = prefs.getInt('counter')!;
    if ((dbvalue + counter) > 50) {
      return 'greater';
    } else if (dbvalue + counter == 50) {
      return 'equal';
    } else {
      return 'false';
    }
  }

  _addtostorage(int counter, context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dbvalue = prefs.getInt('counter')!;

    if (dbvalue != null) {
      if ((dbvalue + counter) > 50) {
        FlutterToastr.show(
            "The family size exceeds 50 please add lower family size", context,
            duration: 5,
            position: FlutterToastr.bottom,
            backgroundColor: Colors.red,
            textStyle: TextStyle(color: Colors.white));
      } else if (dbvalue + counter == 50) {
        FlutterToastr.show(
            "You have successfully distributed 50 beneficiaries reset now to continue ",
            context,
            duration: 10,
            position: FlutterToastr.bottom,
            backgroundColor: Colors.green,
            textStyle: TextStyle(color: Colors.white));
        await prefs.setInt('counter', dbvalue + counter);
        setState(() {
          shouldcontinue = true;
        });
      } else {
        await prefs.setInt('counter', dbvalue + counter);
        setState(() {
          shouldcontinue = true;
        });
      }
    } else {
      await prefs.setInt('counter', counter);
      setState(() {
        shouldcontinue = true;
      });
    }
    int value = prefs.getInt('counter')!;
    setState(() {
      countervalue = value;
    });
  }

  GetData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      wheatdata = prefs.getDouble('wheat')!;
      oildata = prefs.getDouble('oil')!;
      pulsedata = prefs.getDouble('pulse')!;
      fafadata = prefs.getDouble('fafa')!;
      if (wheatdata != null && wheatdata != 0) {
        wheat.text = wheatdata.toString();
      }
      if (pulsedata != null && pulsedata != 0) {
        pulse.text = pulsedata.toString();
      }
      if (oildata != null && oildata != 0) {
        oil.text = oildata.toString();
      }
      if (fafadata != null && fafadata != 0) {
        fafa.text = oildata.toString();
      }
    });
  }

  Future<dynamic> verify(var id, BuildContext context) async {
    final url = Uri.parse(baseURL1 + "/verify" + "/$id");
    print(url);
    final response = await http.post(url);
    if (response.statusCode == 200) {
      //return Post.fromJson(jsonDecode(response.body));
      print('verifying user was successful');
      isnowverified = true;
      setState(() {
        nowverifytext = "verified";
        verifystyle = TextStyle(
            fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.green);
      });
      FlutterToastr.show("Verifying user was succesful", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.green,
          textStyle: TextStyle(color: Colors.white));

      return jsonDecode(response.body);
    }
    if (response.statusCode == 304) {
      //return Post.fromJson(jsonDecode(response.body));
      FlutterToastr.show("User is already verified", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.yellowAccent,
          textStyle: TextStyle(color: Colors.black45));
      return jsonDecode(response.body);
    } else {
      FlutterToastr.show("Error verifying user", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red,
          textStyle: TextStyle(color: Colors.white));
      throw Exception('Failed to verify profile: ');
    }
  }

  Future<dynamic> distribute(
      var id, BuildContext context, int familysize) async {
    final url = Uri.parse(baseURL1 + "/distribute" + "/$id");
    final response = await http.post(url);
    if (response.statusCode == 200) {
      print('distribution   was successful');
      isnowdistributed = true;
      _addtostorage(familysize, context);

      //return Post.fromJson(jsonDecode(response.body));
      setState(() {
        nowdistributetext = "distributed";
        distributstyle = TextStyle(
            fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.green);
      });
      FlutterToastr.show("Distribution was sucessful", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.green,
          textStyle: TextStyle(color: Colors.white));
      return jsonDecode(response.body);
    }
    if (response.statusCode == 304) {
      //return Post.fromJson(jsonDecode(response.body));
      FlutterToastr.show("Already distributed", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.yellowAccent,
          textStyle: TextStyle(color: Colors.black45));
      return jsonDecode(response.body);
    }
    if (response.statusCode == 405) {
      //return Post.fromJson(jsonDecode(response.body));
      FlutterToastr.show("User is not verified ,verify first", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.yellowAccent,
          textStyle: TextStyle(color: Colors.black45));
      return jsonDecode(response.body);
    } else {
      FlutterToastr.show("Failed to distribute ", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red,
          textStyle: TextStyle(color: Colors.white));
      throw Exception('Failed to distribute: ');
    }
  }

  Future<dynamic> distributepro(var id, BuildContext context, double cerial,
      double oil, double pulse, double csb, int familysize) async {
    // if(shouldcontinue ==true){

    // }

    if (oil == null || pulse == null || csb == null || cerial == null) {
      FlutterToastr.show("Please input all the values  ", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red,
          textStyle: TextStyle(color: Colors.white));
      return null;
    }
    final url = Uri.parse(baseURL1 + "/distribute" + "/$id");
    //final response = await http.post(url);
    print(cerial);
    print(oil);
    print(pulse);
    print(csb);

    final response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, double>{
          '_cereal': cerial,
          '_oil': oil,
          '_pulse': pulse,
          '_csb': csb,
        }));
    if (response.statusCode == 200) {
      print('distribution   was successful');
      isnowdistributed = true;
      _addtostorage(familysize, context);

      //return Post.fromJson(jsonDecode(response.body));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('wheat', cerial);
      await prefs.setDouble('oil', oil);
      await prefs.setDouble('pulse', pulse);
      await prefs.setDouble('fafa', csb);
      setState(() {
        nowdistributetext = "distributed";
        distributstyle = TextStyle(
            fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.green);
      });
      FlutterToastr.show("Distribution was sucessful", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.green,
          textStyle: TextStyle(color: Colors.white));
      Navigator.pop(context);
      return jsonDecode(response.body);
    }
    if (response.statusCode == 304) {
      //return Post.fromJson(jsonDecode(response.body));
      FlutterToastr.show("Already distributed", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.yellowAccent,
          textStyle: TextStyle(color: Colors.black45));
      Navigator.pop(context);
      return jsonDecode(response.body);
    }
    if (response.statusCode == 405) {
      //return Post.fromJson(jsonDecode(response.body));
      FlutterToastr.show("User is not verified ,verify first", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.yellowAccent,
          textStyle: TextStyle(color: Colors.black45));
      Navigator.pop(context);
      return jsonDecode(response.body);
    } else {
      FlutterToastr.show("Failed to distribute ", context,
          duration: 5,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red,
          textStyle: TextStyle(color: Colors.white));
      Navigator.pop(context);

      throw Exception('Failed to distribute: ');
    }
  }

  @override
  Widget build(BuildContext context) {
    // bool status = context.watch<Verify>().istrue;

    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_sharp),
            color: Colors.white,
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return MyApp();
              }));
            },
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            Center(
                child: Container(
              width: 60.0,
              height: 30.0,
              decoration: BoxDecoration(color: Colors.greenAccent),
              child: TextButton(
                onPressed: () {},
           //     color: Colors.transparent,
                child: Text("${countervalue}",
                    style: TextStyle(color: Colors.white)),
              ),
            )),
            PopupMenuButton<String>(onSelected: (value) {
              if (value == 'reset') {
                _resetCounter();
              }
            }, itemBuilder: (
              BuildContext context,
            ) {
              return [
                // PopupMenuItem(
                //   child: Text('Start Counter'),
                //   value: "start",
                // ),
                PopupMenuItem(
                  child: Text('Reset Counter'),
                  value: "reset",
                ),
              ];
            })
          ],
        ),
        body: FutureBuilder(
            future: api.fetchprofile(widget.id, context),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                var response = snapshot.data;

                //List<int> intList = List<int>.from(response['full_name']);

                // String result = new Utf8Decoder().convert(intList);
                // print(result);

                return SingleChildScrollView(
                  child: Container(
                    color: Colors.black12.withOpacity(0.1),
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Column(
                        children: [
                          ClipOval(
                            child: Material(
                              color: Colors.transparent,
                              child: Ink.image(
                                // (response['sex']=="M")
                                image: (response['sex'] == "M")
                                    ? AssetImage('images/male.png')
                                    : AssetImage('images/female.png'),
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                child: InkWell(
                                  onTap: () {},
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                response['full_name'],
                                //jsonDecode(utf8.decode( response['full_name'], allowMalformed: true)),

                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Age',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        response['age'].toString(),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Text('TFS',
                                          style: TextStyle(fontSize: 12)),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        response['total_family_size']
                                            .toString(),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Text('Sex',
                                          style: TextStyle(fontSize: 12)),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        response['sex'],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          (response['residence_status'] == 'idp')
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Ozone',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(response['origin_zone']),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Text('Owereda',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(response['origin_woreda']),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Czone',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(response['current_zone']),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Text('Cwereda',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                    response['current_woreda']),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Ckebele',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  response['current_kebelle'],
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Zone',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(response['current_zone']),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Text('Owereda',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                    response['current_woreda']),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Kebele',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(response[
                                                    'current_kebelle']),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Text('Ketena',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(response['current_qushet']
                                                    .toString())
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(
                            height: 10.0,
                          ),
                          (widget.type == "distibute")
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ListTile(
                                            title: const Text('Full ration'),
                                            leading: Radio<Pet>(
                                              value: Pet.fullration,
                                              groupValue: _pet,
                                              onChanged: (Pet? value) {
                                                setState(() {
                                                  _pet = value!;
                                                  print(_pet);
                                                });
                                              },
                                            ),
                                          ),
                                          ListTile(
                                            title: const Text('Custom ration'),
                                            leading: Radio<Pet>(
                                              value: Pet.customration,
                                              groupValue: _pet,
                                              onChanged: (Pet? value) {
                                                setState(() {
                                                  _pet = value!;
                                                  print(value);
                                                  if (value ==
                                                      Pet.customration) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            "Enter custom ration"),
                                                        content:
                                                            SingleChildScrollView(
                                                          child: Wrap(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        2.0),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          TextField(
                                                                        controller:
                                                                            wheat,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          hintText:
                                                                              "enter wheat",
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'Wheat',
                                                                      style: TextStyle(
                                                                          color: Theme.of(context)
                                                                              .primaryColor,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          fontSize:
                                                                              14.0),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        2.0),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          TextField(
                                                                        controller:
                                                                            pulse,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          hintText:
                                                                              "enter pulse",
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'Pulse',
                                                                      style: TextStyle(
                                                                          color: Theme.of(context)
                                                                              .primaryColor,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          fontSize:
                                                                              14.0),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        2.0),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          TextField(
                                                                        controller:
                                                                            oil,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          hintText:
                                                                              "enter oil",
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'Oil',
                                                                      style: TextStyle(
                                                                          color: Theme.of(context)
                                                                              .primaryColor,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          fontSize:
                                                                              14.0),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          TextField(
                                                                        controller:
                                                                            fafa,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          hintText:
                                                                              "enter csb",
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'Csb',
                                                                      style: TextStyle(
                                                                          color: Theme.of(context)
                                                                              .primaryColor,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          fontSize:
                                                                              14.0),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              if (response[
                                                                      'is_distributed'] ||
                                                                  nowdistributetext ==
                                                                      "distributed") {
                                                              } else {
                                                                distributepro(
                                                                    widget.id,
                                                                    context,
                                                                    double.parse(
                                                                        wheat
                                                                            .text),
                                                                    double.parse(oil
                                                                        .text),
                                                                    double.parse(
                                                                        pulse
                                                                            .text),
                                                                    double.parse(
                                                                        fafa
                                                                            .text),
                                                                    response[
                                                                        'total_family_size']);
                                                              }
                                                            },
                                                            // color: Theme.of(
                                                            //         context)
                                                            //     .primaryColor,
                                                            child: const Text(
                                                              "Distribute",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    print('full ration');
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      )))
                              : SizedBox(height: 1),
                          // (widget.type == "distibute")
                          //     ? Padding(
                          //         padding: EdgeInsets.all(10.0),
                          //         child: Row(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             Text('Custom ration'),
                          //             LiteRollingSwitch(
                          //               //initial value
                          //               value: false,
                          //               textOn: 'on',
                          //               textOff: 'off',
                          //               colorOn: Colors.greenAccent[700],
                          //               colorOff: Colors.redAccent[700],
                          //               iconOn: Icons.done,
                          //               iconOff: Icons.remove_circle_outline,
                          //               textSize: 16.0,
                          //               onChanged: (bool state) {
                          //                 if (state == true) {

                          //                 }
                          //                 //Use it to manage the different states
                          //                 print(
                          //                     'Current State of SWITCH IS: $state');
                          //               },
                          //             ),
                          //           ],
                          //         ),
                          //       )
                          //     : SizedBox(
                          //         height: 1.0,
                          //       ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 18.0, right: 18.0, bottom: 10.0),
                            child: Row(
                              children: [
                                Text(
                                  'Verification status',
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                                (response['is_verified'] == true)
                                    ? Text(
                                        'verified',
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.green),
                                      )
                                    : Text(
                                        '$nowverifytext',
                                        style: verifystyle,
                                      ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 18.0, right: 18.0),
                            child: Row(
                              children: [
                                Text('Distibution status',
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold)),
                                Spacer(),
                                (response['is_distributed'] == true)
                                    ? Text(
                                        'distibuted',
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.green),
                                      )
                                    : Text(
                                        '$nowdistributetext',
                                        style: distributstyle,
                                      )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            width: double.infinity,
                            height: 60.0,
                            child: (widget.type == "verify")
                                ? TextButton(
                                    onPressed: () {
                                      verify(widget.id, context);
                                    },
                                    child: Text(
                                      'Verify',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                   // color: Theme.of(context).primaryColor,
                                  )
                                : TextButton(
                                    onPressed: () async {
                                      if (response['is_distributed'] ||
                                          nowdistributetext == "distributed") {
                                      } else {
                                        print('checking storage');
                                        var responsefinal = await checkstorage(
                                            response['total_family_size']);
                                        print(responsefinal);
                                        if (responsefinal == "greater") {
                                          FlutterToastr.show(
                                              "The family size exceeds 50 please add lower family size",
                                              context,
                                              duration: 5,
                                              position: FlutterToastr.bottom,
                                              backgroundColor: Colors.red,
                                              textStyle: TextStyle(
                                                  color: Colors.white));
                                        } else if (responsefinal == "false") {
                                          distribute(widget.id, context,
                                              response['total_family_size']);
                                        } else if (responsefinal == "equal") {
                                          distribute(widget.id, context,
                                              response['total_family_size']);
                                        }
                                      }
                                    },
                                    child: Text(
                                      'Distribute',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  //  color: Theme.of(context).primaryColor,
                                  ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {
                                  scanQR();
                                },
                                child: Text(
                                  'Scan another',
                                  style: TextStyle(color: Colors.white),
                                ),
                              //  color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }
}




    /* return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          centerTitle: true,
        ),
       body:

        SingleChildScrollView(
         child: Container(
           color: Colors.black12.withOpacity(0.1),
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(children: [
                ClipOval(child: Material(
                  color: Colors.transparent,
                  child: Ink.image(
                    image: AssetImage('images/photo.jpg'), width: 70, height: 70,
                    fit: BoxFit.cover,
                    child: InkWell(onTap: () {},),
                  ),
                ),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      Text('Nahom hailu tesfu',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),

                  ],),
                Container(
                  padding: const EdgeInsets.all(1.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(children: [
                          Text('Age',style: TextStyle(fontSize: 14),),
                          SizedBox(height: 5.0,),
                          Text('24',style: TextStyle(fontSize: 12),),
                        ],),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(children: [
                          Text('TFS',style: TextStyle(fontSize: 12)),
                          SizedBox(height: 5.0,),
                          Text('12',style: TextStyle(fontSize: 12),),
                        ],),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(children: [
                          Text('Sex',style: TextStyle(fontSize: 12)),
                          SizedBox(height: 5.0,),
                          Text('M',style: TextStyle(fontSize: 12),),
                        ],),
                      ),

                    ],),
                ),
                  Padding(
                    padding: const EdgeInsets.only(left:15.0,right:15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(children: [
                          Text('Ozone',style: TextStyle(fontSize: 16),),
                          SizedBox(height: 5.0,),
                          Text('central'),
                        ],),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(children: [
                          Text('Owereda',style: TextStyle(fontSize: 16)),
                          SizedBox(height: 5.0,),
                          Text('Adwa city'),
                        ],),
                      ),

                    ],),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left:15.0,right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(children: [
                          Text('Czone',style: TextStyle(fontSize: 16),),
                          SizedBox(height: 5.0,),
                          Text('central'),
                        ],),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(children: [
                          Text('Cwereda',style: TextStyle(fontSize: 16)),
                          SizedBox(height: 5.0,),
                          Text('Adwa city'),
                        ],),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(children: [
                          Text('Ckebele',style: TextStyle(fontSize: 14),),
                          SizedBox(height: 5.0,),
                          Text('Hadnet IDP',style: TextStyle(fontSize: 12),),
                        ],),
                      ),

                    ],),
                ),

                SizedBox(height: 10.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0,right: 18.0,bottom: 10.0),
                  child: Row(children: [
                    Text('Verification status',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                    Spacer(),
                    Text('not verified',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.w400,color: Colors.redAccent),)
                  ],),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0,right: 18.0),
                  child: Row(children: [
                    Text('Distibution status',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                    Spacer(),
                    Text('distributed',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.w400,color: Colors.green))
                  ],),
                ),
                SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  height: 60.0,
                  child:TextButton(onPressed: (){},child: Text('Distribute',style: TextStyle(color: Colors.white),),color: Theme.of(context).primaryColor,)
                  ,
                )

              ],
              ),
            ),
          ),
       )
    ) */