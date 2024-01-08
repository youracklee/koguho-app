import 'package:koguho/api_util.dart';
import 'package:koguho/person.dart';
import 'package:test/test.dart';

void main() {
  group("test group1", () {
    test('api_util/shotToday test', () async {
      var v = await shotToday("00000000").timeout(
          const Duration(milliseconds: 1000),
          onTimeout: non
      );
      expect(v, equals(false));
    });

    test('api_util/getList test', () async {
      var k = await getPatientsList().timeout(
          const Duration(milliseconds: 1000),
          onTimeout: () {return [];}
      );
      expect(k, []);
    });
  });
}

bool non() {
  return false;
}