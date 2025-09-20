// lib/screens/home_screen.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:fixmap_app/widgets/photo_marker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:http/http.dart' as http;
import 'report_screen.dart';
import '../api/api_service.dart';
import 'login_screen.dart';
import 'my_reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final ApiService _apiService = ApiService();
  Position? _currentPosition;
  List<MarkerData> _customMarkers = [];
  bool _isLoadingMarkers = true;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(34.03313, -5.00028),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _determinePosition();
    await _fetchPublicReports();
  }

  Future<void> _fetchPublicReports() async {
    if (mounted) setState(() { _isLoadingMarkers = true; });
    try {
      final reports = await _apiService.getAllPublicReports();
      final List<MarkerData> markers = [];
      
      for (var report in reports) {
        // 1. Download the image from the URL
        final http.Response response = await http.get(Uri.parse(report['image_url']));
        final Uint8List imageData = response.bodyBytes;

        // 2. Create the marker only after the download is complete
        markers.add(
          MarkerData(
            marker: Marker(
              markerId: MarkerId(report['id'].toString()),
              position: LatLng(
                double.parse(report['latitude'].toString()),
                double.parse(report['longitude'].toString()),
              ),
            ),
            // 3. Pass the downloaded image data to our widget
            child: PhotoMarker(imageData: imageData),
          ),
        );
      }

      if (mounted) {
        setState(() {
          _customMarkers = markers;
          _isLoadingMarkers = false;
        });
      }
    } catch (e) {
      print('Failed to fetch public reports: $e');
      if (mounted) setState(() { _isLoadingMarkers = false; });
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied.')));
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16.0,
        )
      ));
    }
  }
  
  void _onReportButtonPressed() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Getting your location... Please wait.')));
      await _determinePosition();
      return;
    }
    
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No camera found on this device.')));
      return;
    }

    if(mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReportScreen(
            cameras: cameras,
            location: _currentPosition!,
          ),
        ),
      );
    }
  }

  void _logout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FixMap'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Reports',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MyReportsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomGoogleMapMarkerBuilder(
            customMarkers: _customMarkers,
            builder: (BuildContext context, Set<Marker>? markers) {
              return GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialPosition,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: markers ?? {},
                onMapCreated: (GoogleMapController controller) {
                  _mapController.complete(controller);
                },
              );
            },
          ),
          Positioned(
            top: 10,
            right: 15,
            left: 15,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.search, color: Colors.grey),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un lieu...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15, bottom: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoadingMarkers)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onReportButtonPressed,
        label: const Text('Signaler'),
        icon: const Icon(Icons.add_a_photo_outlined),
        backgroundColor: Colors.teal,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}