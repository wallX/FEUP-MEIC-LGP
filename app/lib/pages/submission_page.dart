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
import 'package:app/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:app/data/user.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'dart:async';

class SubmissionPage extends StatefulWidget {
  const SubmissionPage({super.key});
  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  List<CustomFile> _selectedFiles = [];
  bool _isUploading = false;

  var httpClient = http.Client();

  late final ApiService _apiService;
  late final User _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _user = userProvider.user!; 
    _apiService = ApiService(_user.tokens);
  }
  
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

  Future<void> _selectVideoFromGallery() async {
    FilePickerResult? mediaFiles = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.video,
    );

    if (mediaFiles != null) {
      List<File> files = mediaFiles.paths.map((path) => File(path!)).toList();
      List<CustomFile> customFiles = [];

      for (File file in files) {
        final metadata = await _extractVideoMetadata(file.path);

        customFiles.add(CustomFile(
          name: file.path.split('/').last,
          size: file.lengthSync(),
          file: XFile(file.path),
          thumbnail: VideoThumbnail(
            key: ValueKey(file.path),
            videoPath: file.path,
          ),
          progress: 0,
          estimate: Duration.zero,
          duration: metadata['duration'],
          width: metadata['width'],
          height: metadata['height'],
          orientation: metadata['orientation'],
          date: metadata['date'],
          framerate: metadata['framerate'],
          location: metadata['location'] ?? "",
        ));
      }

      setState(() {
        _selectedFiles = customFiles;
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

              try {
                await _uploadFiles();
              
                // Visual feedback
                final snackbar = SnackBar(
                  content: const Text('Videos submitted successfully!'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
                
                // Remove uploaded videos
                setState(() {
                  _selectedFiles = [];
                });
              } catch (e) {
                if (mounted) {
                  _showErrorDialog(e.toString());
                }
              } finally {
                setState(() {
                  _isUploading = false;
                });
              }
              
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

  Future<void> _uploadFiles() async {
    final tempDir = await getTemporaryDirectory();
    List<Future> uploads = [];

    for (int i = 0; i < _selectedFiles.length; i++) {
      CustomFile uploadFile = _selectedFiles[i];

      // Get the address where we will upload the file
      String? uri = '';
      try {
        uri = await _getUploadUrl(uploadFile);
        uri = uri?.replaceAll("localhost", "10.0.2.2"); // TODO: Fix this for production
      } catch (e) {
        throw Exception('Error getting upload URL: $e');
      }

      uploads.add(_uploadToTus(uploadFile, uri, tempDir));

    }

    // Wait for all uploads to complete
    await Future.wait(uploads);
  }

  Future<String?> _getUploadUrl(CustomFile uploadFile) async {
    try {
      final response = await _apiService.dio.post(
        '/api/uploads',
        options: Options(
          headers: {
            'file_name': uploadFile.name,
            'file_length': uploadFile.size,
            'journalist': _user.name,
            'duration': uploadFile.duration,
            'width': uploadFile.width,
            'height': uploadFile.height,
          },
        ),
      );
    
      if (response.statusCode == 201) {
        return response.headers.map['location']?.first;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '${response.statusCode} - ${response.data}'
        );
      }
    } on DioException catch (e) {
      throw Exception('Error connecting to server: ${e.message}');
    }
  }
  

  Future<void> _uploadToTus(CustomFile uploadFile, String? uri, Directory tempDir) async {

    // Create a temporary directory for this file
    final tempDirectory = Directory('${tempDir.path}/${uploadFile.file.name}_upload');
    if (!tempDirectory.existsSync()) {
      tempDirectory.createSync(recursive: true);
    }

    final accessToken = await _user.tokens.getAccessToken();
    
    final tusClient = TusClient(
      url: uri!, 
      file: uploadFile.file,
      chunkSize: 1.MB,
      timeout: Duration(seconds: 30),
      cache: TusPersistentCache(tempDirectory.path),
      httpClient: httpClient,
      headers: {
        'Authorization': 'Bearer $accessToken',
      }
    );

    // Since the way the package works it always sends a POST first and our server doesn't support that, 
    // we need set the upload URL in the cache before calling startUpload so that the package thinks it's resuming an upload,
    // therefore it will send a PATCH request instead of a POST
    await tusClient.cache?.set(tusClient.fingerprint, uri);

    // Completer to control when this function is complete
    final completer = Completer<void>();
  
    void performUpload() {
      tusClient.startUpload(
        onProgress: (count, total, response) {
          if (!completer.isCompleted) {
            setState(() {
              uploadFile.progress = count / total * 100;
            });
          }
        },

        onComplete: (response) {
          if (!completer.isCompleted) {
            setState(() {
              uploadFile.progress = 100;
            });
            tempDirectory.deleteSync(recursive: true);
            completer.complete();
          }
        },

        onError: (error) async {
          if (error.toString().contains('401') && !completer.isCompleted) { // Token rejected
            try {
              final refreshSuccess = await _user.tokens.refreshTokensHttpClient();
              
              if (refreshSuccess) {
                final newAccessToken = await _user.tokens.getAccessToken();
                tusClient.headers['Authorization'] = 'Bearer $newAccessToken';
                
                // Retry the upload with new token
                performUpload();
                return;
              }
            } catch (refreshError) {
              if (!completer.isCompleted) {
                completer.completeError('Error refreshing token: $refreshError');
              }
              return;
            }
          }
          else if (!completer.isCompleted) {
            completer.completeError('Error uploading ${uploadFile.file.name}: $error');
          }
        },

        onTimeout: () {
          if (!completer.isCompleted) {
            completer.completeError('Timeout while uploading ${uploadFile.file.name}');
          }
        }
      );
    }

    // Start the initial upload
    performUpload();
    
    // Return the Future from the completer
    return completer.future;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
          backgroundColor: themeManager.theme.backgroundColor,
          titleTextStyle: TextStyle(
            color: themeManager.theme.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: themeManager.theme.textColor,
            fontSize: 16,
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _extractVideoMetadata(String filePath) async {
    final videoInfo = FlutterVideoInfo();
    final info = await videoInfo.getVideoInfo(filePath);

    if (info == null) {
      throw Exception('Failed to extract video metadata');
    }

    return {
      'duration': (info.duration ?? 0) / 1000, // ms to seconds
      'width': info.width ?? 0,
      'height': info.height ?? 0,
      'date': info.date ?? "",
      'orientation': info.orientation ?? "",
      'framerate': info.framerate ?? 0,
      'location ': info.location  ?? "",
    };
  }


  @override
  void dispose() {
    // Close the client when the page is disposed
    httpClient.close();
    super.dispose();
  }
}

