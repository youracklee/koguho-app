import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'constant.dart';
import 'util.dart';
import 'dart:async';
import 'person.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'person.dart';

const Duration duration = Duration(milliseconds: DELAY_MILLI);

class Connection {
  final ConnectionStatus cs;
  final dynamic connectionResponse;

  Connection(this.cs, this.connectionResponse);

  ConnectionStatus get status => cs;
  dynamic get response => connectionResponse;
}

//해당 API 주소 반환
Uri getUrl(String path) {
  return Uri.parse('$SERVER_ADDRESS/$path');
}

// //response 메소드 decode
// List<dynamic> getStatus(String responseCode) {
//   bool success = responseCode.split('/')[0] == '1';
//   String code = responseCode.split('/')[1];
//   return [success, code];
// }

dynamic getMessage(http.StreamedResponse sr) async {
  var response = await http.Response.fromStream(sr);
  var msg = jsonDecode(utf8.decode(response.bodyBytes))['msg'];
  return msg;
}

//이미지 업로드
Future<Connection> uploadImage(File image) async {
  final url = getUrl('upload-image');

  try {
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      var response = await request.send().timeout(duration);
      getToast("이미지가 업로드 되었습니다.");
      return Connection(ConnectionStatus.connected, getMessage(response));
    } on TimeoutException catch (_) {
      getToast("서버 연결 실패");
      return Connection(ConnectionStatus.failed, 'connection failed');
    } catch (e) {
      getToast("네트워크에 연결되지 않음");
      return Connection(ConnectionStatus.offline, 'offline');
    }
  } catch (e) {
    debugPrint(e.toString());
    return Connection(ConnectionStatus.error, 'error');
  }
}

//환자 등록
Future<Connection> addPatients(Person person) async {
  String barcode = person.barcode;
  final url = getUrl('patients-info/$barcode');
  final send = json.encode(person.toJson());
  try {
    var request = await http.post(url, body: send).timeout(duration);
    return Connection(ConnectionStatus.connected, getMessage(request as http.StreamedResponse));
  } on TimeoutException catch (_) {
    return Connection(ConnectionStatus.failed, "connection failed");
  } catch (_) {

  }

  return Connection(ConnectionStatus.error, "error");
}

//등록된 바코드인지 확인
Future<bool> isContains(String barcode) async {
  final url = getUrl('patients-info/iscontains/$barcode');

  try {
    var request = await http.get(url);
    return request.statusCode == 200;
  } catch (e) {
    getToast("네트워크 유실", gravity: ToastGravity.CENTER);
    return false;
  }
}

//환자 이름 불러오기
Future<String> getPatientsName(barcode) async {
  final url = getUrl('patients-info/$barcode');
  var request = await http.get(url);

  return getMessage(request as http.StreamedResponse).toString();
}

//환자 정보 불러오기
Future<List<Person>> getPatientsList() async {
  List<Person> list = [];

  try {
    final url = getUrl('patients-info');
    var request = await http.get(url);
    Map<String, dynamic> msg = jsonDecode(utf8.decode(request.bodyBytes));

    for (var p in msg.keys) {
      Person temp = Person.fromJson(msg[p]);
      list.add(temp);
    }
    return list;
  } catch (e) {
    getToast("네트워크 유실");
    debugPrint(e.toString());
    return list;
  }
}

//오늘 사진을 찍었는지 확인
Future<bool> shotToday(String barcode) async {
  final url = getUrl('shot-today/$barcode');

  try {
    var request = await http.get(url);
    return getMessage(request as http.StreamedResponse).toString() == "True";
  } catch (e) {
    debugPrint(e.toString());
    getToast("네트워크 유실");
    return false;
  }
}
//환자 정보 삭제
Future<bool> deletePatients(String barcode) async {
  final url = getUrl('patients-info/$barcode');
  var request = await http.delete(url);
  // var status = getStatus(request.body);
  // if (status[0]) {
  //   return true;
  // } else {
  //   getToast("이미 삭제된 환자입니다.");
  //   return false;
  // }
  return false;
}

