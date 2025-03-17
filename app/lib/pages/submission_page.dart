import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:app/widgets/video/video_thumbnail.dart';
import 'package:app/manager/theme_manager.dart';

import 'package:cross_file/cross_file.dart' show XFile;
import 'package:tusc/tusc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/data/custom_file.dart';

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

          : Column( // Videos selected
              children: [
                Expanded(
                  child: _listSelectedVideos(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _submitButton(),
                ),
              ],
            ),
    );
  }

  Widget _selectVideoFromGalleryButton() {
    return FloatingActionButton(
      onPressed: _isUploading ? null : () async {
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
      },
      tooltip: 'Select video from gallery',
      child: const Icon(Icons.video_library),
    );
  }

  Widget _listSelectedVideos() {
    return ListView.builder(
      itemCount: _selectedFiles.length,
      itemBuilder: (context, index) {
        final uploadFile = _selectedFiles.length > index ? _selectedFiles[index] : null;
        
        return Column(
          children: [
            ListTile(
              title: Text('File ${index + 1}'),
              subtitle: Text('${_selectedFiles[index].name} - ${_selectedFiles[index].size} bytes',
                style: TextStyle(color: themeManager.theme.textColor)),
              leading: _selectedFiles[index].thumbnail,
              trailing: _isUploading 
                ? null 
                : IconButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedFiles.length > index) {
                          _selectedFiles.removeAt(index);
                        }
                      });
                    },
                    icon: const Icon(Icons.close)
                  ),
            ),
            if (uploadFile != null && _isUploading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: uploadFile.progress / 100),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${uploadFile.progress.toStringAsFixed(1)}%', 
                          style: TextStyle(color: themeManager.theme.textColor)),
                        Text('Est: ${_printDuration(uploadFile.estimate)}',
                          style: TextStyle(color: themeManager.theme.textColor)),
                      ],
                    ),
                    if (uploadFile.fileUrl != null)
                      Text('Uploaded: ${uploadFile.fileUrl}',
                        style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: _selectedFiles.isEmpty || _isUploading 
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
              //setState(() {
              //  _selectedFiles = [];
              //  _isUploading = false;
              //});
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
      debugPrint('DEBUG | Getting upload URL for $fileName with length $fileLength');

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
        throw Exception('DEBUG | Failed to get upload URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('DEBUG | Error connecting to server: $e');
    }
  }

  Future<void> _uploadToTus() async {
    debugPrint('DEBUG | Uploading videos to Tus server');
    final tempDir = await getTemporaryDirectory();
    
    //List<Future> uploads = [];
    
    for (int i = 0; i < _selectedFiles.length; i++) {
      CustomFile uploadFile = _selectedFiles[i];

      // Get the address where we will upload the file
      String? uri = '';
      try {
        uri = await _getUploadUrl(uploadFile.name, uploadFile.size);
        uri = uri?.replaceAll("localhost", "10.0.2.2"); // TODO: Fix this for production
        debugPrint('DEBUG | Got upload URL: $uri');
      } catch (e) {
        debugPrint('DEBUG | Error getting upload URL: $e');
        return;
      }

      Uri sendUri = Uri.parse(uri!);
      debugPrint("DEBUG | Sending to $sendUri");

      // Create a temporary directory for this file
      final tempDirectory = Directory('${tempDir.path}/${uploadFile.file.name}_upload');
      if (!tempDirectory.existsSync()) {
        tempDirectory.createSync(recursive: true);
      }
      
      final tusClient = TusClient(
        url: uri, 
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

      tusClient.startUpload(
        onProgress: (count, total, response) {
          debugPrint('DEBUG | Progress: $count / $total');
          setState(() {
            uploadFile.progress = count / total * 100;
          });
        },
        onComplete: (response) {
          debugPrint('DEBUG | Upload complete: $response');
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
      );
    }
    
    // Wait for all uploads to complete
    //await Future.wait(uploads);
  }
  
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  // Close the client when the page is disposed
  @override
  void dispose() {
    httpClient.close();
    super.dispose();
  }
}

