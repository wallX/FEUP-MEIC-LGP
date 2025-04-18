import 'package:flutter/material.dart';
import 'package:app/data/custom_file.dart';

/// Class to manage the submission of videos in the app, so that by leaving the submission_page, videos won't be removed
class SubmissionProvider extends ChangeNotifier {
  List<CustomFile> selectedFiles = [];
  //Set<String> selectedFilesSet = {};
  bool isUploading = false;

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
}