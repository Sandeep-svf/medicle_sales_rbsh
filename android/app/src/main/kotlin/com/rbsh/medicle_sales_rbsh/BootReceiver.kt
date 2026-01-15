package com.rbsh.medicle_sales_rbsh

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.annotation.SuppressLint

class BootReceiver : BroadcastReceiver() {

    @SuppressLint("QueryPermissionsNeeded")
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {

            val launchIntent =
                context.packageManager.getLaunchIntentForPackage(context.packageName)

            launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(launchIntent)
        }
    }
}

