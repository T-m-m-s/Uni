class Employee {
  String _firstName="";
  String _lastName="";

  Employee.bugo(this._firstName,this._lastName);
  Employee.frank(String firstName, String lastName) : _firstName = firstName, _lastName = lastName;
  Employee({required String firstName, String lastName = ""}){
    _firstName = firstName;
    _lastName = "'Nasone' $lastName";
  }

  /*Alt+Ins per il generate
  String get firstName => _firstName;
  String get lastName => _lastName;

  set firstName(String value) {
    _firstName = value;
  }
  set lastName(String value) {
    _lastName = value;
  }
  */

  String get fullName{
    return "$_firstName $_lastName";
  }
}