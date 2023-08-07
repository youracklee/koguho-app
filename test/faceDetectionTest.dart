
import 'package:camera/camera.dart';
import 'package:ediya/camera_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  CameraController controller = CameraController(
    cameras[1], ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.yuv420
  );
  testWidgets("TakePictureScreen 의 faceDetector 기능 테스트", (widgetTester) async {
    widgetTester.pumpWidget(TakePictureTestScreen(controller: controller));
  });
}