import 'package:flutter/material.dart';
import 'testclass.dart';

void main() {
  Employee e1 = Employee.bugo("BUGO","BUGO");
  Employee e2 = Employee.frank("FRANK","METANO");
  Employee e3 = Employee(
      firstName: "Mario",
      lastName: "Sturniolo"
  );
  Employee e4 = Employee(
      firstName: "Marione"
  );

  print(e1.fullName);
  print(e2.fullName);
  print(e3.fullName);
  print(e4.fullName);

  //print(e1.firstName);
  //e1.lastName="GAY";
  //print(e1.getFullName());
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