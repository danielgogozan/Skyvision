//
//  City.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 16.07.2022.
//

import Foundation
import CoreLocation

struct City: Equatable, Hashable {
    let name: String
    let country: String
    let location: CLLocation
    
    static func ==(lhs: City, rhs: City) -> Bool {
        return lhs.name == rhs.name && lhs.country == rhs.country
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(country)
    }
}
