import 'dart:io';


import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/InvoiceController.dart';

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
  final TextEditingController _messageController =
  TextEditingController();

  List<File> attachments = [];

  bool sending = false;

  String get email =>
      widget.invoice.stockist?.emailAddress ?? '';

  @override
  void initState() {
    super.initState();

    _subjectController = TextEditingController(
      text:
      "Invoice ${widget.invoice.invoiceNumber ?? ''}",
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
      "Custom attachments will be available in a future release.",
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
        "Email sent successfully",
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 12),

            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Send Email",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

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
                          labelText: "To",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(
                          labelText: "Subject",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null ||
                              v.trim().isEmpty) {
                            return "Subject required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _messageController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: "Message",
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) {
                          if (v == null ||
                              v.trim().isEmpty) {
                            return "Message required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [

                          const Text(
                            "Attachments",
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
                                "Only invoice PDF is attached automatically by the server.",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            icon: const Icon(Icons.attach_file),
                            label: const Text("Add"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade200,
                        ),
                      ),
                      child: const Row(
                        children: [

                          Icon(
                            Icons.picture_as_pdf,
                            color: Colors.green,
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              "Invoice PDF will be attached automatically by the server.",
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),



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
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: ListTile(

                            leading: isImage
                                ? ClipRRect(
                              borderRadius:
                              BorderRadius.circular(8),
                              child: Image.file(
                                file,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
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
                              "Automatically attached invoice PDF",
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
                                    color: Colors.red,
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

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                  sending ? null : sendEmail,
                  child: sending
                      ? const CircularProgressIndicator()
                      : const Text(
                    "Send Email",
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