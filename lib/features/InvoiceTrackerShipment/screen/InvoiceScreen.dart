// screens/invoice_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../utils/http/http_client.dart';
import '../controller/InvoiceController.dart';
import 'WebviewPage.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with SingleTickerProviderStateMixin {
  final Dio _dio = Dio();
  final _downloadProgressController = StreamController<double>.broadcast();
  late final AnimationController _animController;

  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _animController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();

    // Fetch invoices automatically when page opens
    Future.delayed(Duration.zero, () {
      if (Get.isRegistered<InvoiceController>()) {
        final controller = Get.find<InvoiceController>();
        controller.fetchInvoices();
      } else {
        final controller = Get.put(
          InvoiceController(baseUrl: '', bearerToken: ''),
        );
        controller.fetchInvoices();
      }
    });
  }

  // ---------- UNIVERSAL STORAGE PERMISSION ----------
  Future<bool> _ensureStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    // Quick checks
    if (await Permission.manageExternalStorage.isGranted) return true;
    if (await Permission.storage.isGranted) return true;
    if (await Permission.photos.isGranted ||
        await Permission.videos.isGranted ||
        await Permission.audio.isGranted) return true;

    // Request storage (fallback)
    var status = await Permission.storage.request();

    if (!status.isGranted) {
      bool granted = false;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'To download and open PDF invoices, please allow storage access.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                if (await Permission.manageExternalStorage.request().isGranted ||
                    await Permission.storage.request().isGranted ||
                    await Permission.photos.request().isGranted ||
                    await Permission.videos.request().isGranted ||
                    await Permission.audio.request().isGranted) {
                  granted = true;
                }
              },
              child: const Text('Allow Access'),
            ),
          ],
        ),
      );
      return granted;
    }

    return true;
  }

  // ---------- DOWNLOAD AND OPEN PDF ----------
  Future<void> _downloadAndOpen(String invoiceId, String suggestedFileName) async {
    try {
      if (!await _ensureStoragePermission(context)) {
        Get.snackbar(
          'Permission Required',
          'Storage access is required to download PDF files.',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }

      AuthManager authManager = AuthManager();
      final barrierToken = await authManager.getAuthToken();

      // Fetch signed URL from backend (with bearer)
      final signedUrlEndpoint =
          '${THttpHelper.baseUrl}/invoice-tracking/$invoiceId/signed-url';
      final response = await _dio.get(
        signedUrlEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $barrierToken',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 || response.data == null || response.data['success'] != true) {
        Get.snackbar('Error', 'Failed to generate download link');
        return;
      }

      final fileUrl = response.data['url']?.toString();
      if (fileUrl == null || fileUrl.isEmpty) {
        Get.snackbar('Error', 'No download URL returned from server');
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final filename = suggestedFileName.isNotEmpty ? suggestedFileName : 'invoice.pdf';
      final savePath = '${dir.path}/$filename';

      // Download progress dialog with live updates
      double progress = 0.0;
      StateSetter? setDialogState;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return StatefulBuilder(
            builder: (ctx, setState) {
              setDialogState = setState;
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Downloading...'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      color: TColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      await _dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            progress = received / total;
            try {
              setDialogState?.call(() {});
            } catch (_) {}
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 1),
        ),
      );

      if (Navigator.canPop(context)) Navigator.pop(context);
      Get.snackbar('Download Complete', 'Saved to $savePath', snackPosition: SnackPosition.BOTTOM);
      await OpenFilex.open(savePath);
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      Get.snackbar('Download Failed', e.toString(),
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _downloadProgressController.close();
    _searchController.dispose();
    super.dispose();
  }

  // ---------- SEARCH LOGIC ----------
  List<dynamic> _filterInvoices(List<dynamic> invoices) {
    final query = _searchController.text.trim().toLowerCase();
    return invoices.where((inv) {
      final party = (inv.partyName ?? inv.stockist?.firmName ?? '').toString().toLowerCase();
      final invoice = (inv.invoiceNumber ?? '').toString().toLowerCase();
      final date = (inv.invoiceDate ?? '').toString().toLowerCase();

      final matchesSearch = query.isEmpty ? true : (party.contains(query) || invoice.contains(query));
      final matchesDate = _selectedDate == null
          ? true
          : date.contains(_selectedDate!.toIso8601String().split('T').first);

      return matchesSearch && matchesDate;
    }).toList();
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InvoiceController(baseUrl: '', bearerToken: ''));
    final isTablet = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: Obx(() {
                if (controller.loading.value && controller.invoices.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.error.isNotEmpty) return _buildErrorView(controller);
                if (controller.invoices.isEmpty) return _buildEmptyView(controller);

                final filteredList = _filterInvoices(controller.invoices);

                return RefreshIndicator(
                  onRefresh: controller.fetchInvoices,
                  child: isTablet
                      ? _buildTabletTable(context, controller, filteredList)
                      : _buildMobileCards(context, controller, filteredList),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColors.primary,
        onPressed: () {
          final c = Get.find<InvoiceController>();
          c.fetchInvoices();
        },
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  // ---------- SEARCH BAR UI ----------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Party name or Invoice #',
                prefixIcon: const Icon(Icons.search, color: TColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.date_range, color: TColors.primary),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.redAccent),
              onPressed: () => setState(() => _selectedDate = null),
            ),
        ],
      ),
    );
  }

  // ---------- TABLET VIEW ----------
  Widget _buildTabletTable(
      BuildContext context, InvoiceController controller, List<dynamic> invoices) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(TColors.primary.withOpacity(0.2)),
        headingTextStyle: const TextStyle(
          color: TColors.primary,
          fontWeight: FontWeight.bold,
        ),
        columns: const [
          DataColumn(label: Text('Pharma')),
          DataColumn(label: Text('Invoice #')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('AWB')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Download PDF')),
          DataColumn(label: Text('Track Shipment')),
        ],
        rows: invoices.map((inv) {
          final pharma = inv.partyName ?? inv.stockist?.firmName ?? '-';
          final invoiceNo = (inv.invoiceNumber ?? '-').toString();
          final invoiceDate = (inv.invoiceDate ?? '-').toString();
          final status = (inv.status ?? '-').toString().toUpperCase();
          final trackingUrl = inv.trackingLink;
          final awb = (inv.awbNumber ?? '-').toString();
          final filename = inv.invoiceImagePublicId ?? 'invoice_${inv.id}.pdf';

          return DataRow(cells: [
            DataCell(Text(pharma)),
            DataCell(Text(invoiceNo)),
            DataCell(Text(invoiceDate)),
            DataCell(Text(awb)),
            DataCell(
              Chip(
                label: Text(status),
                backgroundColor: TColors.primary.withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () => _downloadAndOpen(inv.id ?? '', filename),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download'),
            )),
            DataCell(ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: TColors.primary,
                elevation: 0,
                side: BorderSide(color: TColors.primary),
              ),
              onPressed: () {
                final url = (trackingUrl == null || trackingUrl.isEmpty)
                    ? 'https://www.gluckscare.com'
                    : trackingUrl;
                Get.to(() => WebViewPage(url: url, title: 'Tracking'));
              },
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text('Track'),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // ---------- MOBILE VIEW ----------
  Widget _buildMobileCards(
      BuildContext context, InvoiceController controller, List<dynamic> invoices) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final inv = invoices[index];
        final pharma = inv.partyName ?? inv.stockist?.firmName ?? '-';
        final invoiceNo = (inv.invoiceNumber ?? '-').toString();
        final invoiceDate = (inv.invoiceDate ?? '-').toString();
        final status = (inv.status ?? '-').toString().toUpperCase();
        final trackingUrl = inv.trackingLink;
        final awb = (inv.awbNumber ?? '-').toString();
        final filename = inv.invoiceImagePublicId ?? 'invoice_${inv.id}.pdf';

        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _animController,
            curve: Interval(index * 0.1, 1, curve: Curves.easeOut),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animController,
              curve: Interval(index * 0.1, 1, curve: Curves.easeOut),
            )),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 14),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, TColors.primary.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pharma,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Text('Invoice #: ',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                      Text(invoiceNo,
                          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w400)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Text('AWB: ',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                      Text(awb, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w400)),
                    ]),
                    const SizedBox(height: 8),

                    // Date then Status (stacked)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text('Date: ',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                          Text(invoiceDate,
                              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w400)),
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Text('Status: ',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                          Chip(
                            label: Text(status),
                            backgroundColor: TColors.primary.withOpacity(0.1),
                            labelStyle: const TextStyle(color: TColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ]),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),

                    Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _downloadAndOpen(inv.id ?? '', filename),
                          icon: const Icon(Icons.download, size: 20),
                          label: const Text('Download PDF'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: TColors.primary,
                            elevation: 0,
                            side: BorderSide(color: TColors.primary, width: 1),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            final url = (trackingUrl == null || trackingUrl.isEmpty)
                                ? 'https://www.gluckscare.com'
                                : trackingUrl;
                            _showTruckAnimation(url);
                          },
                          icon: const Icon(Icons.local_shipping_outlined, size: 20),
                          label: const Text('Track Shipment'),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------- TRUCK ANIMATION ----------
  void _showTruckAnimation(String trackingUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return SizedBox(
                height: 120,
                width: 300,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 4,
                        color: TColors.primary.withOpacity(0.2),
                      ),
                    ),
                    Positioned(
                      left: 20 + value * 220,
                      child: const Icon(Icons.local_shipping_rounded, color: TColors.primary, size: 40),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          value < 1 ? 'Shipment Loading...' : 'Opening Tracker',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: TColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            onEnd: () {
              Navigator.pop(context);
              Get.to(() => WebViewPage(url: trackingUrl, title: 'Tracking'));
            },
          ),
        );
      },
    );
  }

  // ---------- EMPTY & ERROR ----------
  Widget _buildEmptyView(InvoiceController controller) => RefreshIndicator(
    onRefresh: controller.fetchInvoices,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 100),
        Center(child: Text('No invoices found')),
      ],
    ),
  );

  Widget _buildErrorView(InvoiceController controller) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
        const SizedBox(height: 10),
        Text(controller.error.value,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: controller.fetchInvoices,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}
