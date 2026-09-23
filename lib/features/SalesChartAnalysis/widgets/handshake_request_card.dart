import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../Screen/handshake_user_list_screen.dart';
import '../model/SalesChartDashboardModel.dart';
import '../model/handshake_available_user.dart';
import '../services/handshake_service.dart';
import 'handshake_confirmation_dialog.dart';
import 'handshake_user_tile.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class HandshakeRequestCard extends StatefulWidget {
  const HandshakeRequestCard({
    super.key,
    required this.beat,
    this.onSubmitted,
  });

  final TodayBeatAssigned? beat;
  final Future<void> Function()? onSubmitted;

  @override
  State<HandshakeRequestCard> createState() => _HandshakeRequestCardState();
}

class _HandshakeRequestCardState extends State<HandshakeRequestCard> {
  static const int _previewLimit = 3;

  final HandshakeService _service = const HandshakeService();
  final Set<String> _selectedIds = <String>{};

  List<HandshakeAvailableUser> _users = const [];
  bool _loading = true;
  bool _sending = false;
  bool _sent = false;
  String? _errorMessage;
  String _notes = '';

  DateTime get _availabilityDate =>
      HandshakeService.resolveAvailabilityDate(widget.beat?.date);

  String get _dayId => widget.beat?.dayId?.trim() ?? '';

  List<HandshakeAvailableUser> get _selectedUsers {
    return _users
        .where((user) => _selectedIds.contains(user.id))
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void didUpdateWidget(covariant HandshakeRequestCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.beat?.dayId != widget.beat?.dayId ||
        oldWidget.beat?.date != widget.beat?.date) {
      _selectedIds.clear();
      _loadUsers();
    }
  }

