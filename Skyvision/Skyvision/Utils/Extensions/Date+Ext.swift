//
//  Date+Ext.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 12.07.2022.
//

import Foundation

enum WeekDay: Int, CaseIterable {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var displayName: String {
        switch self {
        case .sunday:
            return "SUN"
        case .monday:
            return "MON"
        case .tuesday:
            return "TUE"
        case .wednesday:
            return "WED"
        case .thursday:
            return "THU"
        case .friday:
            return "FRI"
        case .saturday:
            return "SAT"
        }
    }
}

extension Date {
    var weekDay: String {
        let dayIndex = Calendar.current.component(.weekday, from: self)
        return WeekDay(rawValue: dayIndex - 1)?.displayName ?? ""
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    func addOrSubtract(day: Int)-> Date {
        Calendar.current.date(byAdding: .day, value: day, to: self)!
    }
    
    func addOrSubtract(month: Int)-> Date {
        Calendar.current.date(byAdding: .month, value: month, to: self)!
    }
    
    func addOrSubtract(year: Int)-> Date {
        Calendar.current.date(byAdding: .year, value: year, to: self)!
    }
    
    func addOrSubtractHour(hour: Int, in timeZone: TimeZone)-> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        
        return calendar.date(byAdding: .hour, value: hour, to: self)!
    }
    
    func localDate() -> Date {
        let nowUTC = self
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else { return self }
        return localDate
    }
    
    func currentDate(in timeZone: TimeZone? = .current) -> Date {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        
        guard let currentDate = formatter.date(from: self.description) else { return Date() }
        return currentDate
    }
    
    func hour(in timeZone: TimeZone? = .current) -> String {
        let formatter = DateFormatter()
        
        formatter.timeZone = timeZone
        formatter.dateFormat = "HH:00"
        
        return formatter.string(from: self)
    }
    
    func hourAndMinutes(in timeZone: TimeZone? = .current) -> String {
        let formatter = DateFormatter()
        
        formatter.timeZone = timeZone
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: self)
    }
    
    func isToday(considering timezone: TimeZone? = .current) -> Bool {
        guard let timezone, timezone != .current else { return isToday }
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone
        return calendar.isDateInToday(self)
    }
    
    func isTomorrow(considering timezone: TimeZone? = .current) -> Bool {
        guard let timezone, timezone != .current else { return isToday }
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone
        return calendar.isDateInTomorrow(self)
    }
    
    func hourComponent(timeZone: TimeZone) -> DateComponents {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        
        return calendar.dateComponents([.hour], from: self)
    }
}
