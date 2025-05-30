import 'dart:async';
import 'dart:io';
import 'package:app/data/app_constants.dart';
import 'package:app/data/custom_file.dart';
import 'package:app/data/user.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tusc/tusc.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class UploadService {
  final ApiService _apiService;
  final User _user;
  final http.Client _httpClient = http.Client();
  bool isPaused = false;
  final List<TusClient> _tusClients  = [];
  
  UploadService(this._apiService, this._user);
  
  Future<List<void>> uploadFiles(List<CustomFile> files, void Function(CustomFile file, double progress) onProgressUpdate) async {
    final tempDir = await getTemporaryDirectory();
    List<Future> uploads = [];
    
    for (int i = 0; i < files.length; i++) {
      CustomFile uploadFile = files[i];
      
      // Get the address where we will upload the file
      String? uri = '';
      try {
        uri = await _getUploadUrl(uploadFile);
        uri = uri?.replaceAll("http://localhost", AppConstants.apiBaseUrl);
      } catch (e) {
        throw Exception('Error getting upload URL: $e');
      }
      
      uploads.add(_uploadToTus(uploadFile, uri, tempDir, onProgressUpdate));
    }
    
    return Future.wait(uploads);
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
            'notes':uploadFile.notes ?? '',
            'location': uploadFile.location,
            'date': uploadFile.date,
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
  
  Future<void> _uploadToTus(
    CustomFile uploadFile, 
    String? uri, 
    Directory tempDir,
    void Function(CustomFile file, double progress) onProgressUpdate
  ) async {
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
      httpClient: _httpClient,
      headers: {
        'Authorization': 'Bearer $accessToken',
      }
    );

    _tusClients.add(tusClient);

    // Set upload URL in cache before calling startUpload
    await tusClient.cache?.set(tusClient.fingerprint, uri);

    // Completer to control when this function is complete
    final completer = Completer<void>();
  
    void performUpload() {
      tusClient.startUpload(
        onProgress: (count, total, response) {
          if (!completer.isCompleted) {
            double progress = count / total * 100;
            uploadFile.progress = progress;
            onProgressUpdate(uploadFile, progress);
          }
        },

        onComplete: (response) {
          if (!completer.isCompleted) {
            uploadFile.progress = 100;
            onProgressUpdate(uploadFile, 100);
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
  
  void dispose() {
    _tusClients.clear();
  }

  void pauseUpload() async {
    if (isPaused) {
      for (final client in _tusClients) {
        if (await client.canResume()) {
          client.resumeUpload();
        }
        
      }
      isPaused = false;
    } else {
      for (final client in _tusClients) {
        client.pauseUpload();
      }
      isPaused = true;
    }
  }

  void cancelUpload() {
    for (final client in _tusClients) {
      client.cancelUpload();
    }
    _tusClients.clear();
  }
}