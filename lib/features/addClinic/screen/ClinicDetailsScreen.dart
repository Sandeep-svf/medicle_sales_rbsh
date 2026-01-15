import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../model/clinic.dart';

const Color kPrimaryColor = Color(0xFFC71D52);
const Color kBackgroundColor = Color(0xFFF4F6F9);
const Color kTextDark = Color(0xFF2D3436);
const Color kTextLight = Color(0xFF636E72);

class ClinicDetailScreen extends StatelessWidget {
  final Clinic clinic;

  const ClinicDetailScreen({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true, // For a premium feel
      appBar: AppBar(
        title: const Text("Chemist Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent, // Glass effect over header
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isTablet = constraints.maxWidth > 600;
            bool isLandscape = constraints.maxWidth > 900;

            if (isLandscape) return _buildLandscapeLayout(context);
            if (isTablet) return _buildTabletPortraitLayout(context);
            return _buildMobileLayout(context);
          },
        ),
      ),
    );
  }

  // ==================== LAYOUTS ====================

  // 1. Mobile Layout (Vertical Scroll)
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroHeader(),
          const SizedBox(height: 16),
          _buildInfoSection(),
          const SizedBox(height: 16),
          _buildFinancialSection(),
          const SizedBox(height: 16),
          _buildLocationSection(context),
          const SizedBox(height: 16),
          _buildMetaInfo(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 2. Tablet Portrait (Grid-like)
  Widget _buildTabletPortraitLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildHeroHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Info & Finance
              Expanded(
                child: Column(
                  children: [
                    _buildInfoSection(),
                    const SizedBox(height: 24),
                    _buildFinancialSection(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Column 2: Location & Meta
              Expanded(
                child: Column(
                  children: [
                    _buildLocationSection(context),
                    const SizedBox(height: 24),
                    _buildMetaInfo(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Tablet Landscape (Split View)
  Widget _buildLandscapeLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Pane: Core Details
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroHeader(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildMetaInfo(),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right Pane: Visuals & Finance
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLocationSection(context),
                  const SizedBox(height: 24),
                  _buildFinancialSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WIDGET COMPONENTS ====================

  // --- 1. HERO HEADER (Business Card Style) ---
  Widget _buildHeroHeader() {
    String initials = clinic.firmName.isNotEmpty ? clinic.firmName[0].toUpperCase() : "C";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Text(
                initials,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryColor),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinic.firmName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      clinic.contactPersonName,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "${clinic.yearsInBusiness} Years in Business",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. INFO SECTION (Grouped Contact & Business) ---
  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildStyledCard(
          title: "Contact Information",
          icon: Icons.contact_phone_outlined,
          children: [
            _buildDataRow(Icons.phone_android, "Mobile", clinic.mobileNo, isLink: true),
            _buildDataRow(Icons.email_outlined, "Email", clinic.emailId, isLink: true),
            _buildDataRow(Icons.pin_drop_outlined, "Address", clinic.address),
          ],
        ),
        const SizedBox(height: 16),
        _buildStyledCard(
          title: "Business Details",
          icon: Icons.business_center_outlined,
          children: [
            if (clinic.designation.isNotEmpty) _buildDataRow(Icons.badge_outlined, "Designation", clinic.designation),
            _buildDataRow(Icons.description_outlined, "Drug License", clinic.drugLicenseNumber),
            _buildDataRow(Icons.receipt_long_outlined, "GST Number", clinic.gstNo),
            _buildDataRow(Icons.domain_outlined, "Head Office", clinic.headOffice.name),
          ],
        ),
      ],
    );
  }

  // --- 3. FINANCIAL SECTION (Visualized) ---
  Widget _buildFinancialSection() {
    return _buildStyledCard(
      title: "Financial Overview",
      icon: Icons.monetization_on_outlined,
      children: [
        if (clinic.annualTurnover.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text("No turnover data recorded.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          )
        else
          ...clinic.annualTurnover.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Year ${t.year}", style: const TextStyle(fontWeight: FontWeight.w600, color: kTextDark)),
                      Text(
                        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(t.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Visual Bar
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 1.0, // In real app, calculate relative to max amount
                      child: Container(
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  // --- 4. LOCATION HUB (Map + Image) ---
  Widget _buildLocationSection(BuildContext context) {
    double? lat = double.tryParse(clinic.latitude);
    double? lng = double.tryParse(clinic.longitude);
    bool isMapValid = lat != null && lng != null && lat != 0 && lng != 0;
    bool hasImage = clinic.geoImageUrl != null && clinic.geoImageUrl!.isNotEmpty;

    return Column(
      children: [
        // Map Card
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15)],
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: isMapValid
                ? Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 15),
                  markers: {
                    Marker(
                      markerId: const MarkerId("loc"),
                      position: LatLng(lat, lng),
                      infoWindow: InfoWindow(title: clinic.firmName),
                    )
                  },
                  zoomControlsEnabled: false,
                  liteModeEnabled: true, // Better performance in scroll views
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(Icons.map, size: 14, color: kPrimaryColor),
                        SizedBox(width: 4),
                        Text("Verified Location", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                      ],
                    ),
                  ),
                )
              ],
            )
                : Container(
              color: Colors.grey[100],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_outlined, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text("No Coordinates Available", style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Geo Image Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 18, color: kTextLight),
                    const SizedBox(width: 8),
                    const Text("Chemist Image", style: TextStyle(fontWeight: FontWeight.bold, color: kTextDark)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Container(
                height: 200,
                width: double.infinity,
                child: hasImage
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      child: Image.network(
                        clinic.geoImageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                        errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                    // Overlay Gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                          ),
                        ),
                      ),
                    ),
                    // View Button
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: ElevatedButton.icon(
                        onPressed: () => _showFullImage(context, clinic.geoImageUrl!),
                        icon: const Icon(Icons.fullscreen, size: 18),
                        label: const Text("Full View"),
                        style: ElevatedButton.styleFrom(
                          // Improved visibility
                          backgroundColor: Colors.black.withOpacity(0.6),
                          foregroundColor: Colors.white,
                          elevation: 0,

                          // --- ADDED PADDING (Margin Start & End logic) ---
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    )
                  ],
                )
                    : Center(
                  child: Text("No site image captured", style: TextStyle(color: Colors.grey[400])),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 5. META INFO ---
  Widget _buildMetaInfo() {
    return Center(
      child: Column(
        children: [
          Text("Record Created: ${DateFormat('dd MMM yyyy, hh:mm a').format(clinic.createdAt)}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text("Last Sync: ${DateFormat('dd MMM yyyy, hh:mm a').format(clinic.updatedAt)}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildStyledCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 18, color: kPrimaryColor),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: kTextLight, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : "N/A",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isLink && value.isNotEmpty ? Colors.blue[700] : kTextDark,
                    decoration: isLink && value.isNotEmpty ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}