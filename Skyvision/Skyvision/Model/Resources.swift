//
//  Resources.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 12.07.2022.
//

import UIKit
import WeatherKit

class Resources {
    static let shared = Resources()
    
    private init() {}
    
    func moonIcon(moonPhase: MoonPhase) -> UIImage {
        switch moonPhase {
        case .new:
            return UIImage(named: "moon-new")!
        case .waxingCrescent:
            return UIImage(named: "moon-waxing-crescent")!
        case .firstQuarter:
            return UIImage(named: "moon-first-quarter")!
        case .waxingGibbous:
            return UIImage(named: "moon-waxing-gibbous")!
        case .full:
            return UIImage(named: "moon-full")!
        case .waningGibbous:
            return UIImage(named: "moon-waning-gibbous")!
        case .lastQuarter:
            return UIImage(named: "moon-last-quarter")!
        case .waningCrescent:
            return UIImage(named: "moon-waning-crescent")!
        }
    }
    
    func contitionIcon(condition: WeatherCondition, fallbackIconName: String = "") -> UIImage {
        switch condition {
        case .clear:
            return UIImage(named: "condition-clear")!
        case .cloudy:
            return UIImage(named: "condition-cloudy")!
        case .haze:
            return UIImage(named: "condition-haze")!
        case .mostlyClear:
            return UIImage(named: "condition-mostly-clear")!
        case .mostlyCloudy:
            return UIImage(named: "condition-mostly-cloudy")!
        case .partlyCloudy:
            return UIImage(named: "condition-partly-cloudy")!
        case .scatteredThunderstorms, .thunderstorms, .isolatedThunderstorms:
            return UIImage(named: "condition-scattered-thunderstorms")!
        case .breezy:
            return UIImage(named: "condition-breezy")!
        case .rain:
            return UIImage(named: "condition-rain")!
        case .drizzle:
            return UIImage(named: "condition-drizzle")!
        default:
            print("Unknown condition: \(condition)")
            return UIImage(systemName: fallbackIconName)!
        }
    }
    
    func precipitationIcon(precipitation: Precipitation) -> UIImage? {
        switch precipitation {
        case .hail:
            return UIImage(named: "pp-hail")!
        case .mixed:
            return UIImage(named: "pp-mixed")!
        case .rain:
            return UIImage(named: "pp-rain")!
        case .sleet:
            return UIImage(named: "pp-sleet")!
        case .snow:
            return UIImage(named: "pp-snow")!
        default:
            return UIImage(named: "pp-none")!
        }
    }
}
