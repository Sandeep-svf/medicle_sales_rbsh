import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../utils/constants/colors.dart';

class HandshakeRequestCard extends StatefulWidget {
  const HandshakeRequestCard({super.key});

  @override
  State<HandshakeRequestCard> createState() =>
      _HandshakeRequestCardState();
}

class _HandshakeRequestCardState extends State<HandshakeRequestCard> {
  // ---------------------------------------------------------------------------
  // UI ONLY - Replace with API response later
  // ---------------------------------------------------------------------------

  final List<_HandshakeUser> _users = const [
    _HandshakeUser(
      id: '1',
      name: 'Rajesh Kumar',
      designation: 'ASM',
    ),
    _HandshakeUser(
      id: '2',
      name: 'Amit Singh',
      designation: 'RSM',
    ),
    _HandshakeUser(
      id: '3',
      name: 'Vivek Sharma',
      designation: 'ZSM',
    ),
  ];

  final Set<String> _selectedIds = {};

  bool _isSending = false;
  bool _isSent = false;

  int get _selectedCount => _selectedIds.length;

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  void _toggleUser(String id) {
    if (_isSending) return;

    setState(() {
      _isSent = false;

      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // UI ONLY - Fake API
  // ---------------------------------------------------------------------------

  Future<void> _sendRequest() async {
    if (_selectedIds.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _isSent = false;
    });

    // Simulating API request
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isSending = false;
      _isSent = true;
    });

    // Keep success state visible briefly.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSent = false;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TColors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // Header
          // -------------------------------------------------------------------

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: TColors.primary_shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.handshake_rounded,
                  color: TColors.primary,
                  size: 25,
                ),
              )
                  .animate(
                onPlay: (controller) => controller.repeat(
                  reverse: true,
                ),
              )
                  .scale(
                begin: const Offset(.96, .96),
                end: const Offset(1.04, 1.04),
                duration: 1400.ms,
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FIELD SUPPORT',
                      style: TextStyle(
                        color: TColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Request a Handshake',
                      style: TextStyle(
                        color: TColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              if (_selectedCount > 0)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Container(
                    key: ValueKey(_selectedCount),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.primary_shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_selectedCount selected',
                      style: const TextStyle(
                        color: TColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            'Select one or more reporting managers you want to work with today.',
            style: TextStyle(
              color: TColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          // -------------------------------------------------------------------
          // Manager List
          // -------------------------------------------------------------------

          ...List.generate(
            _users.length,
                (index) {
              final user = _users[index];

              final selected = _selectedIds.contains(user.id);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _users.length - 1 ? 0 : 10,
                ),
                child: _ManagerSelectionTile(
                  user: user,
                  selected: selected,
                  onTap: () => _toggleUser(user.id),
                )
                    .animate()
                    .fadeIn(
                  delay: Duration(
                    milliseconds: 100 + (index * 80),
                  ),
                  duration: 350.ms,
                )
                    .slideX(
                  begin: .08,
                  end: 0,
                  delay: Duration(
                    milliseconds: 100 + (index * 80),
                  ),
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          Divider(
            height: 1,
            color: TColors.borderSecondary.withOpacity(.8),
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // Bottom Action
          // -------------------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _selectedCount == 0
                      ? const Column(
                    key: ValueKey('empty'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No manager selected',
                        style: TextStyle(
                          color: TColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Select a manager to continue',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                      : Column(
                    key: ValueKey(_selectedCount),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ready to send',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_selectedCount ${_selectedCount == 1 ? 'manager' : 'managers'} selected',
                        style: const TextStyle(
                          color: TColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              _SendHandshakeButton(
                enabled: _selectedIds.isNotEmpty,
                isSending: _isSending,
                isSent: _isSent,
                onPressed: _sendRequest,
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
      duration: 500.ms,
    )
        .slideY(
      begin: .12,
      end: 0,
      duration: 500.ms,
      curve: Curves.easeOutCubic,
    );
  }
}

// =============================================================================
// MANAGER TILE
// =============================================================================

class _ManagerSelectionTile extends StatelessWidget {
  final _HandshakeUser user;
  final bool selected;
  final VoidCallback onTap;

  const _ManagerSelectionTile({
    required this.user,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1 : .985,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected
                  ? TColors.primary_shade50
                  : TColors.lightGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? TColors.primary
                    : TColors.borderSecondary,
                width: selected ? 1.4 : 1,
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color: TColors.primary.withOpacity(.10),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
                  : null,
            ),
            child: Row(
              children: [
                // Avatar

                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                      colors: [
                        TColors.primary,
                        TColors.primary_shade700,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: selected
                        ? null
                        : TColors.primary_shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(user.name),
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : TColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Manager Information

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white
                                  : TColors.primary_shade50,
                              borderRadius:
                              BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.designation,
                              style: const TextStyle(
                                color: TColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text(
                              'Reporting Manager',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: TColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Animated selection indicator

                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: selected
                        ? TColors.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? TColors.primary
                          : TColors.darkGrey,
                      width: 1.5,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: selected
                        ? const Icon(
                      Icons.check_rounded,
                      key: ValueKey('checked'),
                      color: Colors.white,
                      size: 17,
                    )
                        : const SizedBox(
                      key: ValueKey('unchecked'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((element) => element.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// =============================================================================
// SEND BUTTON
// =============================================================================

class _SendHandshakeButton extends StatelessWidget {
  final bool enabled;
  final bool isSending;
  final bool isSent;
  final VoidCallback onPressed;

  const _SendHandshakeButton({
    required this.enabled,
    required this.isSending,
    required this.isSent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled || isSending || isSent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 48,
      constraints: const BoxConstraints(
        minWidth: 130,
      ),
      decoration: BoxDecoration(
        gradient: active && !isSent
            ? const LinearGradient(
          colors: [
            TColors.primary,
            TColors.primary_shade700,
          ],
        )
            : null,
        color: isSent
            ? TColors.success
            : active
            ? null
            : TColors.buttonDisabled,
        borderRadius: BorderRadius.circular(14),
        boxShadow: active && !isSending
            ? [
          BoxShadow(
            color: (isSent
                ? TColors.success
                : TColors.primary)
                .withOpacity(.20),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
          enabled && !isSending && !isSent ? onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isSending) {
      return const Row(
        key: ValueKey('sending'),
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 9),
          Text(
            'Sending...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    if (isSent) {
      return const Row(
        key: ValueKey('sent'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 18,
          ),
          SizedBox(width: 7),
          Text(
            'Request Sent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return Row(
      key: const ValueKey('send'),
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: 17,
        ),
        SizedBox(width: 8),
        Text(
          'Send Request',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// TEMP MODEL
// Later remove this and use your API model.
// =============================================================================

class _HandshakeUser {
  final String id;
  final String name;
  final String designation;

  const _HandshakeUser({
    required this.id,
    required this.name,
    required this.designation,
  });
}