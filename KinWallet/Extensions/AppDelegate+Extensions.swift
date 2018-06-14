//
//  AppDelegate+Extensions.swift
//  Kinit
//

import UIKit

extension AppDelegate {
    class var shared: AppDelegate {
        //swiftlint:disable:next force_cast
        return UIApplication.shared.delegate as! AppDelegate
    }

    func applyAppearance() {
        let tintColor = UIColor.kin.appTint
        window?.tintColor = tintColor

        UINavigationBar.appearance().setBackgroundImage(navigationBarGradientImage(), for: .default)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .white

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [WhiteNavigationBar.self]).tintColor = tintColor
        WhiteNavigationBar.appearance().setBackgroundImage(nil, for: .default)

        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white,
                                                            .font: FontFamily.Roboto.regular.font(size: 16)]
    }

    private func navigationBarGradientImage() -> UIImage {
        let gradientView = GradientView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        gradientView.direction = .horizontal
        gradientView.colors = UIColor.navigationBarGradientColors

        return gradientView.drawAsImage()
            .resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    }

    func requestNotifications(with completion: ((Bool) -> Void)? = nil) {
        notificationHandler?.requestNotificationPermissions { granted in
            Analytics.setUserProperty(Events.UserProperties.pushEnabled, with: granted)
            completion?(granted)
        }
    }
}

extension AppDelegate: WebServiceProvider {
    func userId() -> String? {
        return User.current?.userId
    }

    func deviceId() -> String? {
        return User.current?.deviceId
    }

    func appVersion() -> String? {
        return Bundle.appVersion
    }
}

class WhiteNavigationBar: UINavigationBar { }
