package com.the_abraar.quote_widget_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import org.json.JSONObject

class QuoteWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { id ->
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )
            val raw = prefs.getString("flutter.widget_data", null)
            val views = RemoteViews(context.packageName, R.layout.widget_quote)

            if (raw != null) {
                runCatching {
                    val json = JSONObject(raw)
                    val quote = json.getString("quote")
                    val author = json.getString("author")
                    val imagePath = json.optString("imagePath", "")

                    views.setTextViewText(R.id.widget_quote_text, "“$quote”")
                    views.setTextViewText(R.id.widget_author_text, "— $author")

                    if (imagePath.isNotEmpty()) {
                        // Sample down to max 500×500 to stay within RemoteViews 1MB IPC limit
                        val bitmap = decodeSampledBitmap(imagePath, 500, 500)
                        if (bitmap != null) {
                            views.setImageViewBitmap(R.id.widget_image, bitmap)
                        }
                    }
                }
            } else {
                views.setTextViewText(R.id.widget_quote_text, "“Tap the app to load a quote.”")
                views.setTextViewText(R.id.widget_author_text, "")
            }

            // Tap widget → open app
            val intent = Intent(context, MainActivity::class.java)
            val pending = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pending)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        // Decode at reduced resolution to avoid RemoteViews IPC size limit
        private fun decodeSampledBitmap(path: String, reqWidth: Int, reqHeight: Int): Bitmap? {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(path, bounds)
            if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null

            val opts = BitmapFactory.Options().apply {
                inSampleSize = calculateInSampleSize(bounds, reqWidth, reqHeight)
                inJustDecodeBounds = false
            }
            return runCatching { BitmapFactory.decodeFile(path, opts) }.getOrNull()
        }

        private fun calculateInSampleSize(
            opts: BitmapFactory.Options,
            reqWidth: Int,
            reqHeight: Int
        ): Int {
            val (h, w) = opts.outHeight to opts.outWidth
            var sample = 1
            if (h > reqHeight || w > reqWidth) {
                val halfH = h / 2
                val halfW = w / 2
                while (halfH / sample >= reqHeight && halfW / sample >= reqWidth) {
                    sample *= 2
                }
            }
            return sample
        }
    }
}
