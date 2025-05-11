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
              ),
              Text(
                'Est: ${_printDuration(file.estimate)}',
              ),
            ],
          )
        ],
      ),
    );
  }
  
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}