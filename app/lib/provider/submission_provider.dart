import 'package:flutter/material.dart';
import 'package:app/data/custom_file.dart';

/// Class to manage the submission of videos in the app, so that by leaving the submission_page, videos won't be removed
class SubmissionProvider extends ChangeNotifier {
  List<CustomFile> selectedFiles = [];
  bool isUploading = false;
  
  void setSelectedFiles(List<CustomFile> files) {
    selectedFiles = files;
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
    notifyListeners();
  }
  
  void setUploading(bool uploading) {
    isUploading = uploading;
    notifyListeners();
  }
}