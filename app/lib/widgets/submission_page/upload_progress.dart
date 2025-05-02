import 'package:flutter/material.dart';
import 'package:app/data/custom_file.dart';

class UploadProgress extends StatelessWidget {
  final CustomFile file;

  const UploadProgress({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: file.progress / 100),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${file.progress.toStringAsFixed(1)}%', 
              )
            ],
          )
        ],
      ),
    );
  }
}