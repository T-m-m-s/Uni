void main() {
  myPrint(myFunc(), myFun());
  myPrint(myFunc());
  myPr(
    myFunc(),
    s2 : "BRUH"
  );
  myPr(
    myFun()
  );
}

String myStr = "SIUM";
String myFunc() {
  return myStr;
}

String myFun() => "SIUMMING";

void myPrint(String s1, [String? s2]) {
  if (s2 != null) {
    print("$s1 $s2");
  } else {
    print(s1);
  }
}

void myPr(String s1, {String? s2}) {
  if (s2 != null) {
    print("$s1 $s2");
  } else {
    print(s1);
  }
}