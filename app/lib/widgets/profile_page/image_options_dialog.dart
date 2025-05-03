import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/provider/user_provider.dart';
import 'package:file_picker/file_picker.dart';

class ImageOptionsDialog extends StatelessWidget {
  final File? profileImage;
  final Function(File?) onImageSelected;

  const ImageOptionsDialog({
    required this.profileImage,
    required this.onImageSelected,
    super.key,
  });

  Future<void> _pickImage(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final selectedImage = File(result.files.single.path!);
      onImageSelected(selectedImage);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userEmail = context.read<UserProvider>().user?.email ?? '';
      prefs.setString('$userEmail-profileImagePath', result.files.single.path!);
    }
  }

  Future<void> _removeImage(BuildContext context) async {
    onImageSelected(null);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userEmail = context.read<UserProvider>().user?.email ?? '';
    prefs.remove('$userEmail-profileImagePath');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, _) {
      return AlertDialog(
        backgroundColor: themeProvider.backgroundColor,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        title: Center(
          child: Text(
            'Edit Profile Picture',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Would you like to remove the picture or select a new one?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _removeImage(context);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Remove'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _pickImage(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Select from files'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: themeProvider.primaryColor, width: 2),
                foregroundColor: themeProvider.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    });
  }
}
