import 'dart:ui';

import 'package:ediya/constant.dart';
import 'package:ediya/sp_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'person.dart';
import 'package:intl/intl.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'api_util.dart';

class SetData extends StatefulWidget {
  final SPHelper helper;

  const SetData(this.helper, {super.key});

  @override
  State<SetData> createState() => _SetDataState();
}

class _SetDataState extends State<SetData> {
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late String _birthDay;
  String _gender = "남자";

  String barcode = "";
  bool detected = false;
  bool birthCheck = false;
  bool genderCheck = false;
  DateTime initDate = DateFormat('yyyy-MM-dd').parse('2000-01-01');
  List<String> genderList = ["남자", "여자", "기타"];

  /// 등록 시 화면을 초기화하기위해 super.initState() 제거함
  /// 문제 시 수정

  @override
  void initState() {
    _nameController = TextEditingController();
    _barcodeController = TextEditingController();
    _birthDay = initDate.toString().split(' ')[0];
    // super.initState();
  }

  void rollBack() {
    detected = false;
    birthCheck = false;
    genderCheck = false;

    _gender = "남자";
    barcode = " ";
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            // The Bottom margin is provided to align the popup above the system navigation bar.
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            // Provide a background color for the popup.
            color: CupertinoColors.systemBackground.resolveFrom(context),
            // Use a SafeArea widget to avoid system overlaps.
            child: SafeArea(top: false, child: child)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
                middle: Text(
              "환자 추가하기",
              style: TITLE_TEXTSTYLE,
            )),
            child: ListView(children: [
              // SizedBox(height: MediaQuery.of(context).size.height / 10),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      decoration: BoxDecoration(
                        color: TEXTFIELD_COLOR,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        CupertinoTextField.borderless(
                          controller: _nameController,
                          padding: TEXT_FIELD_PADDING,
                          prefix: const Text(
                            "이름",
                            textAlign: TextAlign.center,
                            style: DEFAULT_TEXTSTYLE,
                          ),
                          placeholder: '홍길동',
                          cursorHeight: 40,
                          style: DEFAULT_TEXTSTYLE,
                        ),
                        const Divider(
                          thickness: 1,
                          color: DIVIDER_COLOR,
                        ),
                        CupertinoTextField.borderless(
                            padding: BIRTH_FIELD_PADDING,
                            prefix: getText("생년월일"),
                            placeholder: _birthDay,
                            cursorHeight: 40,
                            style: DEFAULT_TEXTSTYLE,
                            readOnly: true,
                            onTap: () {
                              birthCheck = true;
                              _showDialog(CupertinoDatePicker(
                                  minimumYear: 1900,
                                  maximumYear: DateTime.now().year,
                                  initialDateTime: initDate,
                                  maximumDate: DateTime.now(),
                                  onDateTimeChanged: (DateTime newDate) {
                                    setState(() {
                                      _birthDay =
                                          newDate.toString().split(' ')[0];
                                    });
                                  },
                                  mode: CupertinoDatePickerMode.date));
                            }),
                        const Divider(
                          thickness: 1,
                          color: DIVIDER_COLOR,
                        ),
                        CupertinoTextField.borderless(
                            padding: TEXT_FIELD_PADDING,
                            prefix: getText("성별"),
                            placeholder: _gender,
                            cursorHeight: 40,
                            style: DEFAULT_TEXTSTYLE,
                            readOnly: true,
                            onTap: () {
                              genderCheck = true;
                              _showDialog(CupertinoPicker(
                                  itemExtent: 35,
                                  onSelectedItemChanged: (int value) {
                                    setState(() {
                                      _gender = genderList[value];
                                    });
                                  },
                                  children: const [
                                    Text("남자", style: TextStyle(fontSize: 30)),
                                    Text("여자", style: TextStyle(fontSize: 30)),
                                    Text("기타", style: TextStyle(fontSize: 30))
                                  ]));
                            }),
                        const Divider(
                          thickness: 1,
                          color: DIVIDER_COLOR,
                        ),
                        CupertinoTextField.borderless(
                          controller: _barcodeController,
                          padding: BARCODE_FIELD_PADDING,
                          prefix: const Text(
                            "바코드",
                            textAlign: TextAlign.center,
                            style: DEFAULT_TEXTSTYLE,
                          ),
                          placeholder: '(바코드를 스캔하시거나, 직접 입력하세요.)',
                          cursorHeight: 40,
                          style: DEFAULT_TEXTSTYLE,
                        ),
                      ]))),
              SizedBox(height: MediaQuery.of(context).size.height / 10),
              Row(children: [
                SizedBox(width: MediaQuery.of(context).size.width / 1.28),
                Column(children: [
                  CupertinoButton(
                      padding: BUTTON_PADDING,
                      onPressed: () async {
                        var temp = await BarcodeScanner.scan(
                            options: const ScanOptions(useCamera: 1));
                        barcode = temp.rawContent;
                        detected = barcode != "";
                        setState(() {
                          _barcodeController.text = barcode;
                        });
                      },
                      color: BUTTON_COLOR,
                      borderRadius: BorderRadius.circular(10),
                      child: const Text("바코드", style: BUTTON_TEXTSTYLE)),
                  SizedBox(height: MediaQuery.of(context).size.height / 90),
                  CupertinoButton(
                    padding: BUTTON_PADDING,
                    onPressed: () async {
                      barcode = _barcodeController.text;
                      if (_nameController.text.isEmpty) {
                        getAlertDialog(context, "이름을 입력하세요!");
                      } else if (!birthCheck) {
                        getAlertDialog(context, "생일을 입력하세요!");
                      } else if (!genderCheck) {
                        getAlertDialog(context, "성별을 고르세요!");
                      } else if (barcode == '') {
                        getAlertDialog(context, "바코드를 스캔/입력 하세요!");
                      } else if (widget.helper.contains(barcode)) {
                        // } else if (await isContains(barcode)) {
                        getToast("이미 등록된 환자입니다!\n바코드를 다시 스캔해 주세요.",
                            gravity: ToastGravity.CENTER);
                        // if (!mounted) return;
                        // getAlertDialog(
                        //     context, "이미 등록된 환자입니다!\n바코드를 다시 스캔해 주세요.");
                      } else {
                        Person person = Person(_nameController.text, barcode,
                            _gender, _birthDay.toString());
                        // addPatients(person);
                        saveInfo(person);
                        getToast("등록이 완료되었습니다!");
                        setState(() {
                          initState();
                          rollBack();
                        });
                      }
                    },
                    color: BUTTON_COLOR,
                    borderRadius: BorderRadius.circular(10),
                    child: const Text("등록", style: BUTTON_TEXTSTYLE),
                  )
                ])
              ])
            ])));
  }

  Future saveInfo(Person person) async {
    widget.helper.writeInfo(barcode, person);
  }
}
