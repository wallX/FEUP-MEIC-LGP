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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${file.name} - ${file.size} bytes',
                    style: TextStyle(color: themeManager.theme.textColor),
                    ),
                  if (file.width != 0 && file.height != 0 && file.duration != 0) ...[
                    Text(
                      'Resolution: ${file.width}x${file.height}',
                      style: TextStyle(color: themeManager.theme.textColor, fontSize: 12),
                    ),
                    Text(
                      'Duration: ${_formatDuration(file.duration)}',
                      style: TextStyle(color: themeManager.theme.textColor, fontSize: 12),
                    ),
                  ],
                ],
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

  String _formatDuration(dynamic durationInSeconds) {
    if (durationInSeconds == null) return 'Unknown';
    final duration = Duration(seconds: durationInSeconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds';
  }
}