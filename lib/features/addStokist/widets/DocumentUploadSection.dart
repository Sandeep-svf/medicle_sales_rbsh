// lib/screens/pharma_distributor_form/widgets/document_upload_section.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';

class DocumentUploadSection extends StatelessWidget {
  final Map<String, File?> documentImages;
  final Map<String, double> uploadProgress;
  final Map<String, String?> base64Images;
  final Future<void> Function(String key, {bool forceCamera}) pickImageForKey;
  final Future<void> Function(String key, File file) showImageActions;
  final Future<void> Function() confirmClearAllDocuments;

  const DocumentUploadSection({
    required this.documentImages,
    required this.uploadProgress,
    required this.base64Images,
    required this.pickImageForKey,
    required this.showImageActions,
    required this.confirmClearAllDocuments,
    super.key,
  });

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TColors.primary),
    ),
  );

  @override
  Widget build(BuildContext context) {
    Widget buildTile(String title, bool isRequired) {
      final file = documentImages[title];
      final progress = uploadProgress[title] ?? 0.0;

      // Special icon for Stockist Image to indicate Camera capture
      final bool isGeoImage = title == 'Stockist Image';

      return GestureDetector(
        onTap: () {
          if (file == null) {
            pickImageForKey(title);
          } else {
            showImageActions(title, file);
          }
        },
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: file != null
                          ? Colors.green
                          : (isRequired ? Colors.redAccent : Colors.grey),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: file != null
                        ? Image.file(file, fit: BoxFit.cover)
                        : Icon(
                      // Change icon based on type
                        isGeoImage ? Icons.add_a_photo : Icons.cloud_upload_outlined,
                        color: isGeoImage ? TColors.primary : Colors.grey,
                        size: 44
                    ),
                  ),
                ),
                if (isRequired && file == null)
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(Icons.error, color: Colors.redAccent, size: 20),
                  ),
                if (file != null)
                  Positioned(
                    left: 6,
                    right: 6,
                    bottom: 6,
                    child: LinearProgressIndicator(value: progress),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 110,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isRequired ? Colors.black : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        _sectionTitle("Upload Documents"),
        const SizedBox(height: 12),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            // --- ADDED THIS LINE ---
            buildTile('Stockist Image', true),

            buildTile('GST', true),
            buildTile('Drug License', true),
            buildTile('PAN Card', true),
            buildTile('Security Cheque', true),
            buildTile('Business Profile', false),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                bool ok = true;
                for (var e in documentImages.entries) {
                  // Validate all except Business Profile
                  if (e.key != 'Business Profile' && e.value == null) {
                    ok = false;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${e.key} required')));
                    break;
                  }
                }
                if (ok) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All required documents selected')));
              },
              icon: const Icon(Icons.check),
              label: const Text('Validate Uploads '),
              style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: confirmClearAllDocuments,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Clear All  '),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey,),
            ),
          ],
        ),
      ],
    );
  }
}