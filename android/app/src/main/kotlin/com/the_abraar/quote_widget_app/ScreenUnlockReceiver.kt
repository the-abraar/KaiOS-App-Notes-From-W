package com.the_abraar.quote_widget_app

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import org.json.JSONObject
import java.io.File

class ScreenUnlockReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_USER_PRESENT) return

        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )

        val enabled = prefs.getBoolean("flutter.unlock_refresh_enabled", false)
        if (!enabled) return

        // Pick a new random image from the images directory
        val newImagePath = pickRandomImage(context) ?: return

        // Update stored widget_data with the new image path, preserve quote/author
        val existing = prefs.getString("flutter.widget_data", null)
        val updated = if (existing != null) {
            runCatching {
                val json = JSONObject(existing)
                json.put("imagePath", newImagePath)
                json.put("timestamp", System.currentTimeMillis())
                json.toString()
            }.getOrNull()
        } else null

        if (updated != null) {
            prefs.edit().putString("flutter.widget_data", updated).apply()
        }

        // Refresh all widget instances
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            ComponentName(context, QuoteWidgetProvider::class.java)
        )
        ids.forEach { QuoteWidgetProvider.updateWidget(context, manager, it) }
    }

    private fun pickRandomImage(context: Context): String? {
        // Match the path ImageService uses on Android: getExternalFilesDir(null)/images/
        val imagesDir = File(context.getExternalFilesDir(null), "images")
        if (!imagesDir.exists()) return null
        val images = imagesDir.listFiles { f -> f.extension.lowercase() == "jpg" }
        if (images.isNullOrEmpty()) return null
        return images.random().absolutePath
    }
}
