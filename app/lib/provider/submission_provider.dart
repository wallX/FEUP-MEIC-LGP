import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app/data/custom_file.dart';
import 'package:app/services/upload_service.dart';
import 'package:app/widgets/submission_page/video/video_thumbnail.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:cross_file/cross_file.dart' show XFile;
import 'dart:async';

/// Class to manage the submission of videos in the app, so that by leaving the submission_page, videos won't be removed
class SubmissionProvider extends ChangeNotifier {
  List<CustomFile> selectedFiles = [];
  bool isUploading = false;
  UploadService? _uploadService;

  void uploadService(UploadService service) {
    _uploadService = service;
  }

  bool get isUploadServiceInitialized {
    return _uploadService != null;
  }

  void setFiles(List<CustomFile> files) {
    selectedFiles = files;
    notifyListeners();
  }

  void addFiles(List<CustomFile> files) {
    selectedFiles.addAll(files);
    notifyListeners();
  }

  void addFile(CustomFile file) {
    selectedFiles.add(file);
    notifyListeners();
  }
  
  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
      notifyListeners();
    }
  }
  
  void clearFiles() {
    selectedFiles.clear();
    //selectedFilesSet.clear();
    notifyListeners();
  }
  
  void setUploading(bool uploading) {
    isUploading = uploading;
    notifyListeners();
  }

  bool isEmpty() {
    return selectedFiles.isEmpty;
  }

  // Update progress for a file
  void updateFileProgress(CustomFile file, double progress) {
    file.progress = progress;
    notifyListeners();
  }
  
  // Start the upload process
  Future<void> startUpload() async {
    if (_uploadService == null) {
      throw Exception("Upload service not initialized");
    }
    
    setUploading(true);
    
    try {
      await _uploadService!.uploadFiles(selectedFiles, updateFileProgress);
    } catch (e) {
      rethrow;
    } finally {
      setUploading(false);
    }
  }

  void pauseUpload() {
    if (_uploadService != null) {
      _uploadService!.pauseUpload();
    }
  }

  void cancelUpload() {
    if (_uploadService != null) {
      _uploadService!.cancelUpload();

      clearFiles();
      setUploading(false);
    }
  }

  bool get isPaused {
    return _uploadService != null && _uploadService!.isPaused;
  }

  Future<CustomFile> createCustomFileWithFile(File file) async {
    final metadata = await _extractVideoMetadata(file.path);

    return CustomFile(
      name: file.path.split('/').last,
      size: file.lengthSync(),
      file: XFile(file.path),
      thumbnail: VideoThumbnail(
        key: ValueKey(file.path),
        videoPath: file.path,
      ),
      progress: 0,
      estimate: Duration.zero,
      duration: metadata['duration'],
      width: metadata['width'],
      height: metadata['height'],
      orientation: metadata['orientation'],
      date: metadata['date'],
      framerate: metadata['framerate'],
      location: metadata['location'] ?? "",
    );
  }

  Future<CustomFile> createCustomFile(XFile xfile) async {
    final file = File(xfile.path);

    final metadata = await _extractVideoMetadata(file.path);

    return CustomFile(
      name: file.path.split('/').last,
      size: file.lengthSync(),
      file: xfile,
      thumbnail: VideoThumbnail(
        key: ValueKey(file.path),
        videoPath: file.path,
      ),
      progress: 0,
      estimate: Duration.zero,
      duration: metadata['duration'],
      width: metadata['width'],
      height: metadata['height'],
      orientation: metadata['orientation'],
      date: metadata['date'],
      framerate: metadata['framerate'],
      location: metadata['location'] ?? "",
    );
  }

  Future<Map<String, dynamic>> _extractVideoMetadata(String filePath) async {
    final videoInfo = FlutterVideoInfo();
    final info = await videoInfo.getVideoInfo(filePath);

    if (info == null) {
      throw Exception('Failed to extract video metadata');
    }

    return {
      'duration': (info.duration ?? 0) / 1000, // ms to seconds
      'width': info.width ?? 0,
      'height': info.height ?? 0,
      'date': info.date ?? "",
      'orientation': info.orientation ?? "",
      'framerate': info.framerate ?? 0,
      'location ': info.location  ?? "",
    };
  }
}