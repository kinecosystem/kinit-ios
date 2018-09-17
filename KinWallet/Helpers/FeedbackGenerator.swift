//
//  FeedbackGenerator.swift
//  Kinit
//

import UIKit

class FeedbackGenerator {
    class func notifySuccessIfAvailable() {
        if #available(iOS 10.0, *) {
            notify(.success)
        }
    }

    class func notifyWarningIfAvailable() {
        if #available(iOS 10.0, *) {
            notify(.warning)
        }
    }

    class func notifyErrorIfAvailable() {
        if #available(iOS 10.0, *) {
            notify(.error)
        }
    }

    @available(iOS 10.0, *)
    private class func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.notificationOccurred(type)
    }

    @available(iOS 10.0, *)
    class func notifySelectionChanged() {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
    }
}

