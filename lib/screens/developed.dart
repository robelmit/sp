import 'package:flutter/material.dart';
import 'package:samaritans/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Developed extends StatefulWidget {
  @override
  State<Developed> createState() => _DevelopedState();
}

class _DevelopedState extends State<Developed> {
  int countervalue = 0;
  @override
  initState() {
    // TODO: implement initState

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
    countervalue = dbvalue;
    setState(() {});
  }

  _addtostorage(int counter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dbvalue = prefs.getInt('counter')!;
    if (dbvalue != null) {
      await prefs.setInt('counter', dbvalue + counter);
    } else {
      await prefs.setInt('counter', counter);
    }
    int value = prefs.getInt('counter')!;
    setState(() {
      countervalue = value;
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return MyApp();
            }));
          },
        ),
        title: Text('Developed by'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          Center(
            child: Container(
              width: 60.0,
              height: 30.0,
              decoration: BoxDecoration(color: Colors.pink),
              child: TextButton(
                onPressed: () {},
                //color: Colors.pink,
                child: Text("${countervalue}",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
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
      body: Container(
        width: double.infinity,
        height: 500.0,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Card(
            child: Column(
              children: [
                Text(
                  'App developed by',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  'Robel Tsegay',
                  style: TextStyle(color: Color.fromRGBO(140, 139, 63, 1)),
                ),
                Text(
                  'Micky Tesfalem',
                  style: TextStyle(color: Color.fromRGBO(140, 139, 63, 1)),
                ),
                Text(
                  'Tekleab Gebremedhin',
                  style: TextStyle(color: Color.fromRGBO(140, 139, 63, 1)),
                ),
                Text(
                  'Aida Angesom',
                  style: TextStyle(color: Color.fromRGBO(140, 139, 63, 1)),
                ),
                Text(
                  'Yorkabel Ngatu',
                  style: TextStyle(color: Color.fromRGBO(140, 139, 63, 1)),
                ),
                IconButton(
                    onPressed: () {
                      _addtostorage(5);
                    },
                    icon: Icon(Icons.add, color: Colors.red))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
