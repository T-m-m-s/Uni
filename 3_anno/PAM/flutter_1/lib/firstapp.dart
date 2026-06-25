import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_1/testdart2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    if(Platform.isAndroid) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
            child: MyScaffold()
        ),
      );
    }
    if(Platform.isIOS) {
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
            child: MyScaffold()
        ),
      );
    }
    return Text("Palle sudate");
  }
}