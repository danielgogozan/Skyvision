//
//  TimelineProvider.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 15.07.2022.
//

import WidgetKit
import Intents
import WeatherKit
import CoreLocation

struct Provider: IntentTimelineProvider {
    
    let nextHoursCount = 3
    let midnightNextHoursCount = 1
    let widgetLocationManager = WidgetLocationManager()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), currentHourWeather: nil)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
       locationSnapshotTimelineEntry(date: Date(), configuration: configuration, completion: completion)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
         locationTimelineEntry(date: Date(), configuration: configuration, completion: completion)
    }
}

// MARK: - Snapshot Timeline Entry
private extension Provider {
    func locationSnapshotTimelineEntry(date: Date, configuration: ConfigurationIntent, completion: @escaping (SimpleEntry) -> ())  {
        if configuration.Location == nil {
            widgetLocationManager.requestLocation { placemark in
                guard let placemark else {
                    print("\(#function) placemark is null")
                    return
                }
                configuration.Location = placemark
                snapshotTimelineEntry(date: date, configuration: configuration, completion: completion)
            }
        } else {
            snapshotTimelineEntry(date: date, configuration: configuration, completion: completion)
        }
    }
    
    func snapshotTimelineEntry(date: Date, configuration: ConfigurationIntent, completion: @escaping (SimpleEntry) -> ())  {
        guard let location = configuration.Location?.location else {
            let entry = SimpleEntry(date: date, configuration: configuration, currentHourWeather: nil)
            completion(entry)
            return
        }
        
        Task {
            do {
                let weather = try await currentHourWeather(location: location, timeZone: configuration.Location?.timeZone ?? .current, currentDate: Date())
                let entry = SimpleEntry(date: date, configuration: configuration, currentHourWeather: weather)
                completion(entry)
            } catch {
                print("Error in \(#function): \(String(describing: error))")
            }
        }
    }
}

// MARK: - Timeline entry
private extension Provider {
    func locationTimelineEntry(date: Date, configuration: ConfigurationIntent, completion: @escaping (Timeline<SimpleEntry>) -> ())  {
        if configuration.Location == nil {
            widgetLocationManager.requestLocation { placemark in
                guard let placemark else {
                    print("\(#function) placemark is null")
                    return
                }
                configuration.Location = placemark
                createTimelineEntry(date: date, configuration: configuration, completion: completion)
            }
        } else {
            createTimelineEntry(date: date, configuration: configuration, completion: completion)
        }
    }
    
    func createTimelineEntry(date: Date, configuration: ConfigurationIntent, completion: @escaping (Timeline<SimpleEntry>) -> ())  {
        guard let location = configuration.Location?.location else { return }
        Task {
            do {
                let count = timelineNextHoursCount(considering: date, and: configuration.Location?.timeZone ?? .current)
                var entries: [SimpleEntry] = []
                let weather = try await nextHoursWeather(location: location,
                                                                    timeZone: configuration.Location?.timeZone ?? .current,
                                                                    date: date,
                                                                    count: count)
                print("Received hours weather: \(weather)")
                for index in 0 ..< count {
                    guard index >= 0 && index < weather.count else { continue }
                    let entryDate = date.addOrSubtractHour(hour: index, in: .current)
                    let entry = SimpleEntry(date: entryDate, configuration: configuration, currentHourWeather: weather[index])
                    entries.append(entry)
                }
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            } catch {
                print("Error in \(#function): \(String(describing: error))")
            }
        }
    }
}

// MARK: - Next hours weather provider
extension Provider {
    func nextHoursWeather(location: CLLocation, timeZone: TimeZone, date: Date, count: Int = 3) async throws -> [HourWeather] {
        let hoursToMatch = (0..<count).map{ date.addOrSubtractHour(hour: $0, in: timeZone).hour(in: timeZone) }
        return try await WeatherService.shared.weather(for: location)
            .hourlyForecast
            .forecast
            .filter { hourWeather in
                hourWeather.date.isToday(considering: timeZone) && hoursToMatch.contains { $0 == hourWeather.date.hour(in: timeZone) }
            }
    }
    
    func currentHourWeather(location: CLLocation, timeZone: TimeZone, currentDate: Date) async throws -> HourWeather? {
        return try await WeatherService.shared.weather(for: location)
            .hourlyForecast
            .forecast
            .first { $0.date.isToday(considering: timeZone) &&  currentDate.hour(in: timeZone) == $0.date.hour(in: timeZone) }
    }
    
    func timelineNextHoursCount(considering currentDate: Date, and timeZone: TimeZone = .current) -> Int {
        guard let currentHour = currentDate.hourComponent(timeZone: timeZone).hour else { return nextHoursCount }
        if currentHour + nextHoursCount - 1 >= 24 {
            return midnightNextHoursCount
        } else {
            return nextHoursCount
        }
    }
}
