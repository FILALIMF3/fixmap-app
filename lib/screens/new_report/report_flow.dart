import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fixmap_app/api/api_service.dart';
import 'package:fixmap_app/screens/new_report/add_details_screen.dart';
import 'package:fixmap_app/screens/new_report/confirm_location_screen.dart';
import 'package:fixmap_app/screens/new_report/take_photo_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportFlow extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Position location;

  const ReportFlow({
    super.key,
    required this.cameras,
    required this.location,
  });

  @override
  State<ReportFlow> createState() => _ReportFlowState();
}

class _ReportFlowState extends State<ReportFlow> {
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();

  XFile? _imageFile;
  LatLng? _confirmedLocation;

  void _onPhotoTaken(XFile image) {
    setState(() => _imageFile = image);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _onLocationConfirmed(LatLng location) {
    setState(() => _confirmedLocation = location);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _onDetailsAdded(String title, String description) async {
    if (_imageFile == null || _confirmedLocation == null) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final imageUrl = await _apiService.uploadImage(File(_imageFile!.path));
      await _apiService.submitReport(
        latitude: _confirmedLocation!.latitude,
        longitude: _confirmedLocation!.longitude,
        imageUrl: imageUrl,
        // Optional: Pass title and description if API supports it
      );

      Navigator.of(context).pop(); // Dismiss loading dialog
      Navigator.of(context).pop(); // Pop back from the report flow
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          TakePhotoScreen(
            cameras: widget.cameras,
            onPhotoTaken: _onPhotoTaken,
            onBackPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ConfirmLocationScreen(
            initialPosition: widget.location,
            onLocationConfirmed: _onLocationConfirmed,
            onBackPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            },
          ),
          AddDetailsScreen(
            onDetailsAdded: _onDetailsAdded,
            onBackPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            },
          ),
        ],
      ),
    );
  }
}
