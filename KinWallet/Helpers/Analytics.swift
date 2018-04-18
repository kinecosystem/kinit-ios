//
//  Analytics.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

struct Analytics {
    static var userId: String? {
        didSet {
            if let userId = userId {
                Amplitude.instance().setUserId(userId)
            }
        }
    }

    static var deviceId: String? {
        didSet {
            if let deviceId = deviceId {
                Amplitude.instance().setDeviceId(deviceId)
            }
        }
    }

    static func start(userId: String?, deviceId: String?) {
        #if DEBUG
            guard let key = Configuration.shared.amplitudeKeyDebug else {
                return
            }
        #else
            guard let key = Configuration.shared.amplitudeKeyProd else {
                return
            }
        #endif

        Amplitude.instance().initializeApiKey(key)
        self.userId = userId
        self.deviceId = deviceId

        if userId == nil {
            setUserProperty(Events.UserProperties.balance, with: 0)
            setUserProperty(Events.UserProperties.earnCount, with: 0)
            setUserProperty(Events.UserProperties.spendCount, with: 0)
            setUserProperty(Events.UserProperties.transactionCount, with: 0)
            setUserProperty(Events.UserProperties.totalKinEarned, with: 0)
            setUserProperty(Events.UserProperties.totalKinSpent, with: 0)
        }
    }

    static func setUserProperties(properties: [String: Any]) {
        Amplitude.instance().setUserProperties(properties)
    }

    static func setUserProperty(_ propertyName: String, with value: Any) {
        Amplitude.instance().setUserProperties([propertyName: value])
    }

    static func logEvents(_ events: BIEvent...) {
        events.forEach(logEvent)
    }

    static func logEvent(_ event: BIEvent) {
        Amplitude.instance().logEvent(event.name,
                                      withEventProperties: event.properties)
    }
}

extension Analytics {
    static var balance: UInt64 {
        get {
            fatalError("Don't call me, and I won't call you.")
        }

        set {
            setUserProperty(Events.UserProperties.balance, with: newValue)
        }
    }

    private static func increment(property: String, by amount: Int = 1) {
        let key = "Kin-UserProperty-\(property)"
        let count = UserDefaults.standard.integer(forKey: key) + amount
        setUserProperty(property, with: count)

        UserDefaults.standard.set(count, forKey: key)
    }

    static func incrementTransactionCount() {
        increment(property: Events.UserProperties.transactionCount)
    }

    static func incrementEarnCount() {
        increment(property: Events.UserProperties.earnCount)
    }

    static func incrementSpendCount() {
        increment(property: Events.UserProperties.spendCount)
    }

    static func incrementTotalEarned(by amount: Int) {
        increment(property: Events.UserProperties.totalKinEarned, by: amount)
    }

    static func incrementTotalSpent(by amount: Int) {
        increment(property: Events.UserProperties.totalKinSpent, by: amount)
    }
}
