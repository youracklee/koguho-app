import 'package:ediya/main.dart';
import 'package:ediya/person.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'constant.dart';
import 'sp_helper.dart';
import 'util.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:math';
import 'api_util.dart';

bool canStartImageStream = true;

class CameraPage extends StatefulWidget {
  final SPHelper helper;
  final CameraDescription camera;

  const CameraPage(this.camera, this.helper, {super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late TextEditingController _textStream;

  final _barcodeScanner = BarcodeScanner();


  void barcodeImageStream() async {
    while (true) {
      if (pageIndex == 1 || pageIndex == 2) {
        await Future.delayed(const Duration(milliseconds: 10));
        continue;
      }
      await Future.delayed(const Duration(milliseconds: 10));
      if (canStartImageStream && mounted) {
        barcodeProcess();
      }
    }
  }

  void barcodeProcess() async {
    canStartImageStream = false;
    int barcodeCounts = BARCODE_COUNTS; //너무 빨리 찍히는 거 방지
    await _controller.startImageStream((CameraImage image) async {
      InputImageData iid = getIID(image);
      Uint8List bytes = getBytes(image);
      if (pageIndex == 1 || pageIndex == 2) {
        _controller.stopImageStream();
        canStartImageStream = true;
      }

      final InputImage inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: iid);
      _barcodeScanner.processImage(inputImage).then((List<Barcode> barcodes) async {
        if (barcodeCounts > 0) {
          barcodeCounts--;
        } else {
          if (barcodes.isNotEmpty) {
            barcodeCounts = BARCODE_COUNTS;
            final bar = barcodes[0].rawValue.toString();
            if (widget.helper.contains(bar) && !canStartImageStream) {
            // if (await isContains(bar) && !canStartImageStream) {
              _controller.stopImageStream();
              if (!mounted) return;
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => TakePictureScreen(
                        controller: _controller,
                        barcode: bar,
                        helper: widget.helper,
                      )));
            } else {
              getToast("등록되지 않은 바코드입니다.");
              setState(() {});
            }
          }}});
    });
  }

  void _toastTextEdit() {
    // getToast(_textStream.text);
    debugPrint(_textStream.text);
  }

  @override
  void initState() {
    super.initState();
    _textStream = TextEditingController();
    _textStream.addListener(_toastTextEdit);
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _controller.initialize().then((_) => barcodeImageStream());
  }

  @override
  void dispose() {
    // 카메라 컨트롤러 해제
    _controller.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  void rebuildAllChildren(BuildContext context) {
    debugPrint("rebuild");
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text("환자 찾기", style: TITLE_TEXTSTYLE),
        ),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Stack(
              alignment: Alignment.center,
              children: [
                CupertinoTextField(
                  autofocus: true,
                  showCursor: false,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.none,
                  onChanged: (bar) async {
                    // if (bar.length != 8) {}
                    if (widget.helper.contains(bar) && !canStartImageStream) {
                    // if (await isContains(bar) && !canStartImageStream) {
                      _controller.stopImageStream();
                      if (!mounted) return;
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => TakePictureScreen(
                                controller: _controller,
                                barcode: bar,
                                helper: widget.helper,
                              )));
                      _textStream.clear();
                    } else {
                      if (bar.length == 8) {
                        getToast("등록되지 않은 바코드입니다.");
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const Dummy()
                          )
                        );
                        setState(() {
                          _textStream.clear();
                        });
                        // rebuildAllChildren(context);
                      }
                    }
                  },
                  controller: _textStream,
                ),
                SizedBox(
                    height: h, width: w,
                    child: CameraPreview(_controller)
                ),
                Column(
                  children: [
                    SizedBox(
                      height: h / 1.7, width: w / 1.7,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                            height: h / 4, width: w / 1.1,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 3.0, color: BARCODE_COLOR
                                ))),
                        Container(
                            height: 1, width: w / 1.5,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2.0, color: BARCODE_COLOR
                                )))
                      ],
                    )
                  ],
                )]),
        ));
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraController controller;
  final SPHelper helper;
  final String barcode;

  const TakePictureScreen({
    Key? key,
    required this.controller,
    required this.barcode,
    required this.helper,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late int time;
  final int num = Random().nextInt(NUM_OF_IMAGES) + 1;
  bool isDisposed = false;

  String imagePath(String barcode, String name) {
    var newFileName = "$name-${barcode}_${nowString()}.png";
    return newFileName;
  }

  Future<void> saveImagePath(XFile? tempImage) async {
    if (tempImage == null) return;
    // String name = await getPatientsName(widget.barcode);
    String name = widget.helper.getPersonName(widget.barcode);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String newPath = join(dir, imagePath(widget.barcode, name));

    File temp = await File(tempImage.path).copy(newPath);
    GallerySaver.saveImage(temp.path, albumName: name);
    // await uploadImage(temp);
  }

  @override
  void initState() {
    super.initState();
    // 카메라 컨트롤러 초기화
    time = TIMER_MAX;
    _controller = widget.controller;
    timer();
    // faceDetection();
  }


  void faceDetection() async {
    final options = FaceDetectorOptions();
    final faceDetector = FaceDetector(options: options);
    bool detected = false;

    _controller.startImageStream((CameraImage image) async {
      InputImageData iid = getIID(image);
      Uint8List bytes = getBytes(image);

      final InputImage inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: iid);
      faceDetector.processImage(inputImage).then((List<Face> faces) {
        for (Face face in faces) {
          // print(face.landmarks.toString());
          canStartImageStream = true;
          if (!mounted) return;
          Navigator.pop(context);
          return;
        }});
    });
  }

  void timer() {
    const oneSec = Duration(seconds: 1);
    getToast(
      "촬영이 시작되었습니다. 얼굴 전체가 나올 수 있도록, 정면을 응시해주시길 바랍니다.",
      size:40,
      gravity: ToastGravity.CENTER,
      textColor: PHOTO_NOTICE_TEXT_COLOR,
      backgroundColor: PHOTO_NOTICE_BACKGROUND_COLOR,
    );
    if (!isDisposed) {
      Timer.periodic(
          oneSec,
              (_) {
            if (time == 0 && !canStartImageStream) {
              takePicture();
              // print("찰칵");
              time = TIMER_MAX;
              canStartImageStream = true;
              getToast("촬영이 완료되었습니다.", size:50, gravity: ToastGravity.TOP, toastLength: Toast.LENGTH_LONG);

              if (!mounted) return;
              Navigator.of(context).pop();
              // dispose();
              return;
            } else if (time > 0) {
              if (mounted){
                getToast(
                  time.toString(), size:100, gravity: ToastGravity.TOP,
                  textColor: PHOTO_NOTICE_TEXT_COLOR,
                  backgroundColor: PHOTO_NOTICE_BACKGROUND_COLOR
                );
                setState(() {
                  time--;
                });
              }}});
    }
  }

  void takePicture() async {
    try {
      // 사진 찍기
      final image = await _controller.takePicture();
      Person tp = widget.helper.getPersonInfo(widget.barcode);

      DateTime now = DateTime.now();
      String date = DateTime(now.year, now.month, now.day).toString().split(" ")[0];

      tp.recentShotDate = date;
      widget.helper.writeInfo(widget.barcode, tp);
      // 찍은 사진을 저장하기 위한 경로 생성
      saveImagePath(image);
    } catch (e) {
      // 에러 발생 시 처리
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    canStartImageStream = true;
    isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    // final name = getPatientsName(widget.barcode);
    final name = widget.helper.getPersonName(widget.barcode);

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text('$name님')),
        child: Stack(
            children: [
              SizedBox(
                width: w, height: h,
                child: Image.asset("assets/img/img$num.png")
                // child: CameraPreview(_controller),
              ),
              Column(
                  children: const [
                    SizedBox(
                      width: 200, height: 100,
                    ),
                  ]),
              Column(
                children: [
                  SizedBox(width: w * 0.3, height: h / 1.3),
                  SizedBox(
                    width: w / 5, height: h / 5,
                    child: CameraPreview(_controller)
                  )])
            ]));
  }
}

InputImageData getIID(CameraImage image) {
  return InputImageData(
      inputImageFormat: InputImageFormatValue.fromRawValue(image.format.raw)!,
      size: Size(image.width.toDouble(), image.height.toDouble() / 1.2),
      imageRotation: InputImageRotation.rotation0deg,
      planeData: image.planes.map((Plane plane) => InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      )).toList());
}

class Dummy extends StatefulWidget {
  const Dummy({Key? key}) : super(key: key);

  @override
  State<Dummy> createState() => _DummyState();
}

class _DummyState extends State<Dummy> {

  @override
  void initState() {
    super.initState();
    const oneSec = Duration(milliseconds: 500);
    Timer.periodic(
      oneSec,
        (_) {
          Navigator.of(context).pop();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Container(
      width: w, height: h,
      color: BUTTON_TEXT_COLOR,
    );
  }
}


Uint8List getBytes(CameraImage image) {
  return Uint8List.fromList(
      image.planes.fold(<int>[], (List<int> previousValue, element) => previousValue
        ..addAll(element.bytes)));
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}