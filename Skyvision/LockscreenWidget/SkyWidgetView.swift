//
//  SkyWidgetView.swift
//  LockscreenWidgetExtension
//
//  Created by Daniel Gogozan on 15.07.2022.
//

import SwiftUI
import WidgetKit

struct SkyWidgetView : View {
    
    @Environment(\.widgetFamily)
    var family
    var entry: Provider.Entry
    
    var body: some View {
        switch family {
        case .accessoryInline:
            HStack {
                entry.image
                Text("\(entry.configuration.Location?.locality ?? "---")")
            }
            .widgetURL(entry.url)
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                HStack {
                    entry.image
                    Text("\(entry.configuration.Location?.locality ?? "---")")
                        .font(.headline)
                }
                .widgetAccentable()
                Text("\(entry.currentHourWeather?.apparentTemperature.description ?? "---")")
                    .font(.subheadline)
                    .widgetAccentable()
                Text("\(entry.currentHourWeather?.condition.description ?? "---")")
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .widgetURL(entry.url)
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(alignment: .center) {
                    entry.image
                    Text("\(entry.configuration.Location?.locality ?? "---")")
                        .font(.footnote)
                }
                .widgetAccentable()
                .widgetURL(entry.url)
            }
        default:
            VStack {
                Text("Skyvision widget")
                Text("Current location: \(entry.configuration.Location?.locality ?? "---")")
                    .font(.footnote)
            }
            .widgetURL(entry.url)
        }
    }
}
