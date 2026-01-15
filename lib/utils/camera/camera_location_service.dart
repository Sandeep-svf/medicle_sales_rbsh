import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class CameraLocationResult {
  final File image;
  final double latitude;
  final double longitude;

  CameraLocationResult({
    required this.image,
    required this.latitude,
    required this.longitude,
  });
}

class CameraLocationService {
  static final ImagePicker _picker = ImagePicker();

  static Future<CameraLocationResult?> captureImageWithLocation() async {
    // 1. Check GPS permission
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location service disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied");
    }

    // 2. Get current location
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 3. Capture image (CAMERA ONLY)
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (photo == null) return null;

    return CameraLocationResult(
      image: File(photo.path),
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
