import 'dart:async';

import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';

/// Sample page for camera screen
/// 1. Open camera
/// 2. Apply Face AR effect
/// 3. Record video(with/out AR effect)
/// 4. Take a picture(with/out AR effect)
class CameraPage extends StatefulWidget {
  final BanubaSdkManager _banubaSdkManager;

  CameraPage(this._banubaSdkManager, {super.key}) {}

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  final _epWidget = EffectPlayerWidget(key: null);

  // The higher resolution the more CPU and GPU resources are used.
  // Please take into account that low level devices might have performance issues with HD resolution.
  final _videoResolutionHD = const Size(720, 1280);

  final _captureAudioInVideoRecording = true;

  bool _applyEffect = false;
  bool _isVideoRecording = false;
  bool _isFacingFront = true;

  @override
  void initState() {
    debugPrint('CameraPage: init');
    super.initState();

    // It is required to grant all permissions for the plugin: Camera, Micro, Storage
    requestPermissions().then((granted) {
      if (granted) {
        debugPrint('CameraPage: Thanks! All permissions are granted!');
        openCamera();
      } else {
        debugPrint('CameraPage: WARNING! Not all required permissions are granted!');
        // Plugin cannot be used. Handle this state on your app side
        SystemNavigator.pop();
      }
    }).onError((error, stackTrace) {
      debugPrint('CameraPage: ERROR! Plugin cannot be used : $error');
      // Plugin cannot be used. Handle this state on your app side
      SystemNavigator.pop();
    });
  }

  Future<void> openCamera() async {
    debugPrint('CameraPage: open camera');
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      debugPrint('CameraPage: Warning! widget is not mounted!');
      return;
    }
    await widget._banubaSdkManager.openCamera();
    await widget._banubaSdkManager.attachWidget(_epWidget.banubaId);
    widget._banubaSdkManager.startPlayer();
  }

  Future<void> toggleEffect() async {
    debugPrint('CameraPage: toggleEffect');
    _applyEffect = !_applyEffect;
    if (_applyEffect) {
      // Applies Face AR effect
      widget._banubaSdkManager.loadEffect('effects/TrollGrandma');
    } else {
      // Discard Face AR effect
      widget._banubaSdkManager.loadEffect('');
    }
  }

  Future<void> handleVideoRecording() async {
    if (_isVideoRecording) {
      debugPrint('CameraPage: stopVideoRecording');
      _isVideoRecording = false;
      widget._banubaSdkManager.stopVideoRecording();
    } else {
      final filePath = await generateFilePath('video_', '.mp4');
      debugPrint('CameraPage: startVideoRecording = $filePath');
      _isVideoRecording = true;
      widget._banubaSdkManager
          .startVideoRecording(filePath, _captureAudioInVideoRecording,
          _videoResolutionHD.width.toInt(), _videoResolutionHD.height.toInt())
          .then((value) => debugPrint('CameraPage: Video recorded successfully'));
    }
  }

  Future<void> takePhoto() async {
    final photoFilePath = await generateFilePath('image_', '.png');
    debugPrint('CameraPage: Take photo = $photoFilePath');
    widget._banubaSdkManager
        .takePhoto(
        photoFilePath, _videoResolutionHD.width.toInt(), _videoResolutionHD.height.toInt())
        .then((value) => debugPrint('CameraPage: Photo taken successfully'))
        .onError((error, stackTrace) => debugPrint('CameraPage: Error while taking photo'));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CameraPage: build');
    final screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        SizedBox(width: screenSize.width, height: screenSize.height, child: _epWidget),
        Positioned(
            top: screenSize.height * 0.7,
            left: screenSize.width * 0.05,
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    fixedSize: const Size(120, 40),
                  ),
                  onPressed: () {
                    toggleEffect();
                  },
                  child: Text(
                    'Effect'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    fixedSize: const Size(120, 40),
                  ),
                  onPressed: () {
                    _isFacingFront = !_isFacingFront;
                    widget._banubaSdkManager.setCameraFacing(_isFacingFront);
                  },
                  child: Text(
                    'Front/Back'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                )
              ],
            )),
        Positioned(
            bottom: screenSize.height * 0.03,
            left: screenSize.width * 0.05,
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    fixedSize: const Size(120, 40),
                    backgroundColor: _isVideoRecording ? Colors.red : Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      handleVideoRecording();
                    });
                  },
                  child: Text(
                    _isVideoRecording ? 'Stop'.toUpperCase() : 'Record Video'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    fixedSize: const Size(120, 40),
                  ),
                  onPressed: () => takePhoto(),
                  child: Text(
                    'Take Photo'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                )
              ],
            )),
      ],
    );
  }
}