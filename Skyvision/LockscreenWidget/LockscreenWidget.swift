//
//  LockscreenWidget.swift
//  LockscreenWidget
//
//  Created by Daniel Gogozan on 15.07.2022.
//

import WidgetKit
import SwiftUI
import Intents


//@main
//struct SkyWidgetBundle: WidgetBundle {
//    @WidgetBundleBuilder
//    var body: some View {
//        SkyWidget()
//    }
//}

@main
struct SkyWidget: Widget {
    let kind: String = "SkyWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SkyWidgetView(entry: entry)
        }
        .configurationDisplayName("Skyvision")
        .description("This is Skyvision widget.")
        .supportedFamilies([.accessoryInline, .accessoryRectangular, .accessoryCircular])
    }
}

struct SkyWidget_Previews: PreviewProvider {
    static var previews: some View {
        SkyWidgetView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), currentHourWeather: nil))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}

