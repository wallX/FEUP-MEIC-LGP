import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

Future<void> pickAndSaveProfileImage({
  required String userEmail,
  required ValueChanged<File?> onImageSelected,
}) async {
  final result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result != null && result.files.single.path != null) {
    final selectedImage = File(result.files.single.path!);
    onImageSelected(selectedImage);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$userEmail-profileImagePath', selectedImage.path);
  }
}

Future<void> removeProfileImage({
  required String userEmail,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('$userEmail-profileImagePath');
}
