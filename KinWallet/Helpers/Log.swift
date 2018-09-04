//
//  Log.swift
//  Kinit
//

import Foundation
import Crashlytics

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

extension KinitLogLevel {
    func emoji() -> String {
        switch self {
        case .error: return "🛑"
        case .warn: return "⚠️"
        case .verbose: return "🔊"
        case .debug: return "🐛"
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

var logLevel = KinitLogLevel.verbose

func KLogError(_ code: Int,
               domain: String,
               userInfo: [String: Any]? = nil,
               file: StaticString = #file,
               line: UInt = #line) {
    if logLevel >= .error {
        var userInfoToSend: [String: Any] = ["file": String(file), "line": line]
        userInfo?.forEach {
            userInfoToSend[$0.key] = $0.value
        }

        let error = NSError(domain: domain, code: code, userInfo: userInfoToSend)
        KLogError(error, file: file, line: line)
    }
}

func KLogError(_ error: NSError, file: StaticString = #file, line: UInt = #line) {
    if logLevel >= .error {
        Crashlytics.sharedInstance().recordError(error)
        KLogError("\(error.domain) - \(error.code)", file: file, line: line)
    }
}

func KLogError(_ message: @autoclosure () -> Any, file: StaticString = #file, line: UInt = #line) {
    if logLevel >= .error {
        KLog(message(), file: file, line: line, level: .error)
    }
}

func KLogWarn(_ message: @autoclosure () -> Any, file: StaticString = #file, line: UInt = #line) {
    if logLevel >= .warn {
        KLog(message(), file: file, line: line, level: .warn)
    }
}

func KLogVerbose(_ message: @autoclosure () -> Any, file: StaticString = #file, line: UInt = #line) {
    if logLevel >= .verbose {
        KLog(message(), file: file, line: line, level: .verbose)
    }
}

func KLogDebug(_ message: @autoclosure () -> Any, file: StaticString = #file, line: UInt = #line) {
    if logLevel >= .debug {
        KLog(message(), file: file, line: line, level: .debug)
    }
}

private func KLog(_ message: Any, file: StaticString, line: UInt, level: KinitLogLevel) {
    DispatchQueue.global().async {
        let aFile = String(describing: file)
        let lastPath = aFile.components(separatedBy: "/").last ?? ""
        let emoji = level.emoji()

        print(emoji, level, emoji, lastPath + ":" + String(describing: line), message)
        CLSLogv("%@ %@:%@, %@",
                getVaList([String(describing: level), lastPath, String(describing: line), String(describing: message)]))
    }
}
