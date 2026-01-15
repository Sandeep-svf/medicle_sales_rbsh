import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ImageOverlayUtil {
  static Future<File> addOverlay({
    required File original,
    required double lat,
    required double lng,
  }) async {
    // 1. Load the Captured Image
    final data = await original.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    // ============================================================
    // DYNAMIC SCALING (Fixes visibility on high-res cameras)
    // ============================================================
    final double width = image.width.toDouble();
    final double height = image.height.toDouble();

    // Calculate sizes relative to image width/height
    final double overlayHeight = height * 0.15; // 15% of image height
    final double titleFontSize = width * 0.045; // 4.5% of width
    final double bodyFontSize = width * 0.035;  // 3.5% of width
    final double smallFontSize = width * 0.03;  // 3.0% of width
    final double logoSize = width * 0.15;       // 15% of width
    final double padding = width * 0.04;        // 4% padding

    // 2. Prepare Canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw Original Image
    canvas.drawImage(image, Offset.zero, Paint());

    // 3. Draw Dark Gradient Overlay at Bottom
    final overlayRect = Rect.fromLTWH(
      0,
      height - overlayHeight,
      width,
      overlayHeight,
    );

    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, height - overlayHeight),
        Offset(0, height),
        [
          Colors.black.withOpacity(0.0), // Transparent top
          Colors.black.withOpacity(0.8), // Dark bottom
        ],
        [0.0, 0.4],
      );

    canvas.drawRect(overlayRect, bgPaint);

    // 4. Draw Logo (Safely)
    // IMPORTANT: Make sure this path exists in pubspec.yaml
    const String logoPath = 'assets/logos/faviicons_glucks_care_dark.jpg';

    try {
      final ByteData logoData = await rootBundle.load(logoPath);
      final logoCodec = await ui.instantiateImageCodec(logoData.buffer.asUint8List());
      final logoFrame = await logoCodec.getNextFrame();
      final ui.Image logoImage = logoFrame.image;

      canvas.drawImageRect(
        logoImage,
        Rect.fromLTWH(0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
        Rect.fromLTWH(padding, height - overlayHeight + padding, logoSize, logoSize),
        Paint(),
      );
    } catch (e) {
      print("Warning: Logo asset not found ($logoPath). Text will still appear.");
    }

    // 5. Draw Text
    // Offset text to the right of the logo
    final double textLeftMargin = padding + logoSize + padding;

    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: ui.TextDirection.ltr,
    );

    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: 'Location Verified\n',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(2, 2))],
          ),
        ),
        TextSpan(
          text: 'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}\n',
          style: TextStyle(
            color: Colors.white70,
            fontSize: bodyFontSize,
            height: 1.5,
          ),
        ),
        TextSpan(
          text: DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.now()),
          style: TextStyle(
            color: Colors.white60,
            fontSize: smallFontSize,
            height: 1.5,
          ),
        ),
      ],
    );

    textPainter.text = textSpan;
    textPainter.layout(maxWidth: width - textLeftMargin - padding);

    // Center text vertically in the overlay box
    final double textY = (height - overlayHeight) + (overlayHeight - textPainter.height) / 2;

    textPainter.paint(
      canvas,
      Offset(textLeftMargin, textY),
    );

    // 6. Save and Return
    final picture = recorder.endRecording();
    final finalImage = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/overlay_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());

    return file;
  }
}