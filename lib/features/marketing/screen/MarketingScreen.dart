/*
// lib/ui/screens/marketing_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';

import '../controller/MarketingController.dart';
import '../model/PdfItem.dart';

// Adjust paths to your project structure:

class MarketingScreen extends StatelessWidget {
  const MarketingScreen({super.key});

  bool _isPdfFile(String fileKey) => fileKey.toLowerCase().endsWith('.pdf');

  @override
  Widget build(BuildContext context) {
    // Put the controller once at screen build
    final c = Get.put(MarketingController());

    return Obx(() {
      final isGrid = c.isGridView.value;
      final isOffline = c.isOfflineMode.value; // default OFF => Online first
      final isLoading = c.isLoading.value;

      // Choose source list by mode
      final List<PdfItem> items = isOffline ? c.offlineItems : c.onlineItems;

      final width = MediaQuery.of(context).size.width;
      final crossAxisCount = width > 600 ? 3 : 2;

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Use offline mode if internet is slow or unavailable for viewing PDFs.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: TColors.primary,
          actions: [
            IconButton(
              tooltip: isGrid ? "Switch to List View" : "Switch to Grid View",
              icon: Icon(
                isGrid ? Icons.view_list : Icons.grid_view,
                color: Colors.white,
              ),
              onPressed: c.toggleGrid,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70), // Adjust height as needed
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Toggle with text tightly together
                      Row(
                        mainAxisSize: MainAxisSize.min, // Make Row only as wide as needed
                        children: [
                          const Text(
                            "Offline mode",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 4), // small space between text and toggle
                          Switch(
                            value: isOffline,
                            onChanged: (v) => c.setOffline(v),
                            activeColor: Colors.white,
                            activeTrackColor: Colors.white24,
                          ),
                        ],
                      ),

                      const SizedBox(width: 12), // space between toggle and button
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : () => c.refreshPdfs(context),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text("Refresh PDFs"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Optional status row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isOffline
                              ? "Offline items: ${c.offlineItems.length}"
                              : "Online items: ${c.onlineItems.length}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),


        body: Column(
          children: [


            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                  ? Center(
                child: Text(
                  isOffline
                      ? "No files available"
                      : "No files available${_onlineHelpText()}",
                  textAlign: TextAlign.center,
                ),
              )
                  : isGrid
                  ? GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _AssetCard(
                    title: item.title,
                    isPdf: _isPdfFile(item.fileKey),
                    onTap: () => _onOpen(context, c, item),
                  );
                },
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(
                        _isPdfFile(item.fileKey)
                            ? Icons.picture_as_pdf
                            : Icons.image,
                        size: 40,
                        color: _isPdfFile(item.fileKey)
                            ? Colors.red
                            : Colors.blue,
                      ),
                      title: Text(item.title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _onOpen(context, c, item),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // Adds a hint in Online mode empty-list case
  String _onlineHelpText() => "\n(If you're online, tap Refresh. If not, switch to Offline mode.)";

  Future<void> _onOpen(
      BuildContext context,
      MarketingController c,
      PdfItem item,
      ) async {
    // OFFLINE: open strictly from localPath
    if (c.isOfflineMode.value) {
      final localPath = item.localPath; // already from DB list
      if (localPath != null && await File(localPath).exists()) {
        _openPdf(context, localPath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Not downloaded yet for offline use")),
        );
      }
      return;
    }

    // ONLINE: if no internet → show message; else prefer cached, else fetch signed URL + download
    try {
      final online = await c.isOnline();
      if (!online) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Internet not available. Switch to Offline mode.")),
        );
        return;
      }

      // 1) Try cached first for fast open
      final cached = await c.getCachedLocalPath(item.fileKey);
      if (cached != null) {
        _openPdf(context, cached);
        return;
      }

      // 2) Fresh signed URL → download → open
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final signedUrl = await c.getSignedUrl(item.fileKey); // PdfService.fetchSignedUrl
      if (signedUrl == null) {
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to retrieve signed URL")),
        );
        return;
      }

      final localPath = await c.downloadToCache(signedUrl, item.fileKey); // PdfService.downloadPdf
      if (context.mounted) {
        Navigator.of(context).pop();
        _openPdf(context, localPath);
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      if (kDebugMode) debugPrint("Open online error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load PDF: $e")),
      );
    }
  }

  void _openPdf(BuildContext context, String localPath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PDFViewerScreen(pdfPath: localPath)),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final String title;
  final bool isPdf;
  final VoidCallback onTap;

  const _AssetCard({
    required this.title,
    required this.isPdf,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                title,
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
        onError: (error) {},
        onPageError: (page, error) {},
      ),
    );
  }
}
*/
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

