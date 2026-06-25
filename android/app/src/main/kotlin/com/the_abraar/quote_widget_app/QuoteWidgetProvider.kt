package com.the_abraar.quote_widget_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
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
                    val imagePath = json.getString("imagePath")

                    views.setTextViewText(R.id.widget_quote_text, "“$quote”")
                    views.setTextViewText(R.id.widget_author_text, "— $author")

                    val bitmap = BitmapFactory.decodeFile(imagePath)
                    if (bitmap != null) {
                        views.setImageViewBitmap(R.id.widget_image, bitmap)
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
    }
}
