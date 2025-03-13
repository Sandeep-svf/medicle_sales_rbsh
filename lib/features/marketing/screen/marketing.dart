import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key});

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
  List<Map<String, String>> files = [
    {
      "name": "Project Proposal",
      "url": "https://morth.nic.in/sites/default/files/dd12-13_0.pdf",
      "type": "pdf"
    },
    {
      "name": "Design Mockup",
      "url":
          "https://media.istockphoto.com/id/1313742092/photo/business-partnership-business-man-investor-handshake-with-effect-global-network-link.jpg?s=1024x1024&w=is&k=20&c=uWAW24rxmFCuzlVDTO8EyZe1I6OBcoiP4g7vY233r8Q=",
      "type": "image"
    },
    {
      "name": "User Guide",
      "url": "https://morth.nic.in/sites/default/files/dd12-13_0.pdf",
      "type": "pdf"
    },
    {
      "name": "Team Photo",
      "url":
          "https://media.istockphoto.com/id/1313742092/photo/business-partnership-business-man-investor-handshake-with-effect-global-network-link.jpg?s=1024x1024&w=is&k=20&c=uWAW24rxmFCuzlVDTO8EyZe1I6OBcoiP4g7vY233r8Q=",
      "type": "image"
    },
  ];

  Future<String?> downloadFile(String url, String filename) async {
    try {
      Directory directory = await getTemporaryDirectory();
      String filePath = "${directory.path}/$filename";

      // Check if the file already exists
      if (await File(filePath).exists()) {
        return filePath;
      }

      Dio dio = Dio();
      Response response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));

      File file = File(filePath);
      await file.writeAsBytes(response.data, flush: true);

      return filePath;
    } catch (e) {
      print("Download error: $e");
      return null;
    }
  }

  void openPDFViewer(String url, String filename) async {
    String? filePath = await downloadFile(url, filename);
    if (filePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(pdfPath: filePath),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load PDF")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: files.length,
        itemBuilder: (context, index) {
          var file = files[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 4,
            child: ListTile(
              leading: file['type'] == 'pdf'
                  ? Icon(Icons.picture_as_pdf, size: 40, color: Colors.red)
                  : CachedNetworkImage(
                      imageUrl: file['url']!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Icon(Icons.broken_image, size: 60),
                    ),
              title: Text(file['name']!),
              subtitle: Text(file['type']!.toUpperCase()),
              trailing: Icon(Icons.download),
              onTap: () async {
                String filename = file['url']!.split('/').last;
                String? filePath = await downloadFile(file['url']!, filename);

                if (filePath != null) {
                  if (file['type'] == 'pdf') {
                    openPDFViewer(file['url']!, filename);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageViewerScreen(imagePath: filePath),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to download file")),
                  );
                }
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

  PDFViewerScreen({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Viewer")),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageSnap: true,
        defaultPage: 0,
        pageFling: true,
        onError: (error) {
          print("PDF Load Error: $error");
        },
        onPageError: (page, error) {
          print("Error on page $page: $error");
        },
      ),
    );
  }
}

class ImageViewerScreen extends StatelessWidget {
  final String imagePath;

  ImageViewerScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imagePath,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) =>
              Icon(Icons.broken_image, size: 100, color: Colors.white),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