import '../controller/MarketingController.dart';
import '../model/PdfItem.dart';

class MarketingScreen extends StatelessWidget {
  const MarketingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MarketingController());

    return Obx(() {
      final isGrid = c.isGridView.value;
      final isOffline = c.isOfflineMode.value;
      final isLoading = c.isLoading.value;
      final List<PdfItem> items = isOffline ? c.offlineItems : c.onlineItems;

      final width = MediaQuery.of(context).size.width;
      final crossAxisCount = width > 600 ? 3 : 2;

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Use offline mode if internet is slow or unavailable for viewing PDFs.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: TColors.primary,
          actions: [
            IconButton(
              tooltip: isGrid ? "Switch to List View" : "Switch to Grid View",
              icon: Icon(
                isGrid ? Icons.view_list : Icons.grid_view,
                color: Colors.white,
              ),
              onPressed: c.toggleGrid,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Offline mode", style: TextStyle(color: Colors.white)),
                          const SizedBox(width: 4),
                          Switch(
                            value: isOffline,
                            onChanged: (v) => c.setOffline(v),
                            activeColor: Colors.white,
                            activeTrackColor: Colors.white24,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : () => c.load(),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text("Refresh PDFs"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isOffline
                              ? "Offline items: ${c.offlineItems.length}"
                              : "Online items: ${c.onlineItems.length}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                  ? const Center(child: Text("No files available"))
                  : isGrid
                  ? GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _AssetCard(
                    title: item.title,
                    onTap: () => _onOpen(context, c, item),
                  );
                },
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                      title: Text(item.title),
                      subtitle: item.description == null || item.description!.isEmpty
                          ? null
                          : Text(
                        item.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _onOpen(context, c, item),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _onOpen(BuildContext context, MarketingController c, PdfItem item) async {
    if (c.isOfflineMode.value) {
      final localPath = item.localPath;
      if (localPath != null && await File(localPath).exists()) {
        _openPdf(context, localPath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Not downloaded yet for offline use")),
        );
      }
      return;
    }

    try {
      final online = await c.isOnline();
      if (!online) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Internet not available. Switch to Offline mode.")),
        );
        return;
      }

      // Use cached if present
      final cached = await c.getCachedLocalPathByFileKey(item.fileKey);
      if (cached != null) {
        _openPdf(context, cached);
        return;
      }

      // Fetch signed URL by server id, download, open, and persist
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final signedUrl = await c.getSignedUrlById(item.id);
      if (signedUrl == null) {
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to retrieve signed URL")),
        );
        return;
      }

      final safeName = (item.title.isNotEmpty ? item.title : item.fileKey)
          .replaceAll(RegExp(r'[\\/:"*?<>|]+'), '_');

      final localPath = await c.downloadToCache(
        signedUrl: signedUrl,
        filename: "$safeName.pdf",
      );

      await c.saveDownloaded(item, signedUrl, localPath);

      if (context.mounted) {
        Navigator.of(context).pop();
        _openPdf(context, localPath);
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      if (kDebugMode) debugPrint("MarketingScreen _onOpen error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load PDF: $e")),
      );
    }
  }

  void _openPdf(BuildContext context, String localPath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PDFViewerScreen(pdfPath: localPath)),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _AssetCard({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 60, color: Colors.red),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
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
        onError: (error) {},
        onPageError: (page, error) {},
      ),
    );
  }
}
