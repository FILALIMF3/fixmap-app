import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class TakePhotoScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(XFile) onPhotoTaken;
  final Function() onBackPressed;

  const TakePhotoScreen({
    super.key,
    required this.cameras,
    required this.onPhotoTaken,
    required this.onBackPressed,
  });

  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() => _imageFile = image);
      widget.onPhotoTaken(image);
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: _imageFile == null
                    ? CameraPreview(_controller)
                    : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
              ),
              _buildCaptureControl(),
              _buildBackButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 40,
      left: 10,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        onPressed: widget.onBackPressed,
      ),
    );
  }

  Widget _buildCaptureControl() {
    return Positioned(
      bottom: 50,
      child: GestureDetector(
        onTap: _takePicture,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.5),
            border: Border.all(color: Colors.white, width: 4),
          ),
        ),
      ),
    );
  }
}
