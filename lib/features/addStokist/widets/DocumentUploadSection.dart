import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

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
          style: const TextStyle(
              fontSize: TSizes.v18,
              fontWeight: FontWeight.bold,
              color: TColors.primary),
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
                  width: TSizes.v110,
                  height: TSizes.v110,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: file != null
                          ? TColors.materialGreen
                          : (isRequired
                              ? TColors.materialRedAccent
                              : TColors.materialGrey),
                      width: TSizes.v2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: TColors.materialGrey100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: file != null
                        ? Image.file(file, fit: BoxFit.cover)
                        : Icon(
                            // Change icon based on type
                            isGeoImage
                                ? Icons.add_a_photo
                                : Icons.cloud_upload_outlined,
                            color: isGeoImage
                                ? TColors.primary
                                : TColors.materialGrey,
                            size: TSizes.v44),
                  ),
                ),
                if (isRequired && file == null)
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(Icons.error,
                        color: TColors.materialRedAccent, size: TSizes.v20),
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
            const SizedBox(height: TSizes.v6),
            SizedBox(
              width: TSizes.v110,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: TSizes.v13,
                  fontWeight: FontWeight.w600,
                  color:
                      isRequired ? TColors.pureBlack : TColors.materialGrey700,
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
        const SizedBox(height: TSizes.v6),
        _sectionTitle("Upload Documents"),
        const SizedBox(height: TSizes.v12),
        Wrap(
          spacing: TSizes.v18,
          runSpacing: TSizes.v18,
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
        const SizedBox(height: TSizes.v12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                bool ok = true;
                for (var e in documentImages.entries) {
                  // Validate all except Business Profile
                  if (e.key != 'Business Profile' && e.value == null) {
                    ok = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${e.key} required')));
                    break;
                  }
                }
                if (ok)
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text(TTexts.uiTextAllRequiredDocumentsSelected)));
              },
              icon: const Icon(Icons.check),
              label: const Text(TTexts.uiTextValidateUploads),
              style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
            ),
            const SizedBox(width: TSizes.v12),
            ElevatedButton.icon(
              onPressed: confirmClearAllDocuments,
              icon: const Icon(Icons.delete_forever),
              label: const Text(TTexts.uiTextClearAll),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.materialGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
