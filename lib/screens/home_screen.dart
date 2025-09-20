import 'dart:async';
import 'package:camera/camera.dart';
import 'package:fixmap_app/api/api_service.dart';
import 'package:fixmap_app/screens/my_reports_screen.dart';
import 'package:fixmap_app/screens/new_report/report_flow.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final ApiService _apiService = ApiService();
  Position? _currentPosition;
  Set<Marker> _markers = {};
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
    if (mounted) setState(() => _isLoadingMarkers = true);
    try {
      final reports = await _apiService.getAllPublicReports();
      final Set<Marker> markers = {};
      for (var report in reports) {
        markers.add(
          Marker(
            markerId: MarkerId(report['id'].toString()),
            position: LatLng(
              double.parse(report['latitude'].toString()),
              double.parse(report['longitude'].toString()),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
      if (mounted) {
        setState(() {
          _markers = markers;
          _isLoadingMarkers = false;
        });
      }
    } catch (e) {
      print('Failed to fetch public reports: $e');
      if (mounted) setState(() => _isLoadingMarkers = false);
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Getting your location...')));
      await _determinePosition();
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera found.')));
      return;
    }
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ReportFlow(cameras: cameras, location: _currentPosition!),
        ),
      );
    }
  }

  void _goToMyReports() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MyReportsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _markers,
          ),
          _buildTopBar(),
          _buildBottomBar(),
          if (_isLoadingMarkers)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FixMap', style: Theme.of(context).textTheme.headlineSmall),
              IconButton(
                icon: const Icon(Icons.list_alt_outlined),
                onPressed: _goToMyReports,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
              label: const Text('Create a New Report'),
              onPressed: _onReportButtonPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
