//
//  FeedbackGenerator.swift
//  Kinit
//

import UIKit

class FeedbackGenerator {
    class func notifySuccessIfAvailable() {
        notifyIfAvailable(.success)
    }

    class func notifyWarningIfAvailable() {
        notifyIfAvailable(.warning)
    }

    class func notifyErrorIfAvailable() {
        notifyIfAvailable(.error)
    }

    private class func notifyIfAvailable(_ type: UINotificationFeedbackType) {
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.notificationOccurred(type)
        }
    }

    class func notifySelectionChangedIfAvailable() {
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
        }
    }
}
