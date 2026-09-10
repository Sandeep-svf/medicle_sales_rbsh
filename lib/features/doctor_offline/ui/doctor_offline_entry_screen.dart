import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

import '../doctor_offline_module.dart';

class DoctorOfflineEntryScreen extends StatefulWidget {
  const DoctorOfflineEntryScreen({
    super.key,
    required this.accountId,
    this.authorizedScopeId,
    this.deltaHeadOfficeId,
    this.environment,
  });

  final String accountId;
  final String? authorizedScopeId;
  final String? deltaHeadOfficeId;
  final String? environment;

  @override
  State<DoctorOfflineEntryScreen> createState() =>
      _DoctorOfflineEntryScreenState();
}

class _DoctorOfflineEntryScreenState extends State<DoctorOfflineEntryScreen> {
  DoctorOfflineModule? _module;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final module = await DoctorOfflineModule.initialize(
        accountId: widget.accountId,
        authorizedScopeId: widget.authorizedScopeId,
        deltaHeadOfficeId: widget.deltaHeadOfficeId,
        environment: widget.environment,
      );
      if (!mounted) {
        await module.dispose();
        return;
      }
      setState(() {
        _module = module;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    final module = _module;
    if (module != null) unawaited(module.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final module = _module;
    if (module != null) return module.screen();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Offline Doctors',
          style: TextStyle(color: TColors.white),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        iconTheme: const IconThemeData(color: TColors.white),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(TSizes.lg),
              child: _loading
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: TColors.primary),
                        SizedBox(height: TSizes.md),
                        Text('Opening secure offline doctor storage…'),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.storage_rounded,
                          color: TColors.error,
                          size: 52,
                        ),
                        const SizedBox(height: TSizes.md),
                        Text(
                          'Secure doctor storage is unavailable',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: TSizes.sm),
                        Text(
                          _error?.toString() ?? 'Please try again.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: TSizes.md),
                        FilledButton.icon(
                          onPressed: _initialize,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
