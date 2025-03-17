import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:app/widgets/submission_page/video/video_thumbnail.dart';
import 'package:app/manager/theme_manager.dart';

import 'package:cross_file/cross_file.dart' show XFile;
import 'package:tusc/tusc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:app/data/custom_file.dart';

import 'package:app/widgets/submission_page/file_list.dart';
import 'package:app/widgets/submission_page/upload_progress.dart';

class SubmissionPage extends StatefulWidget {
  const SubmissionPage({super.key});
  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  List<CustomFile> _selectedFiles = [];
  bool _isUploading = false;
  var httpClient = http.Client();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeManager,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: themeManager.theme.backgroundColor,
          body: _buildUI(),
          floatingActionButton: _selectVideoFromGalleryButton(),
        );
      },
    );
  }

  Widget _buildUI() {
    return Container(
      child: _selectedFiles.isEmpty
          ? Center( // Empty
              child: Text('No video selected', style: TextStyle(color: themeManager.theme.textColor)),
            )

          : Column(
              children: [
                Expanded(
                  child: FileList(
                    files: _selectedFiles,
                    isUploading: _isUploading,
                    onRemove: _isUploading ? null : (index) {
                      setState(() {
                        _selectedFiles.removeAt(index);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _submitButton(),
                ),
              ],
            ),
    );
  }


  // Widget to select a video from the gallery
  Widget _selectVideoFromGalleryButton() {
    return FloatingActionButton(
      onPressed: _isUploading ? null : _selectVideoFromGallery,
      tooltip: 'Select video from gallery',
      child: const Icon(Icons.video_library),
    );
  }

  // Function to select a video from the gallery
  Future<void> _selectVideoFromGallery() async {
    FilePickerResult? mediaFiles = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.video,
    );
    if (mediaFiles != null) {
      List<File> files = mediaFiles.paths.map((path) => File(path!)).toList();
      setState(() {
        _selectedFiles = files.map((file) => CustomFile(
          name: file.path.split('/').last,
          size: file.lengthSync(),
          file: XFile(file.path),
          thumbnail: VideoThumbnail(videoPath: file.path),
          progress: 0,
          estimate: Duration.zero,
          
        )).toList();
      });
    }
  }

  Widget _submitButton() {
    return ElevatedButton(

      onPressed: _isUploading 
          ? null 
          : () async {
              setState(() {
                _isUploading = true;
              });
              
              await _uploadToTus();
              
              // Visual feedback
              final snackbar = SnackBar(
                content: const Text('Videos submitted successfully!'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
              
              // Remove uploaded videos
              setState(() {
                _selectedFiles = [];
                _isUploading = false;
              });
            },

      child: _isUploading 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Text('Uploading...'),
              ],
            )
          : const Text('Submit Videos'),
    );
  }

  Future<String?> _getUploadUrl(String fileName, int fileLength) async {
    try {
      final response = await httpClient.post(
        Uri.parse("http://10.0.2.2:8080/uploads"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'file_name': fileName,
          'file_length': fileLength.toString(),
        }
      );
    
      if (response.statusCode == 200) {
        final responseData = response.headers['location'];
        return responseData;
      } else {
        throw Exception('Failed to get upload URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<void> _uploadToTus() async {
    final tempDir = await getTemporaryDirectory();
    
    List<Future> uploads = [];
    
    for (int i = 0; i < _selectedFiles.length; i++) {
      CustomFile uploadFile = _selectedFiles[i];

      // Get the address where we will upload the file
      String? uri = '';
      try {
        uri = await _getUploadUrl(uploadFile.name, uploadFile.size);
        uri = uri?.replaceAll("localhost", "10.0.2.2"); // TODO: Fix this for production
      } catch (e) {
        return;
      }

      // Create a temporary directory for this file
      final tempDirectory = Directory('${tempDir.path}/${uploadFile.file.name}_upload');
      if (!tempDirectory.existsSync()) {
        tempDirectory.createSync(recursive: true);
      }
      
      final tusClient = TusClient(
        url: uri!, 
        file: uploadFile.file,
        chunkSize: 1.MB,
        timeout: Duration(seconds: 30),
        cache: TusPersistentCache(tempDirectory.path),
        httpClient: httpClient,
      );

      // Since the way the package works it always sends a POST first and our server doesn't support that, 
      // we need set the upload URL in the cache before calling startUpload so that the package thinks it's resuming an upload,
      // therefore it will send a PATCH request instead of a POST
      await tusClient.cache?.set(tusClient.fingerprint, uri);

      uploads.add(tusClient.startUpload(
        onProgress: (count, total, response) {
          setState(() {
            uploadFile.progress = count / total * 100;
          });
        },

        onComplete: (response) {
          setState(() {
            uploadFile.progress = 100;
          });
          tempDirectory.deleteSync(recursive: true);
        },

        onError: (error) {
          debugPrint('DEBUG | Error uploading ${uploadFile.file.name}: $error');
        },

        onTimeout: () {
          debugPrint('DEBUG | Timeout uploading ${uploadFile.file.name}');
        }
      ));

    }
    
    // Wait for all uploads to complete
    await Future.wait(uploads);
  }

  @override
  void dispose() {
    // Close the client when the page is disposed
    httpClient.close();
    super.dispose();
  }
}

