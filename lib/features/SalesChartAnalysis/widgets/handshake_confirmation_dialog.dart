import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../model/handshake_available_user.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class HandshakeConfirmation {
  const HandshakeConfirmation({required this.notes});

  final String notes;
}

Future<HandshakeConfirmation?> showHandshakeConfirmationDialog({
  required BuildContext context,
  required List<HandshakeAvailableUser> selectedUsers,
  required DateTime date,
  required String dayId,
  String? beatName,
  String initialNotes = '',
}) async {
  final notesController = TextEditingController(text: initialNotes);

  final confirmation = await showDialog<HandshakeConfirmation>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: TColors.primary_shade50,
              child: Icon(Icons.fact_check_outlined, color: TColors.primary),
            ),
            SizedBox(width: TSizes.v12),
            Expanded(
              child: Text(
                TTexts.uiTextVerifyHandshakeRequest,
                style: TextStyle(
                    fontSize: TSizes.v18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: TSizes.v560,
            maxHeight: MediaQuery.sizeOf(dialogContext).height * .68,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: TColors.primary_shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: TTexts.date,
                        value: DateFormat('dd MMM yyyy').format(date),
                      ),
                      _SummaryRow(
                        label: TTexts.uiTextBeat,
                        value: (beatName ?? '').trim().isEmpty
                            ? 'Not available'
                            : beatName!.trim(),
                      ),
                      _SummaryRow(label: TTexts.uiTextDayID, value: dayId),
                      _SummaryRow(
                        label: TTexts.uiTextSelected,
                        value: '${selectedUsers.length} user(s)',
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.v16),
                const Text(
                  TTexts.uiTextSelectedUsers,
                  style: TextStyle(
                      fontSize: TSizes.v13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: TSizes.v8),
                ...selectedUsers.map(
                  (user) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TColors.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TColors.borderSecondary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: TColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: TSizes.v4),
                        Text(
                          '${user.displayRole} • Employee Code: ${user.displayEmployeeCode}',
                          style: const TextStyle(
                            color: TColors.textSecondary,
                            fontSize: TSizes.v11,
                          ),
                        ),
                        const SizedBox(height: TSizes.v3),
                        SelectableText(
                          'User ID: ${user.id}',
                          style: const TextStyle(
                            color: TColors.textSecondary,
                            fontSize: TSizes.v10,
                          ),
                        ),
                        const SizedBox(height: TSizes.v3),
                        Text(
                          user.available ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: user.available
                                ? TColors.success
                                : TColors.error,
                            fontSize: TSizes.v10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.v8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  maxLength: 250,
                  decoration: InputDecoration(
                    labelText: TTexts.notes,
                    hintText: TTexts.uiTextExampleJointDoctorVisitsInNorthZone,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(TTexts.cancel),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(
                HandshakeConfirmation(notes: notesController.text.trim()),
              );
            },
            icon: const Icon(Icons.send_rounded, size: TSizes.v18),
            label: const Text(TTexts.uiTextConfirmSend),
          ),
        ],
      );
    },
  );

  notesController.dispose();
  return confirmation;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: TColors.primary_shade100),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: TSizes.v76,
            child: Text(
              label,
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: TSizes.v11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: TColors.textPrimary,
                fontSize: TSizes.v11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
