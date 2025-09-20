// lib/screens/report_screen.dart

import 'dart:io'; // <-- THIS IS THE CORRECTED LINE
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../api/api_service.dart';

class ReportScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Position location;

  const ReportScreen({
    super.key,
    required this.cameras,
    required this.location,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile;
  bool _isSubmitting = false;
  final ApiService _apiService = ApiService();

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
      setState(() { _imageFile = image; });
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  // In lib/screens/report_screen.dart, inside the _ReportScreenState class

  void _submitReport() async {
    if (_imageFile == null) return;
    setState(() { _isSubmitting = true; });

    try {
      // Step 1: Upload the image and get the URL
      final imageUrl = await _apiService.uploadImage(File(_imageFile!.path));
      
      // Step 2: Submit the report with the real image URL
      await _apiService.submitReport(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
        imageUrl: imageUrl, // Use the real URL from Cloudinary
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.teal),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSubmitting = false; });
      }
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
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 40, left: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 30),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    if (_isSubmitting)
                      const Expanded(child: Center(child: CircularProgressIndicator()))
                    else
                      Container(
                        padding: const EdgeInsets.only(bottom: 50, top: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          ),
                        ),
                        child: _imageFile == null
                            ? _buildCaptureControl()
                            : _buildConfirmControls(),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCaptureControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _takePicture,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(color: Colors.white, width: 4),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildConfirmControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => setState(() => _imageFile = null),
          icon: const Icon(Icons.replay, color: Colors.white, size: 40),
        ),
        GestureDetector(
          onTap: _submitReport,
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(width: 40), // Spacer
      ],
    );
  }
}