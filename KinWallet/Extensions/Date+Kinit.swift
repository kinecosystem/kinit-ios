//
//  Date+Kinit.swift
//  Kinit
//

import Foundation

let secondsInADay: TimeInterval = 60*60*24

extension Date {
    func beginningOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }

    func endOfDay() -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: beginningOfDay())!
    }
}
