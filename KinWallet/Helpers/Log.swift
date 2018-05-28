//
//  Log.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

enum KinitLogLevel: Int, Comparable, Equatable {
    case off = 0
    case error
    case warn
    case verbose
    case debug
}

extension KinitLogLevel: CustomStringConvertible {
    var description: String {
        switch self {
        case .error: return "ERROR"
        case .warn: return "WARNING"
        case .verbose: return "VERBOSE"
        case .debug: return "DEBUG"
        default: return ""
        }
    }
}

func <<T: RawRepresentable>(lhs: T, rhs: T) -> Bool where T.RawValue: Comparable {
    return lhs.rawValue < rhs.rawValue
}

public func ==<T: RawRepresentable>(lhs: T, rhs: T) -> Bool where T.RawValue: Equatable {
    return lhs.rawValue == rhs.rawValue
}

var logLevel = KinitLogLevel.off

func KLogError(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    if logLevel >= .error {
        KLog(String(describing: logLevel) + " " + message(), file: file, line: line)
    }
}

func KLogWarn(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    if logLevel >= .warn {
        KLog(String(describing: logLevel) + " " + message(), file: file, line: line)
    }
}

func KLogVerbose(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    if logLevel >= .verbose {
        KLog(String(describing: logLevel) + " " + message(), file: file, line: line)
    }
}

func KLogDebug(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    if logLevel >= .debug {
        KLog(String(describing: logLevel) + " " + message(), file: file, line: line)
    }
}

private func KLog(_ message: String, file: StaticString, line: UInt) {
    let aFile = String(describing: file)
    let lastPath = aFile.components(separatedBy: "/").last ?? ""

    print(lastPath + ":" + String(describing: line), message)
}
