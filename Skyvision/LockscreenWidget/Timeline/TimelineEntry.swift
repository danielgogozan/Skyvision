//
//  File.swift
//  LockscreenWidgetExtension
//
//  Created by Daniel Gogozan on 15.07.2022.
//

import WidgetKit
import WeatherKit
import CoreLocation
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let currentHourWeather: HourWeather?
    
    var url: URL? {
        guard let location = configuration.Location?.location,
              let url = URL(string: "skyvision://widget/\(location.coordinate.latitude)/\(location.coordinate.longitude)") else {
            print("Unable to create URL or location might be nil. Location: \(String(describing: configuration.Location?.location))")
            return nil
        }
        return url
    }
    
    var image: Image {
        guard let condition = currentHourWeather?.condition else { return Image(systemName: "arrow.counterclockwise.icloud") }
        switch condition {
        case .clear:
            return Image(systemName: "sun.max")
        case .cloudy:
            return Image(systemName: "cloud")
        case .haze:
            return Image(systemName: "sun.haze")
        case .mostlyClear:
            return Image(systemName: "cloud.sun")
        case .mostlyCloudy:
            return Image(systemName: "cloud")
        case .partlyCloudy:
            return Image(systemName: "cloud.sun")
        case .scatteredThunderstorms:
            return Image(systemName: "cloud.bolt")
        case .breezy:
            return Image(systemName: "wind")
        default:
            print("Unknown condition: \(condition)")
            return Image(systemName: "arrow.counterclockwise.icloud")
        }
    }
}
