import 'dart:io';

import 'package:app/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/submission_provider.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:app/data/custom_file.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late SubmissionProvider _submissionProvider;

  @override
  void initState() {
    super.initState();
    _submissionProvider = Provider.of<SubmissionProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.video(
          videoOptions: VideoOptions(
            enableAudio: true,
            ios: CupertinoVideoOptions(
              fps: 10,
            ),
            android: AndroidVideoOptions(
              bitrate: 6000000,
              fallbackStrategy: QualityFallbackStrategy.lower,
            ),
          ),
        ),
        onMediaCaptureEvent: (event){
          switch (event.status) {
            case MediaCaptureStatus.capturing:
              break;
            case MediaCaptureStatus.success:
              event.captureRequest.when(
                single: (single) async {
                  if (single.file == null) return;
                  File file = File(single.file!.path);
                  CustomFile customFile = await _submissionProvider.createCustomFile(file);
                  _submissionProvider.addFile(customFile);

                  if(mounted){
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Video saved successfully!'),
                          actions: [
                            TextButton(
                              style: Theme.of(context).textButtonTheme.style,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Record another video'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pushReplacementNamed('/submission_page');
                              },
                              child: const Text('Done'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                multiple: (multiple) {
                  multiple.fileBySensor.forEach((key, value) {
                    debugPrint('DEBUG | multiple video taken: $key ${value?.path}');
                  });
                },
              );
            case MediaCaptureStatus.failure:
              ErrorDialog.show(context: context, message: '${event.exception}');
              break;
          }
        },
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          flashMode: FlashMode.auto,
          aspectRatio: CameraAspectRatios.ratio_4_3,
          zoom: 0.0,
        ),
        enablePhysicalButton: true,
        previewAlignment: Alignment.center,
        previewFit: CameraPreviewFit.contain,

        // Play button
        //onMediaTap: (mediaCapture) {
        //  mediaCapture.captureRequest.when(
        //    single: (single) {
        //      debugPrint('DEBUG | single: ${single.file?.path}');
        //      //single.file?.open();
        //    },
        //  );
        //},
      ),
    );
  }
}