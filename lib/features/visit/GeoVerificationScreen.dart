import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

// --- YOUR IMPORTS ---
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../../../../utils/camera/CameraLocationResult.dart';

// --- CONSTANTS FOR ANIMATION ---
const Duration kAnimationDuration = Duration(milliseconds: 600);
const Curve kAnimationCurve = Curves.easeOutQuart;

class GeoVerificationScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const GeoVerificationScreen({
    super.key,
    required this.doctorId,
    this.doctorName = "Doctor",
  });

  @override
  State<GeoVerificationScreen> createState() => _GeoVerificationScreenState();
}

class _GeoVerificationScreenState extends State<GeoVerificationScreen> with TickerProviderStateMixin {
  // Logic Variables
  File? _capturedImage;
  bool _isProcessing = false;
  final AuthManager _authManager = AuthManager();

  // Animation Controllers
  late AnimationController _scanController;     // For the laser scanning effect
  late AnimationController _pulseController;    // For the capture button pulse
  late AnimationController _entryController;    // For screen entrance

  // Animations
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // 1. Scanner Line Animation (Loops)
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _scanController, curve: Curves.easeInOut));

    // 2. Pulse Animation (Loops)
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // 3. Entry Animation (One time)
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)));

    _entryController.forward();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // LOGIC SECTION
  // ===========================================================================

  Future<void> _capturePhoto() async {
    HapticFeedback.lightImpact(); // Modern feel
    final result = await CameraLocationService.captureImageWithLocation();
    if (result == null) return;

    setState(() => _isProcessing = true);
    _scanController.repeat(reverse: true); // Start scanning animation

    try {
      // Simulate "scanning" delay for UX feel (optional, remove if unwanted)
      await Future.delayed(const Duration(milliseconds: 800));

      final File? watermarked = await _addWatermark(result);
      if (watermarked != null) {
        setState(() => _capturedImage = watermarked);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Processing failed",
        backgroundColor: TColors.primary.withOpacity(0.1), // Pink tint
        colorText: TColors.primary, // Pink text
        snackPosition: SnackPosition.BOTTOM,
      );    } finally {
      _scanController.stop();
      _scanController.reset();
      setState(() => _isProcessing = false);
    }
  }

  Future<File?> _addWatermark(CameraLocationResult result) async {
    // ... [KEEPING YOUR EXISTING LOGIC INTACT, JUST COMPACTED] ...
    try {
      final bytes = await result.image.readAsBytes();
      final img.Image? original = img.decodeImage(bytes);
      if (original == null) return null;

      int w = original.width;
      int h = original.height;
      int barHeight = (h * 0.18).toInt();

      img.fillRect(original, x1: 0, y1: h - barHeight, x2: w, y2: h, color: img.ColorRgb8(0, 0, 0));

      try {
        final ByteData assetData = await rootBundle.load('assets/logos/faviicons_glucks_care_dark.jpg');
        final Uint8List logoBytes = assetData.buffer.asUint8List();
        img.Image? logo = img.decodeImage(logoBytes);
        if (logo != null) {
          int logoH = (barHeight * 0.7).toInt();
          img.Image resizedLogo = img.copyResize(logo, height: logoH);
          int logoY = h - barHeight + ((barHeight - logoH) ~/ 2);
          img.compositeImage(original, resizedLogo, dstX: 40, dstY: logoY);
        }
      } catch (e) {}

      String date = DateFormat('dd MMM yyyy').format(DateTime.now());
      String time = DateFormat('hh:mm a').format(DateTime.now());
      String lat = "Lat: ${result.latitude.toStringAsFixed(5)}";
      String lng = "Lng: ${result.longitude.toStringAsFixed(5)}";

      int textX = w ~/ 3;
      int textYStart = h - barHeight + 30;
      int lineHeight = 40;

      void drawLine(String text, int yOffset) {
        img.drawString(original, text, font: img.arial48, x: textX, y: textYStart + yOffset, color: img.ColorRgb8(255, 255, 255));
      }

      drawLine("$date | $time", 0);
      drawLine("$lat, $lng", lineHeight);
      drawLine("Loc: ${widget.doctorName}", lineHeight * 2);

      final newBytes = img.encodeJpg(original, quality: 85);
      return File(result.image.path)..writeAsBytesSync(newBytes);
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitPhoto() async {
    HapticFeedback.mediumImpact();
    if (_capturedImage == null) return;

    // 1. Loading Popup with Primary Color
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: "Uploading...",
      text: "Verifying Location",
      disableBackBtn: true,
      barrierColor: Colors.black.withOpacity(0.7),
      confirmBtnColor: TColors.primary, // <--- PINK BUTTON
      headerBackgroundColor: TColors.primary, // <--- PINK HEADER
    );

    try {
      String? token = await _authManager.getAuthToken();
      if (token == null) {
        Navigator.pop(context);
        return;
      }

      var uri = Uri.parse('${THttpHelper.baseUrl}/doctors/${widget.doctorId}/geo-image');
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({'Authorization': 'Bearer $token'});

      var stream = http.ByteStream(_capturedImage!.openRead());
      var length = await _capturedImage!.length();
      var multipartFile = http.MultipartFile(
          'geo_image',
          stream,
          length,
          filename: 'geo_verification.jpg',
          contentType: MediaType('image', 'jpeg')
      );
      request.files.add(multipartFile);

      var response = await http.Response.fromStream(await request.send());
      Navigator.pop(context); // Pop Loader

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(result: true);

        // 2. Success Snackbar with Primary Color
        Get.snackbar(
          "Verified",
          "Location Verified Successfully",
          backgroundColor: TColors.primary, // <--- PINK BACKGROUND
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          borderRadius: 20,
          icon: const Icon(Icons.verified, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      } else {
        // 3. Error Popup with Primary Color (for consistency)
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Upload Failed",
          confirmBtnColor: TColors.primary, // <--- PINK BUTTON
        );
      }
    } catch (e) {
      Navigator.pop(context);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Error: $e",
        confirmBtnColor: TColors.primary, // <--- PINK BUTTON
      );
    }
  }

  // ===========================================================================
  // UI BUILD SECTION
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    // 1. LayoutBuilder ensures we know available space to prevent overflow
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // A. Dynamic Background
              _buildModernBackground(constraints),

              // B. Main Scrollable Content
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - MediaQuery.of(context).padding.top),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Custom App Bar
                              _buildCustomAppBar(),

                              const SizedBox(height: 30),

                              // 2. Doctor Info Card (Glassmorphism)
                              _buildDoctorInfoCard(),

                              const SizedBox(height: 30),

                              // 3. The "Viewfinder" (Camera Area)
                              // This will take available space but have a minimum height
                              SizedBox(
                                height: constraints.maxHeight * 0.5, // 50% of screen height
                                child: _buildViewFinder(),
                              ),

                              const SizedBox(height: 30),

                              // 4. Bottom Controls
                              _buildBottomControls(),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildModernBackground(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white, // Fallback
      ),
      child: CustomPaint(
        painter: MeshGradientPainter(
          primary: TColors.primary,
          secondary: TColors.primary_shade200,
          tertiary: TColors.primary_shade50,
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: TColors.primary),
          ),
        ),
        Text(
          "VERIFICATION",
          style: TextStyle(
            color: TColors.primary_shade800,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2.0,
          ),
        ),
        // Empty container to balance the row
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildDoctorInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // Semi-transparent
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(color: TColors.primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.primary_shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.medication_rounded, color: TColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("VISIT LOCATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(
                  widget.doctorName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Verified Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _capturedImage != null ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _capturedImage != null ? "READY" : "PENDING",
              style: TextStyle(
                  color: _capturedImage != null ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 10
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildViewFinder() {
    return AnimatedContainer(
      duration: kAnimationDuration,
      curve: kAnimationCurve,
      decoration: BoxDecoration(
        color: Colors.black, // Dark viewfinder background
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: TColors.primary.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15)),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. The Image or Placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: _capturedImage != null
                ? Image.file(_capturedImage!, fit: BoxFit.cover)
                : _buildEmptyState(),
          ),

          // 2. Processing Overlay (Scanning Line)
          if (_isProcessing)
            _buildScanningEffect(),

          // 3. Viewfinder Corners (Custom Paint)
          IgnorePointer(
            child: CustomPaint(
              painter: ViewfinderPainter(color: Colors.white.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 50, color: TColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text("CAPTURE EVIDENCE", style: TextStyle(color: TColors.primary_shade800, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 5),
          Text("Ensure clear visibility of location", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildScanningEffect() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ScannerPainter(
            scanValue: _scanAnimation.value,
            color: TColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    if (_capturedImage == null) {
      return GestureDetector(
        onTap: _capturePhoto,
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [TColors.primary, TColors.primary_shade400]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: TColors.primary_shadow_dark, blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.center_focus_weak, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text("INITIATE CAPTURE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildSecondaryButton(
            icon: Icons.refresh_rounded,
            label: "RETAKE",
            onTap: _capturePhoto,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPrimaryButton(
            icon: Icons.check_circle_rounded,
            label: "SUBMIT",
            onTap: _submitPhoto,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: TColors.success,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TColors.primary.withOpacity(0.2), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: TColors.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: TColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// CUSTOM PAINTERS (FOR THAT 1000-LINE POLISH FEEL)
// ===========================================================================

// 1. Mesh Gradient Background
class MeshGradientPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  MeshGradientPainter({required this.primary, required this.secondary, required this.tertiary});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    // Blob 1 (Top Left)
    paint.shader = ui.Gradient.radial(
      Offset(0, 0),
      size.width * 0.8,
      [tertiary.withOpacity(0.8), Colors.white.withOpacity(0)],
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Blob 2 (Bottom Right)
    paint.shader = ui.Gradient.radial(
      Offset(size.width, size.height),
      size.width * 0.6,
      [secondary.withOpacity(0.4), Colors.white.withOpacity(0)],
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Viewfinder Corners
class ViewfinderPainter extends CustomPainter {
  final Color color;
  ViewfinderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double length = 40;
    double padding = 20;

    // Top Left
    canvas.drawPath(
      Path()..moveTo(padding, padding + length)..lineTo(padding, padding)..lineTo(padding + length, padding),
      paint,
    );
    // Top Right
    canvas.drawPath(
      Path()..moveTo(size.width - padding - length, padding)..lineTo(size.width - padding, padding)..lineTo(size.width - padding, padding + length),
      paint,
    );
    // Bottom Left
    canvas.drawPath(
      Path()..moveTo(padding, size.height - padding - length)..lineTo(padding, size.height - padding)..lineTo(padding + length, size.height - padding),
      paint,
    );
    // Bottom Right
    canvas.drawPath(
      Path()..moveTo(size.width - padding - length, size.height - padding)..lineTo(size.width - padding, size.height - padding)..lineTo(size.width - padding, size.height - padding - length),
      paint,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. Holographic Scanner Line
class ScannerPainter extends CustomPainter {
  final double scanValue; // 0.0 to 1.0
  final Color color;

  ScannerPainter({required this.scanValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    double yPos = size.height * scanValue;

    // Draw Line
    canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), paint);

    // Draw Glow (Gradient fade out)
    final glowPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, yPos),
        Offset(0, yPos - 50), // Trail behind
        [color.withOpacity(0.5), Colors.transparent],
      );

    // Draw the glow rect based on direction (simplified to trail up)
    canvas.drawRect(Rect.fromLTRB(0, yPos - 50, size.width, yPos), glowPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerPainter oldDelegate) => oldDelegate.scanValue != scanValue;
}