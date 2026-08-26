import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../model/handshake_available_user.dart';
import '../services/handshake_service.dart';
import '../widgets/handshake_confirmation_dialog.dart';
import '../widgets/handshake_user_tile.dart';

class HandshakePageResult {
  const HandshakePageResult({
    required this.submitted,
    required this.message,
  });

  final bool submitted;
  final String message;
}

class HandshakeUserListScreen extends StatefulWidget {
  const HandshakeUserListScreen({
    super.key,
    required this.initialUsers,
    required this.initialSelectedIds,
    required this.dayId,
    required this.date,
    this.beatName,
  });

  final List<HandshakeAvailableUser> initialUsers;
  final Set<String> initialSelectedIds;
  final String dayId;
  final DateTime date;
  final String? beatName;

  @override
  State<HandshakeUserListScreen> createState() =>
      _HandshakeUserListScreenState();
}

class _HandshakeUserListScreenState extends State<HandshakeUserListScreen> {
  final HandshakeService _service = const HandshakeService();
  final TextEditingController _searchController = TextEditingController();

  late List<HandshakeAvailableUser> _users;
  late Set<String> _selectedIds;

  bool _refreshing = false;
  bool _submitting = false;
  String _search = '';
  String _notes = '';

  List<HandshakeAvailableUser> get _filteredUsers {
    final normalizedSearch = _search.trim().toLowerCase();
    if (normalizedSearch.isEmpty) return _users;

    return _users.where((user) {
      return user.displayName.toLowerCase().contains(normalizedSearch) ||
          user.displayRole.toLowerCase().contains(normalizedSearch) ||
          user.displayEmployeeCode.toLowerCase().contains(normalizedSearch);
    }).toList(growable: false);
  }

  List<HandshakeAvailableUser> get _selectedUsers {
    return _users
        .where((user) => _selectedIds.contains(user.id))
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _users = List<HandshakeAvailableUser>.from(widget.initialUsers);
    _selectedIds = Set<String>.from(widget.initialSelectedIds);
    _selectedIds.retainAll(_users.map((user) => user.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleUser(HandshakeAvailableUser user) {
    if (_submitting || !user.available) return;

    setState(() {
      if (!_selectedIds.add(user.id)) {
        _selectedIds.remove(user.id);
      }
    });
  }

  Future<void> _refreshUsers() async {
    if (_refreshing) return;

    setState(() => _refreshing = true);

    try {
      final users = await _service.fetchAvailableUsers(date: widget.date);
      if (!mounted) return;

      setState(() {
        _users = users;
        _selectedIds.retainAll(users.map((user) => user.id));
      });
    } catch (error) {
      if (!mounted) return;
      _showMessage(HandshakeService.errorMessage(error), isError: true);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _submit() async {
    final selectedUsers = _selectedUsers;
    if (selectedUsers.isEmpty || _submitting) return;

    final confirmation = await showHandshakeConfirmationDialog(
      context: context,
      selectedUsers: selectedUsers,
      date: widget.date,
      dayId: widget.dayId,
      beatName: widget.beatName,
      initialNotes: _notes,
    );

    if (confirmation == null || !mounted) return;
    _notes = confirmation.notes;

    setState(() => _submitting = true);

    try {
      final result = await _service.sendRequest(
        dayId: widget.dayId,
        userIds: selectedUsers.map((user) => user.id),
        notes: _notes,
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      Navigator.of(context).pop(
        HandshakePageResult(
          submitted: result.success,
          message: result.message,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showMessage(HandshakeService.errorMessage(error), isError: true);
    }
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
    final filteredUsers = _filteredUsers;

    return Scaffold(
      backgroundColor: TColors.light,
      appBar: AppBar(
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Available Handshake Users'),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedIds.length} selected',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: 'Search by name, role or employee code',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshUsers,
              child: filteredUsers.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 130),
                        Icon(
                          Icons.person_search_outlined,
                          size: 56,
                          color: TColors.darkGrey,
                        ),
                        SizedBox(height: 12),
                        Center(
                          child: Text(
                            'No available users found',
                            style: TextStyle(
                              color: TColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return HandshakeUserTile(
                          user: user,
                          selected: _selectedIds.contains(user.id),
                          onTap: () => _toggleUser(user),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: TColors.borderSecondary),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedIds.length} user(s) selected',
                      style: const TextStyle(
                        color: TColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'A verification popup appears before sending.',
                      style: TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(142, 48),
                ),
                onPressed: _selectedIds.isEmpty || _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(_submitting ? 'Sending...' : 'Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
