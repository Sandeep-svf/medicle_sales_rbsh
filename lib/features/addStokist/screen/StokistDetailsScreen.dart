import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/features/addStokist/model/Stokist.dart';

import '../../../utils/constants/colors.dart';

class StokistDetailScreen extends StatelessWidget {
  final Stockist stokist;


  const StokistDetailScreen({Key? key, required this.stokist}) : super(key: key);

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: TColors.primary,
      ),
    ),
  );

  Widget _infoRow(String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value?.isNotEmpty == true ? value! : "-",
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    ),
  );

  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double latitude =  28.6139;
    final double longitude =  77.2090;

    return Scaffold(
      appBar: AppBar(
        title: Text(stokist.firmName ?? 'Stockist Details'),
        backgroundColor: TColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard("Basic Info", [
              _infoRow("Firm Name", stokist.firmName),
              _infoRow("Registered Name", stokist.registeredBusinessName),
              _infoRow("Nature of Business", stokist.natureOfBusiness),
              _infoRow("GST Number", stokist.gstNumber),
              _infoRow("PAN Number", stokist.panNumber),
              _infoRow("Drug License", stokist.drugLicenseNumber),
              _infoRow("Years in Business", stokist.yearsInBusiness?.toString()),
            ]),
            _sectionCard("Contact Info", [
              _infoRow("Contact Person", stokist.contactPerson),
              _infoRow("Designation", stokist.designation),
              _infoRow("Mobile", stokist.mobileNumber),
              _infoRow("Email", stokist.emailAddress),
              _infoRow("Website", stokist.website),
              _infoRow("Address", stokist.registeredOfficeAddress),
            ]),
            _sectionCard("Business Scope", [
              _infoRow("Areas of Operation",
                  stokist.areasOfOperation?.join(", ") ?? "-"),
              _infoRow("Distributorships",
                  stokist.currentPharmaDistributorships?.join(", ") ?? "-"),
            ]),
            _sectionCard("Facilities", [
              _infoRow("Warehouse Facility",
                  stokist.warehouseFacility == true ? "Yes" : "No"),
              _infoRow("Cold Storage",
                  stokist.coldStorageAvailable == true ? "Yes" : "No"),
              _infoRow("Storage Size",
                  stokist.storageFacilitySize?.toString() ?? "-"),
              _infoRow("Sales Reps",
                  stokist.numberOfSalesRepresentatives?.toString() ?? "-"),
            ]),
            /*_sectionCard("Bank Details", [
              _infoRow("Bank Name", stokist.bankDetails?.bankName),
              _infoRow("Branch", stokist.bankDetails?.branch),
              _infoRow("Account No.", stokist.bankDetails?.accountNumber),
              _infoRow("IFSC", stokist.bankDetails?.ifscCode),
            ]),*/
            if (stokist.annualTurnover != null &&
                stokist.annualTurnover!.isNotEmpty)
              _sectionCard("Annual Turnover", [
                ...stokist.annualTurnover!.map((t) => _infoRow(
                    "Year ${t.year}",
                    "₹ ${t.amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",")}"))
              ]),

            // 📍 MAP
            _sectionTitle("Location"),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(latitude, longitude),
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("stokist_location"),
                      position: LatLng(latitude, longitude),
                      infoWindow: InfoWindow(
                          title: stokist.firmName ?? "Stockist Location"),
                    )
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
