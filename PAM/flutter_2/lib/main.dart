import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("ch 1"),
            Text("ch 2"),
            Text("ch 3")
          ],
        ),
      ),
    );
  }
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
