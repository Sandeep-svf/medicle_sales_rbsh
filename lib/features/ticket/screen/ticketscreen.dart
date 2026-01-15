import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/constants/colors.dart';
import '../controller/TicketController.dart';


class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with TickerProviderStateMixin {

  // Inject the TicketController
  final TicketController _controller = Get.put(TicketController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Animation Controllers
  late AnimationController _entranceController;
  late AnimationController _submitController;
  late Animation<double> _submitScaleAnimation;

  // Logic Variables
  File? _selectedImage;
  String? _base64Image;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  // State for View Toggle (New Ticket vs History)
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();

    // Setup Animations
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _submitScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _submitController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _entranceController.forward();
    });

    // Ensure tickets are fetched when screen loads
    _controller.fetchTickets();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _entranceController.dispose();
    _submitController.dispose();
    super.dispose();
  }

  // --- Image Handling Logic ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          _selectedImage = imageFile;
          _base64Image = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _base64Image = null;
    });
  }

  // --- Submission Logic ---
  void _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    await _submitController.forward();
    setState(() => _isSubmitting = true);

    // Call the GetX Controller
    final success = await _controller.createTicket(
      _titleController.text,
      _descController.text,
      _base64Image ?? "",
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);
    await _submitController.reverse();

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to create ticket. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => Container(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "Ticket Raised!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "We've received your request.\nYou can track it in the History tab.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _titleController.clear();
                    _descController.clear();
                    _removeImage();

                    // Switch to history view
                    setState(() {
                      _showHistory = true;
                    });
                    // Refresh history just in case
                    _controller.fetchTickets();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("View Ticket"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- Header Section ---
            _buildAnimatedHeader(size),

            // --- Main Content Section ---
            Transform.translate(
              offset: const Offset(0, -40), // Pull up over header
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Custom Toggle
                          _buildToggleSwitch(),
                          const SizedBox(height: 25),

                          // Content Switching
                          AnimatedCrossFade(
                            firstChild: _buildFormContent(),
                            secondChild: _buildHistoryContent(),
                            crossFadeState: _showHistory
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                            alignment: Alignment.topCenter,
                            firstCurve: Curves.easeInOut,
                            secondCurve: Curves.easeInOut,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Content Builders ---

  Widget _buildToggleSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildToggleItem("New Ticket", !_showHistory, () {
            setState(() => _showHistory = false);
          }),
          _buildToggleItem("History", _showHistory, () {
            if (!_showHistory) _controller.fetchTickets();
            setState(() => _showHistory = true);
          }),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? TColors.primary : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle("What's happening?"),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _titleController,
            label: "Subject",
            icon: Icons.title_rounded,
            validator: (v) => v!.isEmpty ? "Please enter a subject" : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descController,
            label: "Description",
            icon: Icons.description_outlined,
            maxLines: 5,
            validator: (v) => v!.isEmpty ? "Please describe the issue" : null,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Attachments (Optional)"),
          const SizedBox(height: 10),
          _buildImagePickerArea(),
          const SizedBox(height: 30),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHistoryContent() {
    // Obx listens to changes in the GetX controller
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(
            child: CircularProgressIndicator(color: TColors.primary),
          ),
        );
      }

      if (_controller.tickets.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.history, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 10),
              const Text("No tickets found", style: TextStyle(color: Colors.grey)),
              TextButton(
                  onPressed: _controller.fetchTickets,
                  child: const Text("Refresh", style: TextStyle(color: TColors.primary))
              )
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: _controller.tickets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          final ticket = _controller.tickets[index];

          // Determine status using your model field
          final statusStr = ticket.status?.toUpperCase() ?? "UNKNOWN";
          final isResolved = statusStr == "RESOLVED" || statusStr == "CLOSED";

          // Parse Date (Assuming string from API)
          String dateStr = "Unknown Date";
          if (ticket.createdAt != null) {
            try {
              final date = DateTime.parse(ticket.createdAt!);
              dateStr = "${date.day}/${date.month}/${date.year}";
            } catch (_) {
              dateStr = ticket.createdAt!;
            }
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isResolved
                        ? Colors.green.withOpacity(0.1)
                        : TColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isResolved ? Icons.check : Icons.hourglass_bottom,
                    color: isResolved ? Colors.green : TColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.title ?? "No Title",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "ID: ${ticket.id?.substring(0, math.min(ticket.id?.length ?? 0, 8)) ?? '...'} • $dateStr",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isResolved
                        ? Colors.green.withOpacity(0.1)
                        : TColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusStr,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isResolved ? Colors.green : TColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // --- Widget Builders ---

  Widget _buildAnimatedHeader(Size size) {
    return SizedBox(
      height: size.height * 0.35,
      child: Stack(
        children: [
          // Background Gradient with Curve
          Positioned.fill(
            child: ClipPath(
              clipper: HeaderCurveClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TColors.primary,
                      TColors.primary_shade100,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Floating Shapes
          Positioned(
            top: -50,
            right: -50,
            child: _buildCircleDecoration(150, Colors.white.withOpacity(0.1)),
          ),
          Positioned(
            top: 50,
            left: -30,
            child: _buildCircleDecoration(80, Colors.white.withOpacity(0.1)),
          ),

          // Content
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.headset_mic, color: Colors.white, size: 14),
                              SizedBox(width: 5),
                              Text("24/7 Support", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Spacer(),
                    SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                          .animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOut)),
                      child: FadeTransition(
                        opacity: _entranceController,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "We're here\nto help you.",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Raise a ticket or track previous issues.",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            SizedBox(height: 40), // Space for the overlap
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 60 : 0),
          child: Icon(icon, color: const Color(0xFF94A3B8)),
        ),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      validator: validator,
    );
  }

  Widget _buildImagePickerArea() {
    if (_selectedImage != null) {
      return Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildPickButton(
            icon: Icons.photo_library_rounded,
            label: "Gallery",
            color: TColors.primary,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildPickButton(
            icon: Icons.camera_alt_rounded,
            label: "Camera",
            color: TColors.primary,
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
      ],
    );
  }

  Widget _buildPickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScaleTransition(
      scale: _submitScaleAnimation,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              TColors.primary,
              TColors.primary_shade100,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: TColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitTicket,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: _isSubmitting
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Submit Ticket",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleDecoration(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);

    // First control point and end point
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy
    );

    // Second control point and end point
    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondEndPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}