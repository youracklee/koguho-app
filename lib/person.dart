
class Person {
  late String _name;
  late String _barcode;
  late String _gender;
  late String _birth;
  bool _shotToday = false;
  String _recentShotDate = " ";

  Person(this._name, this._barcode, this._gender, this._birth);

  Person.fromJson(Map<String, dynamic> info) {
    _name = info['name'] ?? " ";
    _barcode = info['barcode'] ?? " ";
    _gender = info['gender'] ?? " ";
    _birth = info['birth'] ?? " ";
    _recentShotDate = info['recentShotDate'] ?? " ";
  }

  Map<String, dynamic> toJson() {
    return {
      'name' : _name,
      'barcode' : _barcode,
      'gender' : _gender,
      'birth' : _birth,
      'recentShotDate' : _recentShotDate
    };
  }

  @override
  String toString() {
    return 'Person{_name: $_name, _barcode: $_barcode, _gender: $_gender,  _birth: $_birth}';
  }

  String get birth => _birth;

  set birth(String value) {
    _birth = value;
  }

  String get gender => _gender;

  set gender(String value) {
    _gender = value;
  }

  String get barcode => _barcode;

  set barcode(String value) {
    _barcode = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  bool get shotToday => _shotToday;

  set shotToday(bool value) {
    _shotToday = value;
  }

  String get recentShotDate => _recentShotDate;

  set recentShotDate(String value) {
    _recentShotDate = value;
  }

  bool shot() {
    DateTime now = DateTime.now();
    return _recentShotDate == DateTime(now.year, now.month, now.day).toString().split(" ")[0];
  }
}