import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicle_sales_rbsh/features/approval_management/controller/approval_management_controller.dart';

class _ApprovalController extends ApprovalManagementController {
  int pendingCalls = 0;
  int beatCalls = 0;
  int collaborationCalls = 0;

  @override
  Future<void> fetchPendingApprovals() async => pendingCalls++;

  @override
  Future<void> fetchPendingBeatChangeRequests() async => beatCalls++;

  @override
  Future<void> fetchCollaborationRequests() async => collaborationCalls++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final role in ['State Head', 'Manager', 'User', ' user ']) {
    test('$role uses current login role despite a stale role key', () async {
      SharedPreferences.setMockInitialValues({
        'role': role.trim().toLowerCase() == 'user' ? 'State Head' : 'User',
        'user_data': jsonEncode({
          'user': {'role': role, 'headOffices': []},
        }),
      });
      final controller = _ApprovalController();
      await controller.loadData();

      final isUser = role.trim().toLowerCase() == 'user';
      expect(controller.isUser, isUser);
      expect(controller.pendingCalls, isUser ? 0 : 1);
      expect(controller.beatCalls, isUser ? 0 : 1);
      expect(controller.collaborationCalls, 1);
    });
  }

  test('legacy sessions can still read the separate role key', () async {
    SharedPreferences.setMockInitialValues({'role': 'State Head'});
    final controller = _ApprovalController();
    await controller.loadData();
    expect(controller.isUser, false);
    expect(controller.pendingCalls, 1);
    expect(controller.beatCalls, 1);
  });
}
