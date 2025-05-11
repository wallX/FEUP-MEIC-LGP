import 'package:cross_file/cross_file.dart' show XFile;
import 'package:tus_client_dart/tus_client_dart.dart';
import 'package:app/widgets/submission_page/video/video_thumbnail.dart';

// Custom File class to hold everything we need to submit the file
class CustomFile {
  final String name;
  final int size;	
  final XFile file;
  final VideoThumbnail thumbnail;
  final double duration;
  final int width;
  final int height;
  final int orientation;
  final String date;
  final double framerate;
  final String location;
  TusClient? client;
  double progress;
  Duration estimate;
  Uri? fileUrl;

  CustomFile({
    required this.name,
    required this.size,
    required this.file,
    required this.thumbnail,
    required this.progress,
    required this.estimate,
    required this.duration,
    required this.width,
    required this.height,
    required this.orientation,
    required this.date,
    required this.framerate,
    required this.location,
    this.client,
    this.fileUrl,
  });
}