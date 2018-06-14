//
//  TimeZone+KinWallet.swift
//  Kinit
//

import Foundation

extension TimeZone {
    var fromGMT: String {
        let inSeconds = secondsFromGMT()

        let hours = abs(inSeconds / 3600)
        let minutes = abs((inSeconds % 3600) / 60)
        let sign = inSeconds >= 0 ? "+" : "-"

        return String(format: "\(sign)%02d:%02d", hours, minutes)
    }
}
