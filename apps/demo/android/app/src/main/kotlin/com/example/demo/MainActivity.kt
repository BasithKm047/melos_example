package com.example.demo

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.example.demo.R
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private val liveActivityChannelName = "order_android_live_activity"
    private val orderTrackingChannelId = "order_tracking_channel"
    private val orderTrackingChannelName = "Order Tracking"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            liveActivityChannelName
        ).setMethodCallHandler { call, result ->
            handleLiveActivityMethodCall(call, result)
        }
    }

    private fun handleLiveActivityMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val payload = AndroidLiveActivityPayload.fromArguments(call.arguments)
        if (payload == null) {
            result.error(
                "invalid_args",
                "Expected orderId, productName, statusLabel, and progress",
                null
            )
            return
        }

        when (call.method) {
            "startLiveActivity" -> result.success(showOrUpdateOrderNotification(payload, ongoing = true))
            "updateLiveActivity" -> result.success(showOrUpdateOrderNotification(payload, ongoing = true))
            "endLiveActivity" -> result.success(showOrUpdateOrderNotification(payload, ongoing = false))
            else -> result.notImplemented()
        }
    }

    private fun showOrUpdateOrderNotification(
        payload: AndroidLiveActivityPayload,
        ongoing: Boolean
    ): Boolean {
        createNotificationChannelIfNeeded()

        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return false
        }

        val compactView = buildCompactView(payload)
        val expandedView = buildExpandedView(payload)
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val contentIntent = launchIntent?.let {
            PendingIntent.getActivity(
                this,
                payload.orderId,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val delivered = payload.progress >= 100 || !ongoing
        val builder = NotificationCompat.Builder(this, orderTrackingChannelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setOngoing(!delivered)
            .setAutoCancel(delivered)
            .setCustomContentView(compactView)
            .setCustomBigContentView(expandedView)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())

        if (contentIntent != null) {
            builder.setContentIntent(contentIntent)
        }

        if (delivered) {
            builder.setTimeoutAfter(90_000)
        }

        NotificationManagerCompat.from(this).notify(payload.orderId, builder.build())
        return true
    }

    private fun buildCompactView(payload: AndroidLiveActivityPayload): RemoteViews {
        val delivered = payload.progress >= 100
        val title = if (delivered) "Order arrived \u2705" else payload.statusLabel
        val subtitle = if (delivered) {
            "Thank you for placing the order!"
        } else {
            "${payload.productName} is on the way"
        }
        val actionLabel = if (delivered) "Rate order" else "Track order"
        val statusGlyph = if (delivered) "\u2705" else "\uD83D\uDE9A"

        return RemoteViews(packageName, R.layout.notification_order_live_activity_compact).apply {
            setTextViewText(R.id.order_brand_text, "demo express")
            setTextViewText(R.id.order_subtitle_text, subtitle)
            setTextViewText(R.id.order_title_text, title)
            setProgressBar(R.id.order_progress_bar, 100, payload.progress, false)
            setTextViewText(R.id.order_action_chip, actionLabel)
            setTextViewText(
                R.id.order_progress_text,
                "${payload.progress}% - ${payload.statusLabel}"
            )
            setTextViewText(R.id.order_status_glyph, statusGlyph)
            setTextViewText(R.id.order_status_percent, "${payload.progress}%")
        }
    }

    private fun buildExpandedView(payload: AndroidLiveActivityPayload): RemoteViews {
        val delivered = payload.progress >= 100
        val title = if (delivered) "Order arrived \u2705" else payload.statusLabel
        val subtitle = if (delivered) {
            "Thank you for placing the order!"
        } else {
            "${payload.productName} is on the way"
        }
        val actionLabel = if (delivered) "Rate order" else "Track order"
        val statusGlyph = if (delivered) "\u2705" else "\uD83D\uDE9A"

        return RemoteViews(packageName, R.layout.notification_order_live_activity_expanded).apply {
            setTextViewText(R.id.order_brand_text, "demo express")
            setTextViewText(R.id.order_subtitle_text, subtitle)
            setTextViewText(R.id.order_title_text, title)
            setProgressBar(R.id.order_progress_bar, 100, payload.progress, false)
            setTextViewText(R.id.order_action_chip, actionLabel)
            setTextViewText(
                R.id.order_progress_text,
                "${payload.progress}% - ${payload.statusLabel}"
            )
            setTextViewText(R.id.order_status_glyph, statusGlyph)
            setTextViewText(R.id.order_status_percent, "${payload.progress}%")
        }
    }

    private fun createNotificationChannelIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val channel = NotificationChannel(
            orderTrackingChannelId,
            orderTrackingChannelName,
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Tracks order delivery progress"
            setShowBadge(false)
        }

        val manager = getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(channel)
    }
}

private data class AndroidLiveActivityPayload(
    val orderId: Int,
    val productName: String,
    val statusLabel: String,
    val progress: Int
) {
    companion object {
        fun fromArguments(arguments: Any?): AndroidLiveActivityPayload? {
            val map = arguments as? Map<*, *> ?: return null
            val orderId = (map["orderId"] as? Number)?.toInt() ?: return null
            val productName = map["productName"] as? String ?: return null
            val statusLabel = map["statusLabel"] as? String ?: return null
            val rawProgress = (map["progress"] as? Number)?.toInt() ?: return null

            return AndroidLiveActivityPayload(
                orderId = orderId,
                productName = productName,
                statusLabel = statusLabel,
                progress = rawProgress.coerceIn(0, 100)
            )
        }
    }
}

