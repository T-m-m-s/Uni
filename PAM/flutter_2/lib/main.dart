import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyScaffold extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MyScaffold();

}

class _MyScaffold extends State<MyScaffold> {
  bool? _checkboxValue = false;
  bool _switchValue = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(title: Text("Main screen"), backgroundColor: Colors.amber),
      drawer: Drawer(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Sudo Palle",
                  icon: Icon(Icons.text_fields),
                  //fillColor: Colors.amber,
                  fillColor: Colors.amber,
                  filled: true,
                ),
                onSubmitted: (String value) {
                  String val = value;
                  print(value);
                },
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.amber,
                disabledForegroundColor: Colors.black12,
              ),
              onPressed: () {},
              child: Text("Bottone Palle", style: TextStyle(fontSize: 20)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.amber,
                disabledForegroundColor: Colors.black12,
              ),
              onPressed: () {},
              child: Text("Bottone Sudo", style: TextStyle(fontSize: 20)),
            ),
            Checkbox(
              value: _checkboxValue,
              onChanged: (bool? newvalue){
                setState(() {
                  _checkboxValue = newvalue;
                });
              },
            ),
            Switch(
              value: _switchValue,
              onChanged: (bool newvalue){
                setState(() {
                  _switchValue = newvalue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(child: MyScaffold()),
      );
    }
    if (Platform.isIOS) {
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(child: MyScaffold()),
      );
    }
    return Text("Palle sudate");
  }
}
