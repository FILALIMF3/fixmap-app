import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ConfirmLocationScreen extends StatefulWidget {
  final Position initialPosition;
  final Function(LatLng) onLocationConfirmed;
  final Function() onBackPressed;

  const ConfirmLocationScreen({
    super.key,
    required this.initialPosition,
    required this.onLocationConfirmed,
    required this.onBackPressed,
  });

  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  late GoogleMapController _googleMapController;
  late LatLng _markerPosition;

  @override
  void initState() {
    super.initState();
    _markerPosition =
        LatLng(widget.initialPosition.latitude, widget.initialPosition.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _markerPosition,
              zoom: 18.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
              _googleMapController = controller;
            },
            onCameraMove: (CameraPosition position) {
              setState(() {
                _markerPosition = position.target;
              });
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          const Center(
            child: Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 50,
            ),
          ),
          _buildConfirmationButton(),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 40,
      left: 10,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
        onPressed: widget.onBackPressed,
      ),
    );
  }

  Widget _buildConfirmationButton() {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: ElevatedButton(
        onPressed: () {
          widget.onLocationConfirmed(_markerPosition);
        },
        child: const Text('Confirm Location'),
      ),
    );
  }
}
