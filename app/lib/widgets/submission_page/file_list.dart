import 'package:flutter/material.dart';
import 'package:app/data/custom_file.dart';
import 'package:app/widgets/submission_page/upload_progress.dart';
import 'package:intl/intl.dart';

class FileList extends StatelessWidget {
  final List<CustomFile> files;
  final bool isUploading;
  final Function(int)? onRemove;

  FileList({
    super.key,
    required this.files,
    required this.isUploading,
    this.onRemove,
  });

  final locationController = TextEditingController();
  final dateController = TextEditingController();
  final notesController = TextEditingController();

  void dispose() {
    locationController.dispose();
    dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];

        return Column(
          children: [
            _buildFileList(index, file),
            if (isUploading) UploadProgress(file: file),
          ],
        );
      },
    );
  }

  Widget _buildFileList(int index, CustomFile file) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Builder(
         builder: (context) => ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('File ${index + 1}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      _showFileMetadataDialog(context, file);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  IconButton(
                    onPressed: onRemove != null ? () => onRemove!(index) : null,
                    icon: const Icon(Icons.close)
                  ),
                ],
              ),
            ],
            
          ),
        
          subtitle:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${file.name} - ${_formatFileSize(file.size)}',
                  ),
                if (file.width != 0 && file.height != 0 && file.duration != 0) ...[
                  Text(
                    'Resolution: ${file.width}x${file.height}',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Duration: ${_formatDuration(file.duration)}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
        
          leading: file.thumbnail
        ),
      ),
    );
  }

  void _showFileMetadataDialog(BuildContext context, CustomFile file) {
    locationController.text = file.location;
    notesController.text = file.notes ?? '';


    DateTime? selectedDate;
    final dateFormat = DateFormat('yyyy-MM-dd');

    try {
      if (file.date.isNotEmpty) {
        selectedDate = dateFormat.parse(file.date);
      }
    } catch (e) {
      // If parsing fails, default to current date
      selectedDate = DateTime.now();
    }

    selectedDate ??= DateTime.now();
    final dateController = TextEditingController(text: dateFormat.format(selectedDate));

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(child: Text(file.name)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationField(),
                    const SizedBox(height: 16),
                    _buildDateField(dateController, context, selectedDate, setState, dateFormat),
                    const SizedBox(height: 16),
                    _buildNotesField(),
                  ],
                ),
              ),
              actions: [
                _buildCancelOption(context),
                _buildSaveOption(file, dateController, context),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildNotesField() {
    return TextField(
      style: TextStyle(color: Colors.grey[700]), // Set input text to black
      controller: notesController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Notes',
        border: OutlineInputBorder(),
        
      ),
    );
  }

  TextButton _buildSaveOption(CustomFile file, TextEditingController dateController, BuildContext context) {
    return TextButton(
      onPressed: () {
        file.location = locationController.text;
        file.date = dateController.text;
        file.notes = notesController.text;
        Navigator.of(context).pop();
      },
      child: Text('Save', style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor)),
    );
  }

  TextButton _buildCancelOption(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text('Cancel', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
    );
  }

  TextField _buildDateField(TextEditingController dateController, BuildContext context, DateTime? selectedDate, StateSetter setState, DateFormat dateFormat) {
    return TextField(
      controller: dateController,
      readOnly: true,
      style: TextStyle(color: Colors.grey[700]),
      decoration: InputDecoration(
        labelText: 'Date Recorded',
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate!,
              firstDate: DateTime(0),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != selectedDate) {
              setState(() {
                selectedDate = picked;
                dateController.text = dateFormat.format(picked);
              });
            }
          },
        ),
      ),
    );
  }

  TextField _buildLocationField() {
    return TextField(
      controller: locationController,
      style: TextStyle(color: Colors.grey[700]),
      decoration: const InputDecoration(
        labelText: 'Location',
        border: OutlineInputBorder(),
      ),
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

  String _formatFileSize(int size) {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}