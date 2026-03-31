package com.example.demo

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import com.example.live_activities.LiveActivityManager

class CustomOrderLiveActivityManager(context: Context) : LiveActivityManager(context) {
    private val appContext: Context = context.applicationContext

    private val launchIntent = PendingIntent.getActivity(
        appContext,
        200,
        Intent(appContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>
    ): Notification {
        val progress = getInt(data, "progress", 0).coerceIn(0, 100)
        val statusLabel = getString(data, "statusLabel", "Order placed")
        val productName = getString(data, "productName", "Order")
        val delivered = progress >= 100 ||
            statusLabel.equals("Delivered", ignoreCase = true) ||
            event == "end"

        val brand = getString(data, "brand", "demo express")
        val subtitle = getString(
            data,
            "subtitle",
            if (delivered) "Thank you for placing the order!" else "$productName is on the way"
        )
        val title = getString(
            data,
            "title",
            if (delivered) "Order arrived \u2705" else statusLabel
        )
        val actionLabel = getString(
            data,
            "actionLabel",
            if (delivered) "Rate order" else "Track order"
        )
        val glyph = if (delivered) "\u2705" else "\uD83D\uDE9A"
        val progressLine = "$progress% - $statusLabel"

        val compactView = buildRemoteView(
            layoutId = R.layout.notification_order_live_activity_compact,
            brand = brand,
            subtitle = subtitle,
            title = title,
            actionLabel = actionLabel,
            progress = progress,
            glyph = glyph,
            progressLine = progressLine
        )
        val expandedView = buildRemoteView(
            layoutId = R.layout.notification_order_live_activity_expanded,
            brand = brand,
            subtitle = subtitle,
            title = title,
            actionLabel = actionLabel,
            progress = progress,
            glyph = glyph,
            progressLine = progressLine
        )

        notification
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(progressLine)
            .setContentIntent(launchIntent)
            .setOngoing(!delivered)
            .setAutoCancel(delivered)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setPriority(Notification.PRIORITY_HIGH)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(compactView)
            .setCustomBigContentView(expandedView)

        if (delivered && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notification.setTimeoutAfter(90_000L)
        }

        return notification.build()
    }

    private fun buildRemoteView(
        layoutId: Int,
        brand: String,
        subtitle: String,
        title: String,
        actionLabel: String,
        progress: Int,
        glyph: String,
        progressLine: String
    ): RemoteViews {
        return RemoteViews(appContext.packageName, layoutId).apply {
            setTextViewText(R.id.order_brand_text, brand)
            setTextViewText(R.id.order_subtitle_text, subtitle)
            setTextViewText(R.id.order_title_text, title)
            setProgressBar(R.id.order_progress_bar, 100, progress, false)
            setTextViewText(R.id.order_action_chip, actionLabel)
            setTextViewText(R.id.order_progress_text, progressLine)
            setTextViewText(R.id.order_status_glyph, glyph)
            setTextViewText(R.id.order_status_percent, "$progress%")
        }
    }

    private fun getString(data: Map<String, Any>, key: String, fallback: String): String {
        val value = data[key]
        return if (value is String && value.isNotBlank()) value else fallback
    }

    private fun getInt(data: Map<String, Any>, key: String, fallback: Int): Int {
        val value = data[key]
        return when (value) {
            is Int -> value
            is Long -> value.toInt()
            is Double -> value.toInt()
            is Float -> value.toInt()
            is String -> value.toIntOrNull() ?: fallback
            else -> fallback
        }
    }
}
