import 'package:flutter/material.dart';

class Verify extends ChangeNotifier{
 bool istrue=false;
 void changeNotify(bool notify){
   istrue=notify;
   notifyListeners();
 }
}