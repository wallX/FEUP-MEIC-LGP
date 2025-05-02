import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/error_dialog.dart';



class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late final List<CameraDescription> _cameras;
  late CameraController _controller;
  bool _isInitialized = false;
  bool _isRecording = false;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        if(mounted) {
          ErrorDialog.show(
            context: context,
            message: 'No cameras available',
            title: 'Camera Error',
          );
        }
        return;
      }

      final camera = _cameras.first;

      _controller = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: true,
      );
      await _controller.initialize().then((_) async {
        if (mounted) {
          await _controller.prepareForVideoRecording();
          _minAvailableZoom = await _controller.getMinZoomLevel();
          _maxAvailableZoom = await _controller.getMaxZoomLevel();
          setState(() {  
            _isInitialized = true;
          });
        }
      });
    } on Exception catch (e) {
      if(mounted) {
        if (e is CameraException) {
          ErrorDialog.show(
            context: context,
            message: 'Error initializing camera: $e',
            title: 'Camera Error',
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    _cameras.clear();
    _isInitialized = false;
    _isRecording = false;
    _minAvailableZoom = 1.0;
    _maxAvailableZoom = 1.0;
    _currentZoom = 1.0;
    _baseZoom = 1.0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: _buildTransparentArrowBack(),
      body: Column(
        children: [
          _buildCameraPreview(),
          _buildRecordingControls(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTransparentArrowBack(){
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return GestureDetector(
      onScaleStart: (details) {
        _baseZoom = _currentZoom;
      },
      onScaleUpdate: (details) {
        _setZoomLevel(_baseZoom * details.scale);
      },
      child: CameraPreview(_controller),
    );
  }


  Widget _buildRecordingControls() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          if (_isRecording) _buildIsRecordingText(),
          _buildZoomControls(),
          const SizedBox(height: 20),
          _buildToggleRecordingButton(),
          
        ],
      ),
    );
  }

  Widget _buildIsRecordingText(){
    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: Colors.red, size: 12),
          SizedBox(width: 8),
          Text(
            'Recording',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRecordingButton() {
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 4,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isRecording ? 32 : 62,
            height: _isRecording ? 32 : 62,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(_isRecording ? 8 : 31),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
    
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.remove, color: Colors.white),
            onPressed: () => _setZoomLevel(_currentZoom - 0.5),
          ),
        ),
    
        const SizedBox(width: 16),
    
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _setZoomLevel(_currentZoom + 0.5),
          ),
        ),
        const SizedBox(height: 16),
        
      ],
    );
  }

  Future<void> _startRecording() async {
    if (_isRecording) {
      return;
    }

    try {
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } on CameraException catch (e) {
      if(mounted) {
        ErrorDialog.show(
          context: context,
          message: 'Error starting video recording: $e',
          title: 'Camera Error',
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) {
      return;
    }

    try {
      XFile video = await _controller.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
    } on CameraException catch (e) {
      if(mounted) {
        ErrorDialog.show(
          context: context,
          message: 'Error stopping video recording: $e',
          title: 'Camera Error',
        );
      }
    }
  }

  Future<void> _setZoomLevel(double zoom) async {
    zoom = zoom.clamp(_minAvailableZoom, _maxAvailableZoom);
    
    try {
      await _controller.setZoomLevel(zoom);
      setState(() {
        _currentZoom = zoom;
      });
    } catch (e) {
      if(mounted) {
        ErrorDialog.show(
          context: context,
          message: 'Error while trying to zoom: $e',
          title: 'Camera Error',
        );
      }
    }
  }
}