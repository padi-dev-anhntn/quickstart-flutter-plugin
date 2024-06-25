import 'dart:async';
import 'dart:io';

import 'package:banuba_sdk_example/page_camera.dart';
import 'package:banuba_sdk_example/page_grand.dart';
import 'package:banuba_sdk_example/page_image.dart';
import 'package:banuba_sdk_example/page_touchup.dart';
import 'package:banuba_sdk_example/page_arcloud.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

const banubaToken =
    "Qk5CICT3glGH+ym+thBwGqbhZv/Nqyd9l/b2FZW952dZhMm4bmUj3g13Iyf9SdY4jY0dkUZ8EQB5hp7H/v2nTeXqMnVcbPo8ol7xEA+sIoUg+cYXWg+lBAYcGgi0I0utVxU6RpWkf79rveUSJzkEKPjIMy7EH7VekfuX/xSQbmmLm5E+VWu9IKRrqHUtFy7CVW0Oe/AKkd2tdIOx6gKWxID5b0FVJvl3s4YvYUwbQfbcjeTa5NnJITdi4/UwbkP+9wa2oSQ1gUhoBFI5g7Yc0k/Ux18WV1obfmwu9lTMVgsR+zKjVM4+jvxWsOJDMayCUMCNB24XcvtY6Ay+wneMD/GKy0AIkPW2JN24l3D09a4RrkGME8dFKQZTi8VwV5rmQbex48KAa6AdI3bNVdATdVVpQXRuz3ou9zjmnixzudmZsbsetW3O/7jUJdyMWNZj3d57+f3ryLDa3WvmyB/UnkXN0EtlD7cc/1gKiNHfs24D9g7o/Bys/6MId/ClJO/6TuHifpSYGAmalNVdiig8FL9BBFG7WcTgTYE5P5syPxheQmEH/ePTm7qcpcFRK4cqTWM/MzEGB/PxxZEy4jAVncuKjL7a8LKcAA6Bkz5KDNkw7BQRcA9Wff1wq2Bz6/lYH4LOsV9z+Wuj/Gr3lt0Aug==";

enum EntryPage { camera, image, touchUp, arCloud, grand }

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      fixedSize: Size(MediaQuery.of(context).size.width / 2.0, 50),
    );
    Text textWidget(String text) {
      return Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 13.0),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Face AR Flutter Sample'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.camera),
            child: textWidget('Open Camera'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.image),
            child: textWidget('Image processing'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.touchUp),
            child: textWidget('Touch Up features'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.arCloud),
            child: textWidget('Load from AR Cloud'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.grand),
            child: textWidget('Load custom effect'),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(EntryPage entryPage) {
    switch (entryPage) {
      case EntryPage.camera:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraPage()),
        );
        return;

      case EntryPage.image:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ImagePage()),
        );
        return;

      case EntryPage.touchUp:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TouchUpPage()),
        );
        return;

      case EntryPage.arCloud:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ARCloudPage()),
        );
        return;

      case EntryPage.grand:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GranPage()),
        );
        return;
    }
  }
}

Future<String> generateFilePath(String prefix, String fileExt) async {
  final directory = await getTemporaryDirectory();
  final filename = '$prefix${DateTime.now().millisecondsSinceEpoch}$fileExt';
  return '${directory.path}${Platform.pathSeparator}$filename';
}

// This is a sample implementation of requesting permissions.
// It is expected that the user grants all permissions. This solution does not handle the case
// when the user denies access or navigating the user to Settings for granting access.
// Please implement better permissions handling in your project.
Future<bool> requestPermissions() async {
  final requiredPermissions = _getPlatformPermissions();
  for (var permission in requiredPermissions) {
    var ps = await permission.status;
    if (!ps.isGranted) {
      ps = await permission.request();
      if (!ps.isGranted) {
        return false;
      }
    }
  }
  return true;
}

List<Permission> _getPlatformPermissions() {
  return [Permission.camera, Permission.microphone];
}

void showToastMessage(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 14.0);
}
