// lib/screens/pharma_distributor_form/pharma_distributor_form_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';

// --- Imports specific to your project ---
import '../../../utils/GlobalPermissionHelper/PermissionHelper.dart';
import '../../../utils/camera/MediaPermissionHelper.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../../../utils/loder/CircularLoaderController.dart';
import '../../addDoctor/screens/map.dart';
import '../model/headoffice.dart';
import '../widets/AnnualGTurnOverSection.dart';
import '../widets/BankDetailsSection.dart';
import '../widets/BasicDetailsSection.dart';
import '../widets/BusinessProfileSection.dart';
import '../widets/ContactDetailsSection.dart';
import '../widets/DocumentUploadSection.dart';
import '../widets/FacilitiesSection.dart';

// --- Import for Geo Overlay ---
import '../../../utils/camera/CameraLocationResult.dart';
import '../../../utils/camera/image_overlay_utils.dart';

class PharmaDistributorFormScreen extends StatefulWidget {
  const PharmaDistributorFormScreen({super.key});

  @override
  State<PharmaDistributorFormScreen> createState() =>
      _PharmaDistributorFormScreenState();
}

class _PharmaDistributorFormScreenState
    extends State<PharmaDistributorFormScreen> {
  // ---------------------------
  // Form state & controllers
  // ---------------------------
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Stepper
  int _activeStep = 0;
  final int _totalSteps = 7; // 0..6

  // Regex Patterns
  final RegExp _mobileRegex = RegExp(r'^[0-9]{10}$');
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
  // GST: 2 digits + 5 chars + 4 digits + 1 char + 1 digit + Z + 1 char
  final RegExp _gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
  // IFSC: 4 Letters + '0' + 6 Alphanumeric characters
  final RegExp _ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
  // Account Number: Typically 9 to 18 digits in India
  final RegExp _accountNumberRegex = RegExp(r'^[0-9]{9,18}$');

  // Basic fields
  final TextEditingController firmName = TextEditingController();
  final TextEditingController businessName = TextEditingController();
  String? selectedHeadOfficeId;
  List<HeadOffice1> _offices = [];

  // Business/Contact fields
  final List<String> businessTypes = [
    'Proprietorship',
    'Partnership',
    'Private Ltd.',
    'Public Ltd.'
  ];
  String? selectedBusinessType;
  final TextEditingController gstNumber = TextEditingController();
  final TextEditingController drugLicenseNumber = TextEditingController();
  final TextEditingController panNumber = TextEditingController();
  final TextEditingController officeAddress = TextEditingController();
  final TextEditingController contactPerson = TextEditingController();
  final TextEditingController designation = TextEditingController();
  final TextEditingController mobileNumber = TextEditingController();
  final TextEditingController emailAddress = TextEditingController();
  final TextEditingController website = TextEditingController();
  final TextEditingController yearsInBusiness = TextEditingController();
  final TextEditingController areasOfOperation = TextEditingController();
  final TextEditingController distributorships = TextEditingController();

  // Facilities
  bool warehouseFacility = false;
  bool coldStorageAvailable = false;
  final TextEditingController storageSize = TextEditingController();
  final TextEditingController salesReps = TextEditingController();

  // Bank
  final TextEditingController bankName = TextEditingController();
  final TextEditingController branch = TextEditingController();
  final TextEditingController accountNumber = TextEditingController();
  final TextEditingController ifscCode = TextEditingController();

  // Location
  String? selectedLocation;
  String? selectedlatitude;
  String? selectedlongitude;

  // Turnovers
  List<Map<String, dynamic>> _annualTurnovers = List.generate(
    3,
        (index) => {
      "year": DateTime.now().year - index,
      "amount": 0,
    },
  );

  // ---------------------------
  // Media documents state
  // ---------------------------
  // Added 'Stockist Image' here
  final Map<String, File?> _documentImages = {
    'Stockist Image': null, // New Required Field
    'GST': null,
    'Drug License': null,
    'PAN Card': null,
    'Security Cheque': null,
    'Business Profile': null,
  };

  final Map<String, double> _uploadProgress = {
    'Stockist Image': 0.0,
    'GST': 0.0,
    'Drug License': 0.0,
    'PAN Card': 0.0,
    'Security Cheque': 0.0,
    'Business Profile': 0.0,
  };

  final Map<String, String?> _base64Images = {
    'Stockist Image': null,
    'GST': null,
    'Drug License': null,
    'PAN Card': null,
    'Security Cheque': null,
    'Business Profile': null,
  };

  // ---------------------------
  // Utilities & lifecycle
  // ---------------------------
  final ImagePicker _picker = ImagePicker();
  final dio.Dio _dio = dio.Dio();
  static const String _kPrefix = 'pharma_form_';

  @override
  void initState() {
    super.initState();
    fetchHeadOffices();
    _loadFormDraft();
  }

  // ---------------------------
  // Shared Preferences: Save / Load / Clear
  // ---------------------------
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<void> _saveFormDraft() async {
    final prefs = await _prefs;
    // basic fields
    await prefs.setString('${_kPrefix}firmName', firmName.text);
    await prefs.setString('${_kPrefix}businessName', businessName.text);
    await prefs.setString('${_kPrefix}selectedHeadOfficeId', selectedHeadOfficeId ?? '');
    await prefs.setString('${_kPrefix}selectedBusinessType', selectedBusinessType ?? '');
    // business/contact
    await prefs.setString('${_kPrefix}gstNumber', gstNumber.text);
    await prefs.setString('${_kPrefix}drugLicenseNumber', drugLicenseNumber.text);
    await prefs.setString('${_kPrefix}panNumber', panNumber.text);
    await prefs.setString('${_kPrefix}officeAddress', officeAddress.text);
    await prefs.setString('${_kPrefix}contactPerson', contactPerson.text);
    await prefs.setString('${_kPrefix}designation', designation.text);
    await prefs.setString('${_kPrefix}mobileNumber', mobileNumber.text);
    await prefs.setString('${_kPrefix}emailAddress', emailAddress.text);
    await prefs.setString('${_kPrefix}website', website.text);
    await prefs.setString('${_kPrefix}yearsInBusiness', yearsInBusiness.text);
    await prefs.setString('${_kPrefix}areasOfOperation', areasOfOperation.text);
    await prefs.setString('${_kPrefix}distributorships', distributorships.text);
    // facilities
    await prefs.setBool('${_kPrefix}warehouseFacility', warehouseFacility);
    await prefs.setBool('${_kPrefix}coldStorageAvailable', coldStorageAvailable);
    await prefs.setString('${_kPrefix}storageSize', storageSize.text);
    await prefs.setString('${_kPrefix}salesReps', salesReps.text);
    // bank
    await prefs.setString('${_kPrefix}bankName', bankName.text);
    await prefs.setString('${_kPrefix}branch', branch.text);
    await prefs.setString('${_kPrefix}accountNumber', accountNumber.text);
    await prefs.setString('${_kPrefix}ifscCode', ifscCode.text);
    // location
    await prefs.setString('${_kPrefix}selectedLocation', selectedLocation ?? '');
    await prefs.setString('${_kPrefix}selectedlatitude', selectedlatitude ?? '');
    await prefs.setString('${_kPrefix}selectedlongitude', selectedlongitude ?? '');
    // turnovers
    await prefs.setString('${_kPrefix}annualTurnovers', jsonEncode(_annualTurnovers));
    // active step
    await prefs.setInt('${_kPrefix}activeStep', _activeStep);

    // Save doc paths
    for (final key in _documentImages.keys) {
      final file = _documentImages[key];
      if (file != null) {
        await prefs.setString('${_kPrefix}doc_${_safeKey(key)}', file.path);
      } else {
        await prefs.remove('${_kPrefix}doc_${_safeKey(key)}');
      }
    }
    // Save base64 optionally
    for (final key in _base64Images.keys) {
      final b = _base64Images[key];
      if (b != null) {
        await prefs.setString('${_kPrefix}b64_${_safeKey(key)}', b);
      } else {
        await prefs.remove('${_kPrefix}b64_${_safeKey(key)}');
      }
    }
  }

  Future<void> _loadFormDraft() async {
    final prefs = await _prefs;
    setState(() {
      firmName.text = prefs.getString('${_kPrefix}firmName') ?? '';
      businessName.text = prefs.getString('${_kPrefix}businessName') ?? '';
      selectedBusinessType = prefs.getString('${_kPrefix}selectedBusinessType');
      selectedHeadOfficeId = prefs.getString('${_kPrefix}selectedHeadOfficeId');
      gstNumber.text = prefs.getString('${_kPrefix}gstNumber') ?? '';
      drugLicenseNumber.text = prefs.getString('${_kPrefix}drugLicenseNumber') ?? '';
      panNumber.text = prefs.getString('${_kPrefix}panNumber') ?? '';
      officeAddress.text = prefs.getString('${_kPrefix}officeAddress') ?? '';
      contactPerson.text = prefs.getString('${_kPrefix}contactPerson') ?? '';
      designation.text = prefs.getString('${_kPrefix}designation') ?? '';
      mobileNumber.text = prefs.getString('${_kPrefix}mobileNumber') ?? '';
      emailAddress.text = prefs.getString('${_kPrefix}emailAddress') ?? '';
      website.text = prefs.getString('${_kPrefix}website') ?? '';
      yearsInBusiness.text = prefs.getString('${_kPrefix}yearsInBusiness') ?? '';
      areasOfOperation.text = prefs.getString('${_kPrefix}areasOfOperation') ?? '';
      distributorships.text = prefs.getString('${_kPrefix}distributorships') ?? '';
      warehouseFacility = prefs.getBool('${_kPrefix}warehouseFacility') ?? false;
      coldStorageAvailable = prefs.getBool('${_kPrefix}coldStorageAvailable') ?? false;
      storageSize.text = prefs.getString('${_kPrefix}storageSize') ?? '';
      salesReps.text = prefs.getString('${_kPrefix}salesReps') ?? '';
      bankName.text = prefs.getString('${_kPrefix}bankName') ?? '';
      branch.text = prefs.getString('${_kPrefix}branch') ?? '';
      accountNumber.text = prefs.getString('${_kPrefix}accountNumber') ?? '';
      ifscCode.text = prefs.getString('${_kPrefix}ifscCode') ?? '';
      selectedLocation = prefs.getString('${_kPrefix}selectedLocation');
      selectedlatitude = prefs.getString('${_kPrefix}selectedlatitude');
      selectedlongitude = prefs.getString('${_kPrefix}selectedlongitude');
      final turnoversJson = prefs.getString('${_kPrefix}annualTurnovers');
      if (turnoversJson != null && turnoversJson.isNotEmpty) {
        try {
          final parsed = jsonDecode(turnoversJson) as List<dynamic>;
          _annualTurnovers = parsed.map((e) => {"year": e["year"], "amount": e["amount"]}).toList();
        } catch (e) {
          if (kDebugMode) print('turnovers parse error: $e');
        }
      }
      _activeStep = prefs.getInt('${_kPrefix}activeStep') ?? 0;
      if (_activeStep < 0 || _activeStep >= _totalSteps) _activeStep = 0;

      for (final key in _documentImages.keys) {
        final path = prefs.getString('${_kPrefix}doc_${_safeKey(key)}');
        if (path != null && path.isNotEmpty) {
          final f = File(path);
          if (f.existsSync()) {
            _documentImages[key] = f;
          }
        }
        final b64 = prefs.getString('${_kPrefix}b64_${_safeKey(key)}');
        if (b64 != null && b64.isNotEmpty) _base64Images[key] = b64;
      }
    });
  }

  Future<void> _clearFormDraft() async {
    final prefs = await _prefs;
    final keys = prefs.getKeys().where((k) => k.startsWith(_kPrefix)).toList();
    for (final k in keys) await prefs.remove(k);
  }

  // ---------------------------
  // Networking: fetch head offices
  // ---------------------------
  Future<void> fetchHeadOffices() async {
    try {
      final token = await AuthManager().getAuthToken();
      final res = await _dio.get('${THttpHelper.baseUrl}/users/my-head-offices',
          options: dio.Options(headers: {"Authorization": "Bearer $token", "Accept": "application/json"}));
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data['data'] ?? [];
        setState(() {
          _offices = data.map((j) => HeadOffice1.fromJson(j)).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) print('fetchHeadOffices error: $e');
    }
  }

  String _safeKey(String key) => key.replaceAll(' ', '_').toLowerCase();

  Future<File?> _compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_cmp.jpg';

      final dynamic result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1080,
        keepExif: false,
      );

      if (result == null) return file;
      if (result is File) return result;
      try {
        return File(result.path);
      } catch (_) {
        return file;
      }
    } catch (e) {
      if (kDebugMode) print('compress error: $e');
      return file;
    }
  }

  Future<String> _fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      if (kDebugMode) print('base64 encode error: $e');
      return '';
    }
  }

  Future<void> _pickImageForKey(String key, {bool forceCamera = false}) async {

    final granted = await MediaPermissionHelper.requestCameraAndGallery();

    if (!granted) {
      _showSnack("Camera permission required");

      if (await MediaPermissionHelper.isPermanentlyDenied()) {
        _showSettingsDialog();
      }
      return;
    }

    // ---- STOCKIST IMAGE (CAMERA ONLY) ----
    if (key == 'Stockist Image') {
      try {
        CircularLoaderController.showLoader(context);

        final result = await CameraLocationService.captureImageWithLocation();

        CircularLoaderController.hideLoader();

        if (result == null) return;

        final File geoImage = await ImageOverlayUtil.addOverlay(
          original: result.image,
          lat: result.latitude,
          lng: result.longitude,
        );

        setState(() {
          _documentImages[key] = geoImage;
          _uploadProgress[key] = 1.0;
          selectedlatitude ??= result.latitude.toString();
          selectedlongitude ??= result.longitude.toString();
        });

        await _saveFormDraft();
      } catch (e) {
        CircularLoaderController.hideLoader();
        _showSnack("Camera error");
      }
      return;
    }

    // ---- NORMAL CAMERA / GALLERY ----
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    if (picked == null) return;

    setState(() {
      _documentImages[key] = File(picked.path);
      _uploadProgress[key] = 1.0;
    });

    await _saveFormDraft();
  }



  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("You have previously denied permissions. Please enable Camera and Photos in App Settings to continue."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings(); // Function from permission_handler
              },
              child: const Text("Settings")
          ),
        ],
      ),
    );
  }

  void _proceedToPickImage(String key, bool forceCamera) {
    // Your existing logic to show ModalBottomSheet and pick image...
  }

