import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import '../../../utils/http/http_client.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key});


  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
  List<Map<String, String>> pdfFiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPdfList();
  }

  // Fetch PDFs from backend
  Future<void> fetchPdfList() async {
    try {
      Dio dio = Dio();
      Response response =
      await dio.get("${THttpHelper.baseUrl}/pdfs");

      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          pdfFiles = (response.data as List)
              .map((item) => {
            "title": item["title"]?.toString() ?? "Untitled",
            "fileKey": item["fileKey"]?.toString() ?? "",
          })
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching PDFs: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch signed URL from backend
  Future<String?> fetchSignedUrl(String fileKey) async {
    try {
      String url = "${THttpHelper.baseUrl}/pdfs/signed-url/$fileKey";
      Dio dio = Dio();
      Response response = await dio.get(url);

      if (response.statusCode == 200 && response.data["fileUrl"] != null) {
        return response.data["fileUrl"];
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching signed URL: $e");
      return null;
    }
  }

  // Download the PDF file
  Future<String?> downloadFile(String url, String filename) async {
    try {
      Directory directory = await getTemporaryDirectory();
      String filePath = "${directory.path}/$filename";

      if (await File(filePath).exists()) {
        return filePath; // Return cached file
      }

      Dio dio = Dio();
      Response response = await dio.get(url, options: Options(responseType: ResponseType.bytes));

      File file = File(filePath);
      await file.writeAsBytes(response.data, flush: true);

      return filePath;
    } catch (e) {
      if (kDebugMode) print("Download error: $e");
      return null;
    }
  }

  // Fetch signed URL, download and open PDF
  void openPDFViewer(String fileKey) async {
    String? signedUrl = await fetchSignedUrl(fileKey);
    if (signedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to retrieve signed URL")),
      );
      return;
    }

    String filename = fileKey.split('/').last;
    String? filePath = await downloadFile(signedUrl, filename);

    if (filePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(pdfPath: filePath),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load PDF")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pdfFiles.isEmpty
          ? const Center(child: Text("No PDFs available"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          var file = pdfFiles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
              title: Text(file['title']!),
              trailing: const Icon(Icons.download),
              onTap: () async {
                openPDFViewer(file['fileKey']!);
              },
            ),
          );
        },
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;

  const PDFViewerScreen({super.key, required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Viewer")),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageSnap: true,
        defaultPage: 0,
        pageFling: true,
        onError: (error) {
          if (kDebugMode) print("Error loading PDF: $error");
        },
        onPageError: (page, error) {
          if (kDebugMode) print("Error on page $page: $error");
        },
      ),
    );
  }
}
