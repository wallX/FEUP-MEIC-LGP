import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:app/widgets/submission_page/video/video_thumbnail.dart';
import 'package:cross_file/cross_file.dart' show XFile;
import 'package:app/data/custom_file.dart';
import 'package:app/widgets/submission_page/file_list.dart';
import 'package:app/services/api_service.dart';
import 'package:app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:app/data/user.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'dart:async';
import 'package:app/provider/submission_provider.dart';
import 'package:app/services/upload_service.dart';

class SubmissionPage extends StatefulWidget {
  const SubmissionPage({super.key});
  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {

  late final ApiService _apiService;
  late final User _user;
  late final SubmissionProvider _submissionProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _user = userProvider.user!; 
    _apiService = ApiService(_user.tokens);

    _submissionProvider = Provider.of<SubmissionProvider>(context, listen: false);

    if (!_submissionProvider.isUploadServiceInitialized) {
      _submissionProvider.uploadService(UploadService(_apiService, _user));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _submissionProvider,
      builder: (context, _){
        return Scaffold(
          body: _buildUI(),
          floatingActionButton: _selectVideoFromGalleryButton(),
        );
      }
    );
  }

  Widget _buildUI() {
    return Container(
      child: _submissionProvider.isEmpty()
          ? Center( // Empty
              child: Text('No video selected'),
            )

          : Column(
              children: [
                Expanded(
                  child: FileList(
                    files: _submissionProvider.selectedFiles,
                    isUploading: _submissionProvider.isUploading,
                    onRemove: _submissionProvider.isUploading ? null : (index) {
                      _submissionProvider.removeFile(index);
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
    return _submissionProvider.isUploading ? 
      const SizedBox.shrink() :
      FloatingActionButton(
      onPressed: _submissionProvider.isUploading ? null : _selectVideoFromGallery,
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
      List<CustomFile> customFiles = _submissionProvider.selectedFiles;

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
      _submissionProvider.setFiles(customFiles);
    }
  }

  Widget _submitButton() {
    return ElevatedButton(

      onPressed: _submissionProvider.isUploading 
          ? null 
          : () async {
              _submissionProvider.setUploading(true);

              try {
                await _submissionProvider.startUpload();

                if (mounted){
                  // Show success message
                  final snackbar = SnackBar(
                    content: const Text('Videos submitted successfully!'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                }
                _submissionProvider.clearFiles();

              } catch (e) {
                if (mounted) {
                  _showErrorDialog(e.toString());
                }
              } finally {
                _submissionProvider.setUploading(false);
              }
              
            },

      child: _submissionProvider.isUploading 
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Row(
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
                  ),
                ),
                
                // Control buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pause button
                    TextButton.icon(
                      onPressed: () {
                        _submissionProvider.pauseUpload();
                      },
                      icon: Icon(
                        _submissionProvider.isPaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white, 
                        size: 16
                      ),
                      label: Text(
                        _submissionProvider.isPaused ? 'Resume' : 'Pause', 
                        style: TextStyle(color: Colors.white, fontSize: 12)
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size(60, 24),
                      ),
                    ),
                    
                    // Cancel button
                    TextButton.icon(
                      onPressed: () {
                        _submissionProvider.cancelUpload();
                      },
                      icon: Icon(
                        Icons.cancel, 
                        color: Colors.white, 
                        size: 16
                      ),
                      label: Text(
                        'Cancel', 
                        style: TextStyle(color: Colors.white, fontSize: 12)
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size(60, 24),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : const Text('Submit Videos'),
    );
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
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
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
}

