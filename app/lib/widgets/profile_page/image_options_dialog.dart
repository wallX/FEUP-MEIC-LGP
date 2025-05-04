import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app/widgets/profile_page/dialog_buttons.dart';

class ImageOptionsDialog extends StatelessWidget {
  final File? profileImage;
  final ValueChanged<File?> onImageSelected;
  final String userEmail;

  const ImageOptionsDialog({
    required this.profileImage,
    required this.onImageSelected,
    required this.userEmail,
    super.key,
  });

  Future<void> _pickImage(BuildContext context) async {
    final navigator = Navigator.of(context);
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final selectedImage = File(result.files.single.path!);
      onImageSelected(selectedImage);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$userEmail-profileImagePath', selectedImage.path);
    }
    navigator.pop();
  }

  Future<void> _removeImage(BuildContext context) async {
    final navigator = Navigator.of(context);
    onImageSelected(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$userEmail-profileImagePath');
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('Edit Profile Picture')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDescriptionText(),
          const SizedBox(height: 16),
          _buildActionButtons(context),
          const SizedBox(height: 4),
          buildOutlinedDialogButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionText() {
    return const Text(
      'Would you like to remove the picture or select a new one?',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        children: [
          buildElevatedDialogButton(
            label: 'Remove',
            onPressed: () => _removeImage(context),
          ),
          const SizedBox(width: 16),
          buildElevatedDialogButton(
            label: 'Select from files',
            onPressed: () => _pickImage(context),
          ),
        ],
      ),
    );
  }
}
