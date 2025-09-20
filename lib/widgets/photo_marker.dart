// lib/widgets/photo_marker.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';

class PhotoMarker extends StatelessWidget {
  final Uint8List imageData;

  const PhotoMarker({super.key, required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          imageData,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}