import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/submission_provider.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';


class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  //late SubmissionProvider _submissionProvider;

  @override
  void initState() {
    super.initState();
    //_submissionProvider = Provider.of<SubmissionProvider>(context, listen: false);
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
              debugPrint("DEBUG | Capturing video...");
              break;
            case MediaCaptureStatus.success:
              debugPrint("DEBUG | Video captured successfully!");
              event.captureRequest.when(
                single: (single) {
                  debugPrint('DEBUG | Video saved: ${single.file?.path}');
                },
                multiple: (multiple) {
                  multiple.fileBySensor.forEach((key, value) {
                    debugPrint('DEBUG | multiple video taken: $key ${value?.path}');
                  });
                },
              );
            case MediaCaptureStatus.failure:
              debugPrint('DEBUG | Failed to capture video: ${event.exception}');
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
        onMediaTap: (mediaCapture) {
          mediaCapture.captureRequest.when(
            single: (single) {
              debugPrint('DEBUG | single: ${single.file?.path}');
              //single.file?.open();
            },
            multiple: (multiple) {
              multiple.fileBySensor.forEach((key, value) {
                debugPrint('DEBUG | multiple file taken: $key ${value?.path}');
                //value?.open();
              });
            },
          );
        },
      ),
    );
  }

}