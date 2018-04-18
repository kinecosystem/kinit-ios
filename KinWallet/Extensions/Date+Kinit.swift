//
//  Date+Kinit.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
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
