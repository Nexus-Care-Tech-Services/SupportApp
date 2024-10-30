package com.example.support

import android.util.Log
import androidx.annotation.NonNull
import android.view.WindowManager
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.app.Notification;
import android.app.NotificationChannelGroup;
import android.net.Uri;
import android.media.AudioAttributes;
import android.content.ContentResolver;
import android.content.Intent
import android.content.IntentFilter
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.content.Context
import android.content.ContextWrapper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Objects
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.support/screen_control"

    private val NOTIFY_CHANNEL = "flutter_helper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "registerSensor" -> {
                    registerProximitySensor()
                    result.success(null)
                }

                "unregisterSensor" -> {
                    unregisterProximitySensor()
                    result.success(null)
                    print("unregister called")
                }

                "createnotifychannel" -> {
                    val response: Boolean
                    response = createnotifychannel()
                    if (response) {
                        result.success(response)
                    } else {
                        result.error("Error Code", "Error Message", null)
                    }
                }

                "createconstantnotifychannel" -> {
                    val response: Boolean
                    response = createconstantnotifychannel()
                    if (response) {
                        result.success(response)
                    } else {
                        result.error("Error Code", "Error Message", null)
                    }
                }

                else -> result.notImplemented()
            }
        }

    }

    private fun createnotifychannel(): Boolean {
        var completed: Boolean
        if (VERSION.SDK_INT >= VERSION_CODES.O) {
            val mChannel = NotificationChannel("support1", "ride", NotificationManager.IMPORTANCE_HIGH)
            mChannel.description = "Start | Ride"
            val soundUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + getApplicationContext().getPackageName() + "/raw/customsound");
            val att = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build();

            mChannel.setSound(soundUri, att)
            mChannel.enableVibration(true)
            mChannel.setShowBadge(true)
            mChannel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannelGroup(NotificationChannelGroup("support_media","Media"))
            mChannel.setGroup("support_media")
            notificationManager.createNotificationChannel(mChannel)
            completed = true
        } else {
            completed = false
        }
        return completed
    }

    private fun createconstantnotifychannel(): Boolean {
        var completed: Boolean
        if (VERSION.SDK_INT >= VERSION_CODES.O) {
            val mChannel = NotificationChannel("ongoing id", "ongoing content", NotificationManager.IMPORTANCE_HIGH)
            mChannel.description = "Media Content"

            mChannel.enableVibration(true)
            mChannel.setShowBadge(true)
            mChannel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannelGroup(NotificationChannelGroup("support_media","Media"))
            mChannel.setGroup("support_media")
            notificationManager.createNotificationChannel(mChannel)
            completed = true
        } else {
            completed = false
        }
        return completed
    }

    private fun registerProximitySensor() {
        val screenControlHandler = ScreenControlHandler(this)
        screenControlHandler.registerSensor()
    }

    private fun unregisterProximitySensor() {
        val screenControlHandler = ScreenControlHandler(this)
        screenControlHandler.unregisterSensor()
    }
}
