import 'package:flutter/material.dart';
import 'package:app/data/custom_file.dart';
import 'package:app/manager/theme_manager.dart';
import 'package:app/widgets/submission_page/upload_progress.dart';

class FileList extends StatelessWidget {
  final List<CustomFile> files;
  final bool isUploading;
  final Function(int)? onRemove;

  const FileList({
    super.key,
    required this.files,
    required this.isUploading,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        
        return Column(
          children: [
            ListTile(
              title: Text('File ${index + 1}'),
              subtitle: Text(
                '${file.name} - ${file.size} bytes',
                style: TextStyle(color: themeManager.theme.textColor),
              ),
              leading: file.thumbnail,
              trailing: isUploading 
                ? null 
                : IconButton(
                    onPressed: onRemove != null ? () => onRemove!(index) : null,
                    icon: const Icon(Icons.close)
                  ),
            ),
            if (isUploading)
              UploadProgress(file: file),
          ],
        );
      },
    );
  }
}