  Future<void> _loadUsers({bool showLoader = true}) async {
    if (_dayId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _users = const [];
        _loading = false;
        _errorMessage = 'No current tour-plan day is available.';
      });
      return;
    }

    if (showLoader && mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final users = await _service.fetchAvailableUsers(
        date: _availabilityDate,
      );

      if (!mounted) return;
      setState(() {
        _users = users;
        _selectedIds.retainAll(users.map((user) => user.id));
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = HandshakeService.errorMessage(error);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleUser(HandshakeAvailableUser user) {
    if (_sending || !user.available) return;

    setState(() {
      _sent = false;
      if (!_selectedIds.add(user.id)) {
        _selectedIds.remove(user.id);
      }
    });
  }

  Future<void> _sendSelectedUsers() async {
    final selectedUsers = _selectedUsers;
    if (selectedUsers.isEmpty || _sending) return;

    final confirmation = await showHandshakeConfirmationDialog(
      context: context,
      selectedUsers: selectedUsers,
      date: _availabilityDate,
      dayId: _dayId,
      beatName: widget.beat?.beatName,
      initialNotes: _notes,
    );

    if (confirmation == null || !mounted) return;
    _notes = confirmation.notes;

    setState(() {
      _sending = true;
      _sent = false;
    });

    try {
      final result = await _service.sendRequest(
        dayId: _dayId,
        userIds: selectedUsers.map((user) => user.id),
        notes: _notes,
      );

      if (!mounted) return;
      await _handleSubmissionSuccess(result.message);
    } catch (error) {
      if (!mounted) return;
      _showMessage(HandshakeService.errorMessage(error), isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _openFullList() async {
    if (_dayId.isEmpty || _sending) return;

    final result = await Navigator.of(context).push<HandshakePageResult>(
      MaterialPageRoute(
        builder: (_) => HandshakeUserListScreen(
          initialUsers: _users,
          initialSelectedIds: _selectedIds,
          dayId: _dayId,
          date: _availabilityDate,
          beatName: widget.beat?.beatName,
        ),
      ),
    );

    if (!mounted || result == null || !result.submitted) return;
    await _handleSubmissionSuccess(result.message);
  }

  Future<void> _handleSubmissionSuccess(String message) async {
    if (!mounted) return;

    setState(() {
      _sent = true;
      _selectedIds.clear();
      _notes = '';
    });

    _showMessage(message, isError: false);

    try {
      await widget.onSubmitted?.call();
    } catch (error) {
      debugPrint('[HandshakeCard] Dashboard refresh failed: $error');
    }

    await _loadUsers(showLoader: false);

    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _sent = false);
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? TColors.error : TColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withValues(alpha: .07),
            blurRadius: TSizes.v20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: TSizes.v16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: TSizes.v46,
          height: TSizes.v46,
          decoration: BoxDecoration(
            color: TColors.primary_shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.handshake_rounded,
            color: TColors.primary,
            size: TSizes.v25,
          ),
        ),
        const SizedBox(width: TSizes.v14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                TTexts.uiTextREQUESTAHANDSHAKE,
                style: TextStyle(
                  color: TColors.primary,
                  fontSize: TSizes.v11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: TSizes.v3),
              Text(
                '${HandshakeService.formatApiDate(_availabilityDate)} • ${widget.beat?.beatName ?? 'Current Beat'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: TSizes.v11,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: TTexts.uiTextRefreshAvailableUsers,
          onPressed: _loading || _sending ? null : _loadUsers,
          icon: const Icon(Icons.refresh_rounded, color: TColors.primary),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const SizedBox(
        key: ValueKey('loading'),
        height: TSizes.v110,
        child: Center(
          child: CircularProgressIndicator(color: TColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        key: const ValueKey('error'),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColors.errorBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: TColors.error),
            const SizedBox(width: TSizes.v10),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: TColors.error,
                  fontSize: TSizes.v12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
                onPressed: _loadUsers, child: const Text(TTexts.uiTextRetry)),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const SizedBox(
        key: ValueKey('empty'),
        height: TSizes.v100,
        child: Center(
          child: Text(
            TTexts.uiTextNoUsersAreAvailableForToday,
            style: TextStyle(
              color: TColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final previewUsers = _users.take(_previewLimit).toList(growable: false);

    return Column(
      key: const ValueKey('users'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          TTexts.uiTextSelectOneOrMoreAvailableUsersForJoint,
          style: TextStyle(
            color: TColors.textSecondary,
            fontSize: TSizes.v12,
          ),
        ),
        const SizedBox(height: TSizes.v12),
        ...previewUsers.map(
          (user) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: HandshakeUserTile(
              user: user,
              selected: _selectedIds.contains(user.id),
              onTap: () => _toggleUser(user),
            ),
          ),
        ),
        if (_users.length > _previewLimit)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _openFullList,
              icon: const Icon(Icons.people_alt_outlined, size: TSizes.v18),
              label: Text('View More (${_users.length})'),
            ),
          ),
        const Divider(height: TSizes.v24, color: TColors.borderSecondary),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedIds.length} user(s) selected',
                    style: const TextStyle(
                      color: TColors.textPrimary,
                      fontSize: TSizes.v12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: TSizes.v2),
                  const Text(
                    TTexts.uiTextVerifyDetailsBeforeSending,
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: TSizes.v10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: TSizes.v12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _sent ? TColors.success : TColors.primary,
                foregroundColor: TColors.white,
                minimumSize: const Size(136, 46),
              ),
              onPressed: _selectedIds.isEmpty || _sending || _sent
                  ? null
                  : _sendSelectedUsers,
              icon: _sending
                  ? const SizedBox(
                      width: TSizes.v17,
                      height: TSizes.v17,
                      child: CircularProgressIndicator(
                        strokeWidth: TSizes.v2,
                        color: TColors.white,
                      ),
                    )
                  : Icon(
                      _sent ? Icons.check_circle : Icons.send_rounded,
                      size: TSizes.v18,
                    ),
              label: Text(
                _sending
                    ? 'Sending...'
                    : _sent
                        ? 'Sent'
                        : 'Send Request',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
