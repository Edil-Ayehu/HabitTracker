//
//  HabitTrackerWidget.swift
//  HabitTrackerWidget
//

import WidgetKit
import SwiftUI

struct HabitWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitWidgetTimelineEntry {
        HabitWidgetTimelineEntry(date: Date(), data: WidgetSharedData.load())
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetTimelineEntry) -> ()) {
        let entry = HabitWidgetTimelineEntry(date: Date(), data: WidgetSharedData.load())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetTimelineEntry>) -> ()) {
        let data = WidgetSharedData.load()
        let entry = HabitWidgetTimelineEntry(date: Date(), data: data)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct HabitWidgetTimelineEntry: TimelineEntry {
    let date: Date
    let data: HabitWidgetData
}

struct HabitTrackerWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: HabitWidgetProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            HabitSmallWidgetView(data: entry.data)
        case .systemMedium:
            HabitMediumWidgetView(data: entry.data)
        case .accessoryCircular:
            HabitLockScreenCircularView(data: entry.data)
        case .accessoryRectangular:
            HabitLockScreenRectangularView(data: entry.data)
        default:
            HabitSmallWidgetView(data: entry.data)
        }
    }
}

struct HabitTrackerWidget: Widget {
    let kind: String = "HabitTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetProvider()) { entry in
            HabitTrackerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track your daily habits and streaks directly from your Home Screen or Lock Screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}
