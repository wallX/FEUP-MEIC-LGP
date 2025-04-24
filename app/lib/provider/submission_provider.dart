import 'package:flutter/material.dart';
import 'package:app/data/custom_file.dart';
import 'package:app/services/upload_service.dart';

/// Class to manage the submission of videos in the app, so that by leaving the submission_page, videos won't be removed
class SubmissionProvider extends ChangeNotifier {
  List<CustomFile> selectedFiles = [];
  //Set<String> selectedFilesSet = {};
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

  /*bool addPathToSet(String path) {
    if (selectedFilesSet.contains(path)) {
      return false; // Path already exists in the set
    }
    selectedFilesSet.add(path);
    notifyListeners();
    return true; // Path added successfully
  }*/
  
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
}