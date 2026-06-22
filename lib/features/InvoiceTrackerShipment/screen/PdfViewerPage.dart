import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String fileName;

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    required this.fileName,
  });

  @override
  State<PdfViewerPage> createState() =>
      _PdfViewerPageState();
}

class _PdfViewerPageState
    extends State<PdfViewerPage> {

  bool downloading = false;

  Future<void> downloadPdf() async {

    try {

      setState(() {
        downloading = true;
      });

      final dir =
      await getApplicationDocumentsDirectory();

      final path =
          '${dir.path}/${widget.fileName}';

      await Dio().download(
        widget.pdfUrl,
        path,
      );

      await OpenFilex.open(path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "PDF Downloaded",
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          downloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.fileName),

        actions: [

          IconButton(
            onPressed:
            downloading
                ? null
                : downloadPdf,
            icon: downloading
                ? const SizedBox(
              width: 20,
              height: 20,
              child:
              CircularProgressIndicator(),
            )
                : const Icon(
              Icons.download,
            ),
          ),
        ],
      ),

      body: SfPdfViewer.network(
        widget.pdfUrl,
      ),
    );
  }
}