// Helper function to show the dialog if they denied the popup
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("To upload documents, please allow Camera and Storage permissions in the next screen or in App Settings."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                PermissionHelper.openAppSettingsIfDenied();
              },
              child: const Text("Settings")
          ),
        ],
      ),
    );
  }

  Future<void> _removeImageForKey(String key) async {
    setState(() {
      _documentImages[key] = null;
      _uploadProgress[key] = 0.0;
      _base64Images[key] = null;
    });
    await _saveFormDraft();
  }

  Future<void> _showImageActions(String key, File file) async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('View Image'),
                onTap: () {
                  Navigator.pop(ctx);
                  _viewImage(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Replace (Camera)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageForKey(key, forceCamera: true);
                },
              ),
              if(key != 'Stockist Image') // Hide gallery for Stockist Image (Force Camera)
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Replace (Gallery)'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImageForKey(key, forceCamera: false);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeImageForKey(key);
                },
              ),
              ListTile(
                title: const Center(child: Text('Cancel')),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _viewImage(File file) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            PhotoView(
              imageProvider: FileImage(file),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SUBMIT FORM ---
  Future<void> _submitDistributorForm() async {
    if (!_validateStep(_activeStep, finalValidation: true)) return;
    if (!_validateTurnovers()) return;

    CircularLoaderController.showLoader(context);

    try {
      final token = await AuthManager().getAuthToken();
      debugPrint('PharmaDistributorFormScreen: token fetched');

      final formData = dio.FormData.fromMap({
        "firmName": firmName.text.trim(),
        "registeredBusinessName": businessName.text.trim(),
        "natureOfBusiness": selectedBusinessType ?? '',
        "gstNumber": gstNumber.text.trim(),
        "drugLicenseNumber": drugLicenseNumber.text.trim(),
        "panNumber": panNumber.text.trim(),
        "registeredOfficeAddress": officeAddress.text.trim(),
        "latitude": selectedlatitude,
        "longitude": selectedlongitude,
        "contactPerson": contactPerson.text.trim(),
        "designation": designation.text.trim(),
        "mobileNumber": mobileNumber.text.trim(),
        "emailAddress": emailAddress.text.trim(),
        "website": website.text.trim(),
        "yearsInBusiness": int.tryParse(yearsInBusiness.text) ?? 0,

        "areasOfOperation[]": areasOfOperation.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),

        "currentPharmaDistributorships[]": distributorships.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),

        "annualTurnover": jsonEncode(_annualTurnovers),

        "warehouseFacility": warehouseFacility,
        "storageFacilitySize": int.tryParse(storageSize.text) ?? 0,
        "coldStorageAvailable": coldStorageAvailable,
        "numberOfSalesRepresentatives": int.tryParse(salesReps.text) ?? 0,

        "bankDetails[bankName]": bankName.text.trim(),
        "bankDetails[branch]": branch.text.trim(),
        "bankDetails[accountNumber]": accountNumber.text.trim(),
        "bankDetails[ifscCode]": ifscCode.text.trim(),

        "headOffice": selectedHeadOfficeId,

        // -------- FILE PARTS --------

        // 1. Stockist Geo Image
        if (_documentImages['Stockist Image'] != null)
          "geo_image": await dio.MultipartFile.fromFile(
            _documentImages['Stockist Image']!.path,
            filename: "stockist_geo.jpg",
            contentType: MediaType('image', 'jpeg'),
          ),

        if (_documentImages['GST'] != null)
          "gstCertificate": await dio.MultipartFile.fromFile(
            _documentImages['GST']!.path,
            filename: "gst.jpg",
          ),

        if (_documentImages['Drug License'] != null)
          "drugLicense": await dio.MultipartFile.fromFile(
            _documentImages['Drug License']!.path,
            filename: "drug_license.jpg",
          ),

        if (_documentImages['PAN Card'] != null)
          "panCard": await dio.MultipartFile.fromFile(
            _documentImages['PAN Card']!.path,
            filename: "pan_card.jpg",
          ),

        if (_documentImages['Security Cheque'] != null)
          "cancelledCheque": await dio.MultipartFile.fromFile(
            _documentImages['Security Cheque']!.path,
            filename: "cheque.jpg",
          ),

        if (_documentImages['Business Profile'] != null)
          "businessProfile": await dio.MultipartFile.fromFile(
            _documentImages['Business Profile']!.path,
            filename: "business_profile.jpg",
          ),
      });

      final res = await _dio.post(
        '${THttpHelper.baseUrl}/stockists',
        data: formData,
        options: dio.Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await _clearFormDraft();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Distributor registered successfully')),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submit failed: ${res.statusCode}')),
          );
        }
      }
    } catch (e, s) {
      debugPrint('PharmaDistributorFormScreen: submit error -> $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      CircularLoaderController.hideLoader();
    }
  }

  bool _validateTurnovers() {
    for (final t in _annualTurnovers) {
      if ((t['amount'] == null) ||
          (t['amount'] is num && (t['amount'] as num) <= 0)) {
        _showSnack('Please provide turnover amount for ${t['year']}');
        return false;
      }
    }
    return true;
  }

  bool _validateStep(int step, {bool finalValidation = false}) {
    String ifscVal = ifscCode.text.trim().toUpperCase();
    String accVal = accountNumber.text.trim();
    if (finalValidation) {
      if (firmName.text.trim().isEmpty) { _showStepError(0, 'Firm Name required'); return false; }
      if (businessName.text.trim().isEmpty) { _showStepError(0, 'Business Name required'); return false; }
      if (selectedHeadOfficeId == null || selectedHeadOfficeId!.isEmpty) { _showStepError(0, 'Select Head Office'); return false; }
      if (contactPerson.text.trim().isEmpty) { _showStepError(1, 'Contact Person required'); return false; }
      if (mobileNumber.text.trim().isEmpty) { _showStepError(1, 'Mobile Number required'); return false; }
      if (emailAddress.text.trim().isEmpty) { _showStepError(1, 'Email Address required'); return false; }
      if (gstNumber.text.trim().isEmpty) { _showStepError(2, 'GST Number required'); return false; }
      if (drugLicenseNumber.text.trim().isEmpty) { _showStepError(2, 'Drug License required'); return false; }
      if (panNumber.text.trim().isEmpty) { _showStepError(2, 'PAN Number required'); return false; }
      if (officeAddress.text.trim().isEmpty) { _showStepError(2, 'Office Address required'); return false; }
      if (!_validateTurnovers()) return false;
      if (bankName.text.trim().isEmpty) { _showStepError(5, 'Bank name required'); return false; }
      if (branch.text.trim().isEmpty) { _showStepError(5, 'Branch required'); return false; }
      if (accountNumber.text.trim().isEmpty) { _showStepError(5, 'Account Number required'); return false; }
      if (ifscCode.text.trim().isEmpty) { _showStepError(5, 'IFSC required'); return false; }
      if (selectedlatitude == null || selectedlongitude == null || selectedLocation == null) { _showSnack('Select location before submit'); return false; }

      // Check Document Images
      for (final entry in _documentImages.entries) {
        // Business Profile is optional
        if (entry.key == 'Business Profile') continue;

        // Stockist Image is Required (New Check)
        if (entry.key == 'Stockist Image' && entry.value == null) {
          _showStepError(6, 'Stockist Image (Geo-Tagged) is required');
          return false;
        }

        if (entry.value == null) {
          _showStepError(6, '${entry.key} image required');
          return false;
        }
      }
      return true;
    }

    switch (step) {
      case 0:
        if (firmName.text.trim().isEmpty || businessName.text.trim().isEmpty) { _showSnack('Firm & Business name required'); return false; }
        if (selectedHeadOfficeId == null || selectedHeadOfficeId!.isEmpty) { _showSnack('Please select Head Office'); return false; }
        if (!_gstRegex.hasMatch(gstNumber.text.trim().toUpperCase())) {
          _showSnack('Invalid GST number'); return false;
        }
        if (!_panRegex.hasMatch(panNumber.text.trim().toUpperCase())) {
          _showSnack('Invalid PAN number'); return false;
        }
        if (drugLicenseNumber.text.trim().isEmpty) {
          _showSnack('Drug License required'); return false;
        }
        return true;
      case 1:
        if (contactPerson.text.trim().isEmpty || mobileNumber.text.trim().isEmpty || emailAddress.text.trim().isEmpty) { _showSnack('Contact person, mobile & email are required'); return false; }
        if (!_mobileRegex.hasMatch(mobileNumber.text.trim())) {
          _showSnack('Enter valid 10-digit mobile number'); return false;
        }
        if (!_emailRegex.hasMatch(emailAddress.text.trim())) {
          _showSnack('Enter valid email address'); return false;
        }
        return true;
      case 2:
        if (yearsInBusiness.text.trim().isEmpty || officeAddress.text.trim().isEmpty) { _showSnack('Years in business and office address required'); return false; }
        if(selectedLocation!.isEmpty){ _showSnack('Please select address on map'); return false; };
        return true;
      case 3:
        return _validateTurnovers();
      case 4:
        return true;
      case 5:
        if (bankName.text.trim().isEmpty) { _showSnack('Bank Name required'); return false; }
        if (branch.text.trim().isEmpty) { _showSnack('Branch Name required'); return false; }
        if (accVal.isEmpty) { _showSnack('Account Number required'); return false; }
        if (!_accountNumberRegex.hasMatch(accVal)) { _showSnack('Invalid Account Number (9-18 digits)'); return false; }
        if (ifscVal.isEmpty) { _showSnack('IFSC Code required'); return false; }
        if (!_ifscRegex.hasMatch(ifscVal)) { _showSnack('Invalid IFSC Code format (e.g. SBIN0123456)'); return false; }
        return true;
      case 6:
      // Ensure Stockist Image is captured before submitting
        if (_documentImages['Stockist Image'] == null) {
          _showSnack('Please capture the Stockist Geo Image');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showStepError(int step, String message) {
    setState(() {
      _activeStep = step;
    });
    _showSnack(message);
  }

  void _showSnack(String message) {
    Get.snackbar('Validation', message, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _confirmClearAllDocuments() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all documents?'),
        content: const Text('This will remove all selected documents from this form (local only). Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        for (final k in _documentImages.keys) {
          _documentImages[k] = null;
          _uploadProgress[k] = 0.0;
          _base64Images[k] = null;
        }
      });
      await _saveFormDraft();
    }
  }

  @override
  void dispose() {
    firmName.dispose();
    businessName.dispose();
    gstNumber.dispose();
    drugLicenseNumber.dispose();
    panNumber.dispose();
    officeAddress.dispose();
    contactPerson.dispose();
    designation.dispose();
    mobileNumber.dispose();
    emailAddress.dispose();
    website.dispose();
    yearsInBusiness.dispose();
    areasOfOperation.dispose();
    distributorships.dispose();
    storageSize.dispose();
    salesReps.dispose();
    bankName.dispose();
    branch.dispose();
    accountNumber.dispose();
    ifscCode.dispose();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Distributor Registration", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        backgroundColor: TColors.primary,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                child: EasyStepper(
                  activeStep: _activeStep,
                  finishedStepTextColor: TColors.primary,
                  activeStepTextColor: TColors.primary,
                  unreachedStepIconColor: Colors.grey,
                  finishedStepBackgroundColor: TColors.primary,
                  activeStepBackgroundColor: TColors.primary,
                  unreachedStepBackgroundColor: Colors.grey.shade300,
                  internalPadding: 8,
                  borderThickness: 2,
                  steps: const [
                    EasyStep(icon: Icon(Icons.details, color: Colors.white), title: 'Applicant'),
                    EasyStep(icon: Icon(Icons.contact_phone, color: Colors.white), title: 'Contact'),
                    EasyStep(icon: Icon(Icons.business, color: Colors.white), title: 'Business'),
                    EasyStep(icon: Icon(Icons.trending_up, color: Colors.white), title: 'Turnover'),
                    EasyStep(icon: Icon(Icons.inventory_2, color: Colors.white), title: 'Facilities'),
                    EasyStep(icon: Icon(Icons.account_balance, color: Colors.white), title: 'Bank'),
                    EasyStep(icon: Icon(Icons.upload, color: Colors.white), title: 'Media'),
                  ],
                  onStepReached: (index) async {
                    if (index < _activeStep) {
                      setState(() => _activeStep = index);
                      await _saveFormDraft();
                      return;
                    }
                    if (_validateStep(_activeStep)) {
                      setState(() => _activeStep = index);
                      await _saveFormDraft();
                    }
                  },
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: IndexedStack(
                    index: _activeStep,
                    children: [
                      BasicDetailsSection(
                        firmName: firmName,
                        businessName: businessName,
                        selectedHeadOfficeId: selectedHeadOfficeId,
                        offices: _offices,
                        drugLicenceNumber: drugLicenseNumber,
                        panNumber: panNumber,
                        onHeadOfficeChanged: (v) async {
                          setState(() => selectedHeadOfficeId = v);
                          await _saveFormDraft();
                        },
                        gstNumber: gstNumber,
                        selectedBusinessType: selectedBusinessType,
                        businessTypes: businessTypes,
                        onBusinessTypeChanged: (v) async {
                          setState(() => selectedBusinessType = v);
                          await _saveFormDraft();
                        },
                      ),
                      ContactDetailsSection(
                        contactPerson: contactPerson,
                        designation: designation,
                        mobileNumber: mobileNumber,
                        emailAddress: emailAddress,
                        website: website,
                      ),
                      BusinessProfileSection(
                        yearsInBusiness: yearsInBusiness,
                        areasOfOperation: areasOfOperation,
                        distributorships: distributorships,
                        officeAddress: officeAddress,
                        onPickLocation: () async {
                          try {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LocationPickerScreen()),
                            );
                            if (result != null) {
                              setState(() {
                                selectedlatitude = result['latitude'].toString();
                                selectedlongitude = result['longitude'].toString();
                                selectedLocation = result['address'].toString();
                              });
                              Get.snackbar(
                                "📍 Location Selected",
                                "$selectedLocation\nLat: $selectedlatitude, Lng: $selectedlongitude",
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 4),
                              );
                              await _saveFormDraft();
                            } else {
                              Get.snackbar(
                                "Location Not Selected",
                                "Please try again or cancel",
                                backgroundColor: Colors.orange,
                              );
                            }
                          } catch (e) {
                            if (kDebugMode) print("Location picker error: $e");
                          }
                        },
                      ),
                      // Turnover Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Annual Turnover",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TColors.primary),
                            ),
                          ),
                          AnnualTurnoverSection(
                            turnovers: _annualTurnovers,
                            onChanged: (updatedList) {
                              setState(() => _annualTurnovers = updatedList);
                              _saveFormDraft();
                            },
                          ),
                        ],
                      ),
                      FacilitiesSection(
                        warehouseFacility: warehouseFacility,
                        coldStorageAvailable: coldStorageAvailable,
                        storageSize: storageSize,
                        salesReps: salesReps,
                        onWarehouseChanged: (val) async {
                          setState(() => warehouseFacility = val);
                          await _saveFormDraft();
                        },
                        onColdStorageChanged: (val) async {
                          setState(() => coldStorageAvailable = val);
                          await _saveFormDraft();
                        },
                      ),
                      BankDetailsSection(
                        bankName: bankName,
                        branch: branch,
                        accountNumber: accountNumber,
                        ifscCode: ifscCode,
                        onSubmitNow: () async {
                          if (!_validateStep(_activeStep, finalValidation: true)) return;
                          await _saveFormDraft();
                          await _submitDistributorForm();
                        },
                      ),
                      DocumentUploadSection(
                        documentImages: _documentImages,
                        uploadProgress: _uploadProgress,
                        base64Images: _base64Images,
                        pickImageForKey: _pickImageForKey,
                        showImageActions: _showImageActions,
                        confirmClearAllDocuments: _confirmClearAllDocuments,
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Row(
                  children: [
                    if (_activeStep > 0)
                      OutlinedButton(
                        onPressed: () async {
                          setState(() => _activeStep--);
                          await _saveFormDraft();
                        },
                        child: const Text('Back'),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
                      onPressed: () async {
                        if (_activeStep == _totalSteps - 1) {
                          if (!_validateStep(_activeStep, finalValidation: true)) return;
                          await _saveFormDraft();
                          await _submitDistributorForm();
                        } else {
                          if (_validateStep(_activeStep)) {
                            setState(() => _activeStep++);
                            await _saveFormDraft();
                          }
                        }
                      },
                      child: Text(_activeStep == _totalSteps - 1 ? 'Submit' : 'Next'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}