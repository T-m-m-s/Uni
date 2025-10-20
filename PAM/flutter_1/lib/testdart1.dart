void main() {
  myPrint(myFunc(), myFun());
  myPrint(myFunc());
  myPr(
    myFunc(),
    s2 : "TROIA"
  );
  myPr(
    myFun()
  );
}

String myStr = "DIOMERDA";
String myFunc() {
  return myStr;
}

String myFun() => "STA ZITTA puttana!";

void myPrint(String s1, [String? s2]) {
  if (s2 != null) {
    print(s1 + " " + s2);
  } else {
    print(s1);
  }
}

void myPr(String s1, {String? s2}) {
  if (s2 != null) {
    print(s1 + " " + s2);
  } else {
    print(s1);
  }
}