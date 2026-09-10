# Encrypted Offline Doctor Module

## Delivery boundary

This directory is a new, isolated, read-only doctor module. It does not modify the app entry point, route table, existing doctor feature, existing databases, platform files, or dependency manifests. The existing dashboard drawer now exposes it as **Offline Doctors** through `lib/features/dashboard/widgets/custrom_drawer.dart`.

The current API inventory contains only server-to-device download endpoints. Add Doctor, edit, delete, attachment upload, outbox processing, and automatic local-to-server upload are intentionally not implemented. The local record already reserves `localId`, nullable `serverId`, nullable `clientGeneratedId`, `localSyncState`, and exact nullable `syncVersion` for that later phase.

## Public entry points

- `doctor_offline.dart` exports the supported public API.
- `DoctorOfflineModule.initialize(...)` composes storage, HTTP, repository, synchronization, connectivity, and controller dependencies.
- `DoctorOfflineModule.screen()` returns the adaptive screen.
- `DoctorOfflineModule.dispose()` cancels listeners/sync work and closes the encrypted store.
- `DoctorOfflineEntryScreen` is a self-contained optional host widget that initializes and disposes one module instance.
- `DoctorOfflineBinding` is available for a host that wants tagged GetX registration; the screen itself does not require global GetX registration.

Only one module instance may open a given environment/account/scope namespace at one time.

## Repository integrations discovered

| Concern | Existing source reused |
|---|---|
| API base URL | `lib/utils/http/http_client.dart` through `THttpHelper.baseUrl` |
| Authentication | `lib/utils/local_storage/auth_manager.dart` through `AuthManager.getAuthToken()` and `getUserId()` |
| Colors | `lib/utils/constants/colors.dart` through `TColors` |
| Spacing and text-size tokens | `lib/utils/constants/sizes.dart` through `TSizes` |
| Typography and light/dark theme | `lib/utils/theam/custom_theme/text_theme.dart` and `lib/utils/theam/theme.dart` |
| State management | Existing GetX dependency through a module-local `GetxController` |
| At-rest key protection | Existing `flutter_secure_storage` dependency |
| Encrypted values | Existing Hive dependency with `HiveAesCipher` |

No direct HTTPS host is hardcoded in this module. `HttpDoctorRemoteDataSource` defaults to `THttpHelper.baseUrl`, adds `/api` only when the configured base does not already end with `/api`, and builds query parameters through `Uri`.

## Architecture

| Layer | Files and responsibility |
|---|---|
| Wire/domain/storage models | `models/doctor_dto.dart`, `models/doctor.dart`, `models/doctor_record.dart`, and `models/doctor_sync_models.dart` preserve the supplied fields and exact `BigInt` versions |
| Remote source | `data/remote/doctor_remote_data_source.dart` performs authenticated GET requests, timeout handling, URL construction, and strict envelope parsing |
| Encrypted local source | `data/local/hive_encrypted_doctor_local_data_source.dart` owns a separately scoped encrypted Hive box, immutable page segments, manifests, checkpoints, identity indexes, tombstones, and compaction |
| Key provider | `data/local/doctor_encryption_key_provider.dart` creates one random 256-bit key and stores it in platform-backed secure storage |
| Repository | `repositories/doctor_repository_impl.dart` maps layers and reconciles only by server/client identity while preserving stable local IDs |
| Search | `repositories/doctor_search_index.dart` keeps decrypted n-gram and filter indexes in memory only |
| Synchronization | `sync/doctor_sync_coordinator.dart` coalesces triggers, resumes bootstrap, validates progress, retries transient requests, and prevents late writes after scope changes |
| Controller | `controllers/doctor_offline_controller.dart` owns local query/filter/selection state plus resume and debounced connectivity triggers |
| UI | `ui/` renders phone/tablet portrait/landscape layouts, local search/filtering, pull-to-refresh, status states, and read-only details |

The encrypted local store is always the UI source of truth. A previous complete generation remains visible during a rebuild. Bootstrap pages are written as immutable encrypted segments and become visible only when one encrypted manifest/checkpoint value promotes the completed generation. Delta pages use the same write-segment-then-switch-manifest pattern, so a failed metadata commit leaves the prior visible records and checkpoint unchanged.

## API requests

The module sends no JSON request body for these calls:

```text
GET {{base_url}}/doctors/sync/bootstrap?limit=500
GET {{base_url}}/doctors/sync/bootstrap?cursor=<opaque-nextCursor>&limit=500
GET {{base_url}}/doctors/sync?afterVersion=<exact-saved-version>&limit=500
GET {{base_url}}/doctors/sync?afterVersion=<exact-saved-version>&limit=500&headOfficeId=<configured-uuid>
Authorization: Bearer <access-token>
Accept: application/json
```

The initial request does not send `page=1`. A returned cursor is treated as opaque and is never decoded or rebuilt. Bootstrap does not receive `headOfficeId` because that parameter was not confirmed for the bootstrap contract.

The DTO preserves these 31 received keys, normalizing the two client-ID aliases into one property: `id`, `name`, `specialization`, `clinicName`, `clinicAddress`, `location`, `latitude`, `longitude`, `email`, `phone`, `registrationNumber`, `yearsOfExperience`, `dateOfBirth`, `qualification`, `consultationFee`, `availableTimings`, `geoImageUrl`, `gender`, `anniversary`, `priority`, `headOfficeId`, `headOfficeName`, `areaId`, `areaName`, `ucpmpAnnualCap`, `createdByName`, `clientGeneratedId`, `client_generated_id`, `syncVersion`, `createdAt`, and `updatedAt`.

