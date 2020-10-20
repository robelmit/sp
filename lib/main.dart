import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:samaritans/screens/about.dart';
import 'package:samaritans/screens/developed.dart';
import 'package:samaritans/screens/profile.dart';
import 'package:flutter_toastr/flutter_toastr.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Color.fromRGBO(33, 51, 84, 1)),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _scanBarcode = 'Unknown';
  String selectedoption = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

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
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                Profile(id: myid, type: selectedoption)));
      }
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Gfds'),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Alert"),
                      content: const Text("Are you sure to exit app?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            exit(0);
                          },
                         // color: Theme.of(context).primaryColor,
                          child: const Text(
                            "Exit",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ))
          ],
        ),
        drawer: Container(
          width: size.width * 0.7, //<-- SEE HERE
          child: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: [
                const UserAccountsDrawerHeader(
                  // <-- SEE HERE
                  decoration:
                      BoxDecoration(color: Color.fromRGBO(33, 51, 84, 1)),
                  accountName: Text(
                    "Gfds",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  accountEmail: Text(
                    "General food distribution system",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //  currentAccountPicture: FlutterLogo(),
                ),
                // ListTile(
                //   leading: Icon(
                //     Icons.adjust_outlined,
                //   ),
                //   title: const Text('About Gfds'),
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => About()),
                //     );
                //   },
                // ),
                ListTile(
                  leading: Icon(
                    Icons.add_to_queue_rounded,
                  ),
                  title: const Text('Developed by'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Developed()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: Builder(builder: (BuildContext context) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'welcome to Gfds app',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'what are you looking for ?',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 14,
                      ),
                    )),
              ),

              GestureDetector(
                onTap: () {
                  selectedoption = "verify";
                  scanQR();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 250,
                      height: 100,
                      child: Stack(
                        children: [
                          Image.asset(
                            'images/samlogo2.PNG',
                            width: 250,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            width: 250,
                            height: 100,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          const Center(
                            child: Text(
                              'Verification',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  selectedoption = "distibute";
                  scanQR();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 250,
                      height: 100,
                      child: Stack(
                        children: [
                          Image.asset(
                            'images/distribute.PNG',
                            width: 250,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            width: 250,
                            height: 100,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          Center(
                            child: Text(
                              'Distribution',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Text(_scanBarcode)
              /* Container(
                      alignment: Alignment.center,
                      child: Flex(
                          direction: Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(
                                onPressed: () => scanBarcodeNormal(),
                                child: Text('Start barcode scan')),
                            ElevatedButton(
                                onPressed: () => scanQR(),
                                child: Text('Start QR scan')),
                            ElevatedButton(
                                onPressed: () => startBarcodeScanStream(),
                                child: Text('Start barcode scan stream')),
                            Text('Scan result : $_scanBarcode\n',
                                style: TextStyle(fontSize: 20))
                          ])), */
              SizedBox(
                height: 50.0,
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.only(right: 50.0, left: 50.0),
                  // child: Text(
                  //   '\"All we have comes from God and we give it out of His Hand\"',
                  //   style: TextStyle(
                  //       fontSize: 12.0,
                  //       color: Color.fromRGBO(140, 139, 63, 1)),
                  // )
                ),
              )
            ],
          );
        }));
  }
}
