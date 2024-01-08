import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:koguho/constant.dart';
import 'package:fluttertoast/fluttertoast.dart';

Text getText(String string) {
  return Text(string, style: DEFAULT_TEXTSTYLE, textAlign: TextAlign.center,);
}

void getToast(String msg,
    {
      ToastGravity gravity = ToastGravity.BOTTOM,
      Color backgroundColor = TOAST_BACKGROUND_DEFAULT_COLOR,
      Color textColor = TOAST_TEXT_DEFAULT_COLOR,
      double size = 30,
      Toast toastLength = Toast.LENGTH_SHORT
    }
    ) {
  Fluttertoast.showToast(
      msg: msg,
      gravity: gravity,
      backgroundColor: backgroundColor,
      fontSize: size,
      toastLength: toastLength,
      textColor: textColor
  );
}

Future<dynamic> getAlertDialog(BuildContext context, String error) {
  return showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(error, style: ALERT_DIALOG_TEXTSTYLE),
          actions: [
            CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        );
      }
  );
}

String nowString() {
  List<String> temp = DateTime.now().toString().split(" ");
  String onlyDate = temp[0];
  String onlyTime = temp[1];
  String hour = onlyTime.split(":")[0];
  String minute = onlyTime.split(":")[1];
  String second = onlyTime.split(":")[2].split(".")[0];
  return "$onlyDate-$hour-$minute-$second";
}

///Todo util.dart 및 constant.dart 편의성 개선 (안해도 됨)
