import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/InvoiceController.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class SendEmailSheet extends StatefulWidget {
  final dynamic invoice;

  const SendEmailSheet({
    super.key,
    required this.invoice,
  });

  @override
  State<SendEmailSheet> createState() => _SendEmailSheetState();
}

class _SendEmailSheetState extends State<SendEmailSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _subjectController;
  final TextEditingController _messageController = TextEditingController();

  List<File> attachments = [];

  bool sending = false;

  String get email => widget.invoice.stockist?.emailAddress ?? '';

  @override
  void initState() {
    super.initState();

    _subjectController = TextEditingController(
      text: "Invoice ${widget.invoice.invoiceNumber ?? ''}",
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> pickFiles() async {
    Get.snackbar(
      "Coming Soon",
      TTexts.uiTextCustomAttachmentsWillBeAvailableInAFuture,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /*Future<void> pickFiles() async {
    try {

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
        ],
      );

      if (result == null) return;

      setState(() {
        attachments.addAll(
          result.files
              .where((e) => e.path != null)
              .map((e) => File(e.path!)),
        );
      });

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    }
  }*/

  void previewFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      Get.dialog(
        Dialog(
          child: InteractiveViewer(
            child: Image.file(file),
          ),
        ),
      );
    } else {
      Get.snackbar(
        "PDF",
        file.path.split('/').last,
      );
    }
  }

  Future<void> sendEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        sending = true;
      });

      final controller = Get.find<InvoiceController>();

      await controller.sendCustomEmail(
        invoiceId: widget.invoice.id,
        subject: _subjectController.text.trim(),
        body: _messageController.text.trim(),
        attachments: attachments,
      );

      if (!mounted) return;

      Get.back();

      Get.snackbar(
        "Success",
        TTexts.uiTextEmailSentSuccessfully,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .85,
      decoration: const BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: TSizes.v12),
            Container(
              width: TSizes.v60,
              height: TSizes.v5,
              decoration: BoxDecoration(
                color: TColors.materialGrey300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: TSizes.v20),
            const Text(
              TTexts.uiTextSendEmail,
              style: TextStyle(
                fontSize: TSizes.v22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TSizes.v20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: email,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: TTexts.uiTextTo,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: TSizes.v16),
                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(
                          labelText: TTexts.uiTextSubject,
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Subject required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: TSizes.v16),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: TTexts.uiTextMessage,
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Message required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: TSizes.v20),
                      Row(
                        children: [
                          const Text(
                            TTexts.uiTextAttachments,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),

                          /*ElevatedButton.icon(
                            onPressed: pickFiles,
                            icon: const Icon(Icons.attach_file),
                            label: const Text("Add"),
                          ),*/

                          ElevatedButton.icon(
                            onPressed: () {
                              Get.snackbar(
                                "Coming Soon",
                                TTexts
                                    .uiTextOnlyInvoicePDFIsAttachedAutomaticallyByThe,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            icon: const Icon(Icons.attach_file),
                            label: const Text(TTexts.uiTextAdd),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.v12),
                      const SizedBox(height: TSizes.v12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: TColors.materialGreen50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TColors.materialGreen200,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: TColors.materialGreen,
                            ),
                            SizedBox(width: TSizes.v12),
                            Expanded(
                              child: Text(
                                TTexts
                                    .uiTextInvoicePDFWillBeAttachedAutomaticallyByThe,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: TSizes.v12),
                      ...attachments.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;

                        final fileName = file.path.split('/').last;
                        final extension =
                            fileName.split('.').last.toLowerCase();

                        final isImage = [
                          'jpg',
                          'jpeg',
                          'png',
                        ].contains(extension);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: TColors.materialGrey300,
                            ),
                          ),
                          child: ListTile(
                            leading: isImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      file,
                                      width: TSizes.v50,
                                      height: TSizes.v50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: TSizes.v50,
                                    height: TSizes.v50,
                                    decoration: BoxDecoration(
                                      color: TColors.materialRed50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.picture_as_pdf,
                                      color: TColors.materialRed,
                                    ),
                                  ),
                            title: Text(
                              fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            /* subtitle: Text(
                              extension.toUpperCase(),
                            ),*/

                            subtitle: const Text(
                              TTexts.uiTextAutomaticallyAttachedInvoicePDF,
                            ),

                            /*  trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                IconButton(
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    previewFile(file);
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: TColors.materialRed,
                                  ),
                                  onPressed: () {
                                    removeFile(index);
                                  },
                                ),
                              ],
                            ),*/

                            trailing: IconButton(
                              icon: const Icon(
                                Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                previewFile(file);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: TSizes.v30),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: TSizes.v55,
                child: ElevatedButton(
                  onPressed: sending ? null : sendEmail,
                  child: sending
                      ? const CircularProgressIndicator()
                      : const Text(
                          TTexts.uiTextSendEmail,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
