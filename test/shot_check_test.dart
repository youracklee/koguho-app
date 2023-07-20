import 'package:ediya/api_util.dart';
import 'package:ediya/person.dart';
import 'package:test/test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group("test group1", () {
    test('SharedPreferences test', () async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setInt("hi", 1);
      pref.setBool('hi', false);

      print(pref.getBool('hi'));
      print(pref.getInt('hi'));
    });

    test('api_util/getList test', () async {

    });


  });
}
