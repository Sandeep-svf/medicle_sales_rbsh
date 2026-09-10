# Host Integration

The dashboard side menu is now wired in `lib/features/dashboard/widgets/custrom_drawer.dart` with the user-facing name **Offline Doctors**. It reads the current account ID and opens `DoctorOfflineEntryScreen` as a full-screen route, which owns initialization and disposal.

## Active navigation pattern

The applied drawer hook follows this pattern:

```dart
import 'package:medicle_sales_rbsh/features/doctor_offline/doctor_offline.dart';

final accountId = await AuthManager().getUserId();
if (accountId == null || accountId.isEmpty) return;

await Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => DoctorOfflineEntryScreen(
      accountId: accountId,
      authorizedScopeId: confirmedAuthorizedScopeId,
      deltaHeadOfficeId: confirmedDeltaHeadOfficeId,
    ),
  ),
);
```

`authorizedScopeId` namespaces local data. It is not automatically sent to an undocumented API parameter. `deltaHeadOfficeId` is sent only to the documented optional delta query. Pass each value only after the host confirms its business meaning.

## Explicit lifecycle hook

A host that owns module lifetime can compose and dispose it directly:

```dart
final module = await DoctorOfflineModule.initialize(
  accountId: accountId,
  authorizedScopeId: confirmedAuthorizedScopeId,
  deltaHeadOfficeId: confirmedDeltaHeadOfficeId,
);

try {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => module.screen()),
  );
} finally {
  await module.dispose();
}
```

Do not initialize two module instances for the same namespace. Dispose the old module before switching account, environment, tenant, or authorized scope.

## Optional GetX route binding

`module.binding` exposes a tagged `DoctorOfflineBinding`, and `module.getXTag` exposes its tag. Use it only if a future host route needs `Get.find<DoctorOfflineController>(tag: module.getXTag)`. The current `module.screen()` receives its controller directly and avoids global registration.

## Required host decisions before release

1. Choose the existing menu/dashboard navigation point. This is the only required UI wiring change.
2. Confirm the account and authorized dataset scope used for cache namespacing.
3. Confirm whether the optional delta `headOfficeId` must be sent for this signed-in role.
4. Confirm logout policy: retain the isolated encrypted cache for offline re-login or add an explicit secure purge flow.
5. Decide Android/iOS backup policy. For a strict no-backup policy, the Android host can set `android:allowBackup="false"` on the existing `<application>` element; no manifest change was made. iOS directory backup exclusion needs a verified native host implementation.
6. Confirm the backend delta deletion and continuation contract listed in `README.md`.
7. Confirm token-refresh behavior. The current project exposes token retrieval but no refresh callback in `AuthManager`; HTTP 401 therefore becomes a sign-in-required state.

## Deferred Add Doctor contract

Before implementing offline creation/upload, provide and confirm:

- Endpoint path, HTTP method, authorization/permission rules, and required fields.
- Canonical request body and whether `clientGeneratedId` is a durable idempotency key.
- Success/error response, server-ID reconciliation, duplicate handling, and lost-response behavior.
- Validation, edit/delete semantics, version/conflict policy, and territory reassignment behavior.
- Attachment fields, multipart names, size/type limits, optionality, and upload retry rules.

The next phase should add an encrypted transactional outbox and preserve one `clientGeneratedId` across retries. Connectivity must not trigger uploads until that contract exists.

## Optional SQLCipher migration

No SQLCipher dependency is currently present. Replacing encrypted Hive with page-level SQLCipher requires a separate approved change to `pubspec.yaml`, the lockfile, native configuration, migration/rebuild policy, and platform tests. Do not point SQLCipher at any existing application database or silently migrate/clear it.
