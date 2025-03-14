import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:app/widgets/video/video_thumbnail.dart';


class SubmissionPage extends StatefulWidget {
  const SubmissionPage({super.key});

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage>{

  List<File> _selectedFiles = [];
  List<VideoThumbnail> _thumbnails = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      floatingActionButton: _selectVideoFromGalleryButton(),
    );
  }

  Widget _buildUI() {
    return Container(
      child: _selectedFiles.isEmpty
        ? const Center(
            child: Text('No video selected'),
          )

        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('File ${index + 1}'),
                      subtitle: Text(_selectedFiles[index].path),
                      leading: _thumbnails[index],
                      trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedFiles.removeAt(index);
                              _thumbnails.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.close)),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Connect to EVS API to submit videos
                    final snackbar = SnackBar(
                      content: const Text('Videos submitted successfully!'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    setState(() {
                      _selectedFiles = [];
                      _thumbnails = [];
                    });
                  },
                  child: const Text('Submit Videos'),
                ),
              ),
            ],
          ),
          
    );
  }

  Widget _selectVideoFromGalleryButton() {
    return FloatingActionButton(
      onPressed: () async {
        FilePickerResult? mediaFiles = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.video,
        );

        if (mediaFiles != null) {
          List<File> files = mediaFiles.paths.map((path) => File(path!)).toList();
          List<VideoThumbnail> thumbnails = files.map((file) => VideoThumbnail(videoPath: file.path)).toList();

          setState(() {
            _selectedFiles = files;
            _thumbnails = thumbnails;
          });
        }
      },
      tooltip: 'Select video from gallery',
      child: const Icon(Icons.video_library),
    );
  }

}