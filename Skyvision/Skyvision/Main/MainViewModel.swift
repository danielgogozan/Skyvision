//
//  MainViewModel.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 11.07.2022.
//

import Foundation
import WeatherKit
import CoreLocation
import Combine
import UIKit

enum WeatherSection: Int, CaseIterable {
    case segmentedControl
    case forecast
    case celestial
    case generalData
    case alert
}

enum ForecastType: Int {
    case daily
    case hourly
}

enum GeneralDataSection: Int, CaseIterable {
    case uv
    case temperature
    case precipitation
    case wind
    case air
    case pressure
    
    var icon: UIImage {
        switch self {
        case .temperature:
            return UIImage(named: "temperature")!
        case .uv:
            return UIImage(named: "uv")!
        case .precipitation:
            return UIImage(named: "precipitation")!
        case .wind:
            return UIImage(named: "wind")!
        case .air:
            return UIImage(named: "humidity")!
        case .pressure:
            return UIImage(named: "pressure")!
        }
    }
}

class MainViewModel {
    // MARK: - Private properties
    private let service = WeatherService()
    private var userWeather: Weather?
    private(set) var autoScrollEnabled = true
    
    // MARK: - Published properties
    @Published var dayForecastData: [ForecastData] = []
    @Published var hourForecastData: [ForecastData] = []
    @Published var alerts: [WeatherAlert] = []
    @Published var currentWeather: CurrentWeather?
    @Published var currentPlacemark: CLPlacemark?
    @Published var loading: Bool = false
    
    // MARK: - Public properties
    let geoCoder: CLGeocoder = CLGeocoder()
    
    var userLocation: CLLocation? {
        didSet {
            currentWeather(for: userLocation)
        }
    }
    
    var userTimezone: TimeZone {
        currentPlacemark?.timeZone ?? .current
    }

    var forecastType: ForecastType = .daily {
        didSet {
            autoScrollEnabled = true
        }
    }
    
    var indexToScroll: IndexPath {
        if autoScrollEnabled {
            autoScrollEnabled = false
            switch forecastType {
            case .daily:
                return IndexPath(item: dayForecastData.firstIndex(where: { $0.isNow }) ?? 0, section: WeatherSection.forecast.rawValue)
            case .hourly:
                return IndexPath(item: hourForecastData.firstIndex(where: { $0.isNow }) ?? 0, section: WeatherSection.forecast.rawValue)
            }
        }
        return IndexPath(item: 0, section: WeatherSection.forecast.rawValue)
    }
}

// MARK: - Private API
private extension MainViewModel {
    func currentWeather(for location: CLLocation?) {
        Task {
            do {
                defer { loading = false }
                loading = true
                try await fetchData(for: location)
                dayForecastData = dailyForecastData()
                hourForecastData = hourlyForecastData()
                currentWeather = userWeather?.currentWeather
                autoScrollEnabled = true
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func fetchData(for location: CLLocation?) async throws {
        guard let location else { return }
        try await withThrowingTaskGroup(of: Void.self, body: { group in
            group.addTask { self.currentPlacemark = await self.findPlacemark() ?? .none }
            group.addTask { self.userWeather = try await self.service.weather(for: location) }
            group.addTask { self.alerts = try await self.service.weather(for: location, including: .alerts) ?? [] }
            try await group.waitForAll()
        })
    }
    
    func dailyForecastData() -> [ForecastData] {
        guard let userWeather else { return [] }
        return userWeather.dailyForecast.forecast.map { //DayWeather object
            ForecastData(date: $0.date.weekDay,
                         icon: Resources.shared.contitionIcon(condition: $0.condition, fallbackIconName: $0.symbolName),
                         precipitationChance: $0.precipitationChance,
                         hTemperature: $0.highTemperature.value,
                         lTemperature: $0.lowTemperature.value,
                         apparentTemperature: nil,
                         isNow: $0.date.isToday(considering: currentPlacemark?.timeZone))
        }
    }
    
    func hourlyForecastData() -> [ForecastData] {
        guard let userWeather else { return [] }
        return userWeather.hourlyForecast.forecast.filter({ $0.date.isToday(considering: currentPlacemark?.timeZone) }).map { // HourWeather object
           return ForecastData(date: $0.date.hour(in: currentPlacemark?.timeZone),
                         icon: Resources.shared.contitionIcon(condition: $0.condition, fallbackIconName: $0.symbolName),
                         precipitationChance: $0.precipitationChance,
                         hTemperature: nil,
                         lTemperature: nil,
                         apparentTemperature: $0.apparentTemperature.value,
                         isNow: Date().currentDate(in: currentPlacemark?.timeZone).hour(in: currentPlacemark?.timeZone) == $0.date.hour(in: currentPlacemark?.timeZone))
        }
    }
    
    func findPlacemark() async -> CLPlacemark? {
        guard let userLocation else { return nil }
        do {
            let result = try await geoCoder.reverseGeocodeLocation(userLocation)
            guard let placemark = result.first else { return nil }
            return placemark
        } catch {
            print("Error getting placemark for user's location: \(error)")
            return nil
        }
    }
}

// MARK: - Collection View Data
extension MainViewModel {
    func numberOfSections() -> Int {
        return alerts.count == 0 ? WeatherSection.allCases.count - 1 : WeatherSection.allCases.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard let section = WeatherSection(rawValue: section) else { return 0 }
        
        switch section {
        case .segmentedControl:
            return 1
        case .forecast:
            return forecastType == .daily ? (dayForecastData.count == 0 ? 10 : dayForecastData.count) :
                                            (hourForecastData.count == 0 ? 24 : hourForecastData.count)
        case .celestial:
            return 1
        case .generalData:
            return GeneralDataSection.allCases.count
        case .alert:
            return alerts.count
        }
    }
    
    func forecastData(at index: Int) -> ForecastData? {
        guard index >= 0 else { return nil }
        
        switch forecastType {
        case .daily:
            guard index < dayForecastData.count else { return nil }
            return dayForecastData[index]
        case .hourly:
            guard index < hourForecastData.count else { return nil }
            return hourForecastData[index]
        }
    }
    
    var celestialData: (SunEvents, MoonEvents)? {
        guard let userWeather,
              let todayWeather = userWeather.dailyForecast.forecast.filter({ $0.date.isToday(considering: currentPlacemark?.timeZone) }).first
        else {
            return nil
        }
        
        return (todayWeather.sun, todayWeather.moon)
    }
    
    func data(for section: GeneralDataSection) -> GeneralDataInfo? {
        guard let userWeather,
              let currentDayForecast = userWeather.dailyForecast.first(where: { $0.date.isToday(considering: currentPlacemark?.timeZone) })
        else {
            return nil
        }
        
        let currentWeather = userWeather.currentWeather

        switch section {
        case .temperature:
            return .temperature(temperature: currentWeather.apparentTemperature, condition: currentWeather.condition)
        case .uv:
            return .uv(uvIndex: currentWeather.uvIndex)
        case .precipitation:
            return .precipitation(precipitation: currentDayForecast.precipitation, precipitationChance: currentDayForecast.precipitationChance)
        case .wind:
            return .wind(wind: currentWeather.wind)
        case .air:
            return .air(visibility: currentWeather.visibility, dewPoint: currentWeather.dewPoint, humidity: currentWeather.humidity)
        case .pressure:
            return .pressure(pressure: currentWeather.pressure, pressureTrend: currentWeather.pressureTrend)
        }
    }
    
    func alertData(at index: Int) -> WeatherAlert? {
        guard index >= 0, index < alerts.count else { return nil }
        return alerts[index]
    }
}
