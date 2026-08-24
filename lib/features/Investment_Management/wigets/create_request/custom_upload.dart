import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../controller/add_investment_controller.dart';
import '../../enum.dart';
import 'section_card.dart';

class CustomUpload extends GetView<AddInvestmentController> {
  const CustomUpload({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isNeft = controller.selectedMode.value == InvestmentMode.neft;
      final bytes = controller.paymentProofBytes.value;
      final existingUrl = controller.existingPaymentProofUrl.value.trim();
      final isPicking = controller.isPickingPaymentProof.value;

      return SectionCard(
        title: isNeft ? "Cancelled Cheque Image" : "UPI / QR Image",
        icon: isNeft ? Icons.account_balance_outlined : Icons.qr_code_2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNeft
                  ? "Optional. Capture or select a cancelled cheque image up to 5 MB."
                  : "Optional. Capture or select a UPI or QR payment image up to 5 MB.",
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            if (bytes != null)
              _SelectedProofState(
                bytes: bytes,
                fileName: controller.paymentProofName.value,
                fileSize: controller.paymentProofSizeLabel,
                isPicking: isPicking,
              )
            else if (existingUrl.isNotEmpty)
              _ExistingProofState(
                imageUrl: existingUrl,
                isPicking: isPicking,
              )
            else
              _EmptyProofState(isPicking: isPicking),
            if (isPicking) ...[
              const SizedBox(height: 14),
              const LinearProgressIndicator(minHeight: 3),
            ],
          ],
        ),
      );
    });
  }
}

class _ExistingProofState extends StatelessWidget {
  const _ExistingProofState({
    required this.imageUrl,
    required this.isPicking,
  });

  final String imageUrl;
  final bool isPicking;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(imageUrl);
    final canPreview = uri != null && uri.hasScheme;

    return Column(
      children: [
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: canPreview
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const _ExistingProofPlaceholder(),
                  )
                : const _ExistingProofPlaceholder(),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "A payment image is already attached. Select another image to replace it.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 14),
        _ProofSourceButtons(isPicking: isPicking),
      ],
    );
  }
}

class _ExistingProofPlaceholder extends StatelessWidget {
  const _ExistingProofPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: TColors.primary,
      ),
    );
  }
}

class _EmptyProofState extends GetView<AddInvestmentController> {
  const _EmptyProofState({required this.isPicking});

  final bool isPicking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 44,
                color: TColors.primary,
              ),
              SizedBox(height: 10),
              Text(
                "No image selected",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ProofSourceButtons(isPicking: isPicking),
      ],
    );
  }
}

class _SelectedProofState extends GetView<AddInvestmentController> {
  const _SelectedProofState({
    required this.bytes,
    required this.fileName,
    required this.fileSize,
    required this.isPicking,
  });

  final Uint8List bytes;
  final String fileName;
  final String fileSize;
  final bool isPicking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined, size: 44),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fileSize,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: "Remove image",
              onPressed: isPicking ? null : controller.removePaymentProof,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ProofSourceButtons(isPicking: isPicking),
      ],
    );
  }
}

class _ProofSourceButtons extends GetView<AddInvestmentController> {
  const _ProofSourceButtons({required this.isPicking});

  final bool isPicking;

  @override
  Widget build(BuildContext context) {
    final galleryButton = OutlinedButton.icon(
      onPressed: isPicking ? null : controller.pickPaymentProofFromGallery,
      icon: const Icon(Icons.photo_library_outlined),
      label: const Text("Gallery"),
    );

    final cameraButton = ElevatedButton.icon(
      onPressed: isPicking ? null : controller.pickPaymentProofFromCamera,
      icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
      label: const Text(
        "Camera",
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              SizedBox(width: double.infinity, child: galleryButton),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: cameraButton),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: galleryButton),
            const SizedBox(width: 12),
            Expanded(child: cameraButton),
          ],
        );
      },
    );
  }
}
