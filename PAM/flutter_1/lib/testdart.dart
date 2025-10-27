import 'testclass.dart';
// import 'package:provider/provider.dart';

void main() {
  int myInt = 13;
  String myString = "palle";
  String s2 = myString + "!";
  String s3 = "${myString}!" " palle!";

  var myVar;
  myVar = 13;

  print(myString+"\n");
  print(s2+"\n");
  print(s3+"\n");
  print("SUDO PALLE\n");
  // print(_globalString+"!!!\n"); non worka --> variabile privata

  List list = [1,2,3];
  List<int> listInt = [1,2,3];
  print(list);
  list.addAll([69, "palle"]);
  print(list);
  list.removeAt(3);
  print(list);

  List emptyList = new List.empty(); // List emptyList = []

  Map map = {
    1 : "sudo",
    2 : "palle",
  };
  print(map[1]);
  print(map);
  print(map.keys);
  print(map.values);
  map.remove(1);

  int i = 9;
  String aaa = (i==0 ? "zero" : "palle");
  print(aaa);

  int? j;
  int k = (j ?? 0);

  List listona = [];
  listona.add(0);
  listona..add(1)
  ..add(2)
  ..add(3);
}
