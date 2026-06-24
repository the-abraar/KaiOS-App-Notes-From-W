import WidgetKit
import SwiftUI

struct WidgetData {
    let quote: String
    let author: String
    let imagePath: String?

    static let placeholder = WidgetData(
        quote: "The only way to do great work is to love what you do.",
        author: "Steve Jobs",
        imagePath: nil
    )

    static func load() -> WidgetData {
        guard
            let defaults = UserDefaults(suiteName: "group.com.inovacetech.quotewidget"),
            let raw = defaults.string(forKey: "widget_data"),
            let data = raw.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return .placeholder }

        return WidgetData(
            quote: json["quote"] as? String ?? placeholder.quote,
            author: json["author"] as? String ?? placeholder.author,
            imagePath: json["imagePath"] as? String
        )
    }
}

struct QuoteEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct QuoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: .now, data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        completion(QuoteEntry(date: .now, data: .load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let data = WidgetData.load()
        let entry = QuoteEntry(date: .now, data: data)
        let defaults = UserDefaults(suiteName: "group.com.inovacetech.quotewidget")
        let interval = defaults?.integer(forKey: "refresh_interval_minutes") ?? 30
        let next = Calendar.current.date(byAdding: .minute, value: interval, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct QuoteWidgetView: View {
    var entry: QuoteEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                // Background image
                if let path = entry.data.imagePath,
                   let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Color.black
                }

                // Gradient scrim
                LinearGradient(
                    colors: [.clear, .black.opacity(0.85)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Quote text
                VStack(alignment: .leading, spacing: 4) {
                    Text("\u{201C}\(entry.data.quote)\u{201D}")
                        .font(family == .systemSmall ? .caption : .footnote)
                        .italic()
                        .foregroundColor(.white)
                        .lineLimit(family == .systemSmall ? 3 : 5)
                    Text("— \(entry.data.author)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.75))
                }
                .padding(10)
            }
        }
    }
}

@main
struct QuoteWidgetBundle: Widget {
    let kind = "QuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            QuoteWidgetView(entry: entry)
        }
        .configurationDisplayName("Quote Widget")
        .description("Random image with an inspiring quote.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
