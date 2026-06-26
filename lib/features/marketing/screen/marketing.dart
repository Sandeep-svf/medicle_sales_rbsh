import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart'; // For zoomable images
import 'package:shared_preferences/shared_preferences.dart'; // <-- added
import '../../../utils/http/http_client.dart';

class MarketingScreenOld extends StatefulWidget {
  const MarketingScreenOld({super.key});

  @override
  State<MarketingScreenOld> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreenOld> {
  List<Map<String, String>> pdfFiles = [];
  bool isLoading = true;

  bool _isGridView = false; // default to list view

  static const String prefViewKey = "view_mode"; // shared pref key

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
    fetchPdfList();
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isGrid = prefs.getBool(prefViewKey);
    if (isGrid != null) {
      setState(() {
        _isGridView = isGrid;
      });
    }
  }

  Future<void> _saveViewPreference(bool isGrid) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(prefViewKey, isGrid);
  }

  Future<void> fetchPdfList() async {
    try {
      Dio dio = Dio();
      Response response = await dio.get("${THttpHelper.baseUrl}/pdfs");

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
      if (kDebugMode) print("Error fetching files: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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

  Future<String?> downloadFile(String url, String filename) async {
    try {
      Directory directory = await getTemporaryDirectory();
      String filePath = "${directory.path}/$filename";

      if (await File(filePath).exists()) {
        return filePath; // Return cached file
      }

      Dio dio = Dio();
      Response response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));

      File file = File(filePath);
      await file.writeAsBytes(response.data, flush: true);

      return filePath;
    } catch (e) {
      if (kDebugMode) print("Download error: $e");
      return null;
    }
  }

  bool isPdfFile(String fileKey) {
    return fileKey.toLowerCase().endsWith('.pdf');
  }

  void openFileViewer(String fileKey) async {
    if (isPdfFile(fileKey)) {
      // For PDFs: fetch signed URL, download & open
      String? signedUrl = await fetchSignedUrl(fileKey);
      if (signedUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to retrieve signed URL")),
        );
        return;
      }

      String filename = fileKey.split('/').last;
      String? localPath = await downloadFile(signedUrl, filename);

      if (localPath != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PDFViewerScreen(pdfPath: localPath)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load PDF")),
        );
      }
    } else {
      // For non-PDF files: open direct URL as image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerScreen(imageUrl: fileKey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine crossAxisCount based on device width (tablet friendly)
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? "Switch to List View" : "Switch to Grid View",
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
                _saveViewPreference(_isGridView);
              });
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pdfFiles.isEmpty
          ? const Center(child: Text("No files available"))
          : _isGridView
          ? GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          var file = pdfFiles[index];
          bool isPdf = isPdfFile(file['fileKey']!);
          return GestureDetector(
            onTap: () => openFileViewer(file['fileKey']!),
            child: Card(
              elevation: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.image,
                    size: 60,
                    color: isPdf ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      file['title']!,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          var file = pdfFiles[index];
          bool isPdf = isPdfFile(file['fileKey']!);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 4,
            child: ListTile(
              leading: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.image,
                size: 40,
                color: isPdf ? Colors.red : Colors.blue,
              ),
              title: Text(file['title']!),
              trailing: const Icon(Icons.download),
              onTap: () => openFileViewer(file['fileKey']!),
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

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Viewer")),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}