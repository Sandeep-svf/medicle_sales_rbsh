package com.rbsh.medicle_sales_rbsh

import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // =========================================================
    // EXISTING DEVICE ID CHANNEL
    // =========================================================

    private val DEVICE_ID_CHANNEL = "device_id"

    // =========================================================
    // SAMSUNG BACKGROUND USAGE SETTINGS CHANNEL
    // =========================================================

    private val SAMSUNG_BATTERY_CHANNEL =
        "samsung_battery_settings"

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        // =====================================================
        // DEVICE ID
        //
        // KEEP THIS.
        // This returns Settings.Secure.ANDROID_ID.
        // =====================================================

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DEVICE_ID_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "getAndroidId" -> {

                    val androidId =
                        Settings.Secure.getString(
                            contentResolver,
                            Settings.Secure.ANDROID_ID
                        )

                    result.success(androidId)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }

        // =====================================================
        // SAMSUNG BATTERY / BACKGROUND USAGE SETTINGS
        // =====================================================

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SAMSUNG_BATTERY_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // =================================================
                // CHECK IF DEVICE IS SAMSUNG
                // =================================================

                "isSamsung" -> {

                    val isSamsung =
                        Build.MANUFACTURER.equals(
                            "samsung",
                            ignoreCase = true
                        )

                    result.success(isSamsung)
                }

                // =================================================
                // OPEN SAMSUNG BACKGROUND USAGE LIST
                //
                // activity_type:
                //
                // 0 = Sleeping apps
                // 1 = Deep sleeping apps
                // 2 = Never sleeping apps
                //
                // =================================================

                "openSamsungBatteryList" -> {

                    val activityType =
                        call.argument<Int>(
                            "activity_type"
                        ) ?: 2

                    try {

                        val intent = Intent()

                        intent.action =
                            "com.samsung.android.sm." +
                                    "ACTION_OPEN_CHECKABLE_LISTACTIVITY"

                        intent.setPackage(
                            "com.samsung.android.lool"
                        )

                        intent.putExtra(
                            "activity_type",
                            activityType
                        )

                        startActivity(intent)

                        result.success(true)

                    } catch (e: Exception) {

                        // =========================================
                        // FALLBACK
                        //
                        // If Samsung changes/removes the specific
                        // Device Care activity on some model,
                        // open normal Android Settings instead.
                        // =========================================

                        try {

                            val fallbackIntent =
                                Intent(
                                    Settings.ACTION_SETTINGS
                                )

                            startActivity(
                                fallbackIntent
                            )

                            result.success(false)

                        } catch (
                            fallbackError: Exception
                        ) {

                            result.error(
                                "SAMSUNG_SETTINGS_ERROR",
                                fallbackError.message,
                                null
                            )
                        }
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}