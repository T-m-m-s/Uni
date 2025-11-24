import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyScaffold extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyScaffold();
}

class _MyScaffold extends State<MyScaffold> {
  //bool? _checkboxValue = false;
  //bool _switchValue = false;
  //int? _radioValue = 1;
  String? email = "";
  String? password = "";
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(title: Text("Main screen"), backgroundColor: Colors.amber),
      drawer: Drawer(),
      body: Center(
        child: Column(
          children: [
            /*Padding(
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
            ),*/
            /*Row(
              children: [
                Radio(
                  value: 1,
                  groupValue: _radioValue,
                  onChanged: (int? newValue){
                    setState(() {
                      _radioValue = newValue;
                    });
                  },
                ),
                Text("Option 1"),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: 2,
                  groupValue: _radioValue,
                  onChanged: (int? newValue){
                    setState(() {
                      _radioValue = newValue;
                    });
                  },
                ),
                Text("Option 2"),
              ],
            )
            */
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                _selectDate(context);
              },
              child: Text("Show DatePicker"),
            ),
            ElevatedButton(
              onPressed: () {
                _selectTime(context);
              },
              child: Text("Show Time"),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "name@company.com",
                      labelText: "Email"
                    ),
                    validator: (String? inVal){
                      if(inVal!.length == 0){
                        return "Please enter email";
                      }
                      return null;
                    },
                    onSaved: (String? inVal){
                      this.email = inVal;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "password",
                      labelText: "Password"
                    ),
                    validator: (String? inVal){
                      if(inVal!.length < 8){
                        return "Need longer password";
                      }
                      return null;
                    },
                    onSaved: (String? inVal){
                      this.password = inVal;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        _formKey.currentState!.save();
                        print("Email: " + this.email.toString());
                        print("Password: " + this.password.toString());
                      };
                    },
                    child: Text("Login"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2028),
      initialDate: DateTime.now(),
    );
    print(selectedDate);
  }

  void _selectTime(BuildContext context) async {
    TimeOfDay? selectedtime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    print(selectedtime);
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