## Backend contract blockers

Bootstrap download is implemented against the supplied full response. Reliable incremental sync deliberately stops with a visible `protocolBlocked` status unless the delta response supplies all of the following:

1. A `deletes` array on every page, including an empty array when there are no deletions.
2. Deletion items shaped as `{ "id": "...", "syncVersion": <exact integer or decimal string> }`.
3. An explicit safe `nextAfterVersion` on every page.
4. `afterVersion` matching the requested checkpoint and a progressing continuation when `hasMore` is true.
5. Full-record upserts whose versions fall inside the committed page boundary.

Backend confirmation is still required for stable bootstrap snapshots, cursor expiry/rebootstrap response semantics, global version ordering, equal-version boundaries, tombstone retention, permission/territory removals, and whether `currentServerVersion` is global or page-safe. The module never advances to `currentServerVersion` merely because it is returned.

## Encryption and storage behavior

- Each environment/account/authorized-scope combination receives a SHA-256-derived non-PII namespace, separate directory, separate encrypted box name, and separate secure-storage key name.
- A random 32-byte key is stored through `FlutterSecureStorage`; it is never derived from a token or written beside the cache.
- Hive values containing doctor records, manifests, cursors, versions, and tombstones use `HiveAesCipher` AES-256 encryption.
- A non-secret HMAC key verifier is stored beside the box so a wrong key fails before Hive opens or attempts recovery. Encrypted-box crash recovery is disabled to prevent a wrong key from being mistaken for corruption and rewritten.
- If cache files exist but the secure key or verifier is missing/invalid, initialization fails. It never silently generates a replacement key over an inaccessible cache.
- Doctor names, payloads, phone numbers, addresses, tokens, keys, and cursors are not logged. Debug logs contain only operation categories, counts, durations, and retry timing.
- Decrypted search indexes exist only in memory. Doctor images are not downloaded or placed in Flutter's disk image cache; the detail screen only reports that a URL reference exists.

This implementation uses the encryption capability already locked in the project. It is not SQLCipher and does not claim SQLite page-level encryption or compliance certification. Adding SQLCipher would require prohibited dependency, native, and migration changes. Android/iOS backup exclusion also needs a host security decision and platform changes; none were applied. On shared devices, decide whether logout should retain the account-scoped encrypted cache for offline re-login or securely purge it. The current module retains it and isolates it by account/scope.

## Reliability behavior

- Sync triggers on module open, app resume, debounced network restoration, pull-to-refresh, and the refresh action.
- Connectivity is only a hint; requests still use bounded timeouts and up to three transient retries with exponential backoff and jitter, honoring numeric `Retry-After` seconds.
- Authentication and authorization failures do not retry indefinitely.
- Concurrent triggers share one in-flight sync.
- Scope checks run before requests and before writes, preventing a response for an old account from being committed.
- Returning users see cached doctors during delta checks, network failures, or a full rebuild.
- A first-install partial bootstrap remains hidden until promotion; its cursor and staging pages are retained for restart/resume.
- Generic segment keys contain no doctor identity. Server/client uniqueness is enforced in the encrypted materialized dataset.
- Delta tombstone versions survive encrypted compaction and block stale resurrection.

Android WorkManager/background execution is intentionally not added. The supplied requirement is reliable foreground/offline reading, and terminated-app execution cannot be guaranteed without host/platform changes.

## UI behavior

- Width, not orientation name, selects the layout.
- Widths below 900 logical pixels use one local list and a separate read-only detail route.
- Widths of 900 logical pixels or more use a master list and scrollable detail pane.
- Search covers name, clinic, specialization, location/address, territory names, and registration number.
- Priority, head-office, and area filters use local indexes and display names rather than UUIDs.
- Pull-to-refresh works even for an empty list through always-scrollable physics.
- Cached content is not replaced by a full-screen loader during sync.
- Missing values have explicit fallbacks, long text wraps, details scroll, and system text scaling is not clamped.
- No create, edit, delete, or upload control is exposed.

## Supported runtime boundary

The module targets the current Flutter mobile application, including Samsung Android tablets and iOS devices. It uses `dart:io`, application-support directories, Hive VM storage, and platform secure storage; web is not supported by this implementation. Desktop behavior was not validated.

## Verification

New tests are under `test/features/doctor_offline/` and cover:

- All supplied wire fields, aliases, malformed values, numeric variants, and exact versions.
- URL/API-prefix construction, first-page behavior, opaque cursor handling, and exact delta query versions.
- Encrypted close/reopen, wrong-key refusal, plaintext sentinel inspection, null and nonnull client IDs, stable local IDs, uniqueness, failed metadata commit, and account isolation.
- Multi-page bootstrap and delta, global watermark separation, interrupted bootstrap resume, repeated cursor rejection, unresolved delta blocking, concurrent triggers, and account-scope cancellation.
- Phone portrait detail navigation plus tablet portrait/landscape layout with increased text scale.

Run:

```bash
flutter test test/features/doctor_offline
dart analyze lib/features/doctor_offline test/features/doctor_offline
```

See `INTEGRATION.md` for the active drawer hook and optional alternative lifecycle wiring.
