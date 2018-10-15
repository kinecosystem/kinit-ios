//
//  RootTabBarController.swift
//  Kinit
//

import UIKit

class RootTabBarController: UITabBarController {
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        tabBar.items?[0].image = Asset.tabBarEarn.image
        tabBar.items?[1].image = Asset.tabBarSpend.image
        tabBar.items?[2].image = Asset.tabBarBalance.image
        tabBar.items?[3].image = Asset.tabBarMore.image

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(remoteConfigUpdated),
                                               name: .RemoteConfigUpdated,
                                               object: nil)
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if
            let itemTitle = item.title,
            let menuItemName = Events.MenuItemName(rawValue: itemTitle) {
            Events.Analytics
                .ClickMenuItem(menuItemName: menuItemName)
                .send()
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    @objc func remoteConfigUpdated() {
        guard let config = RemoteConfig.current,
            config.isUpdateAvailable == true,
            config.forceUpdate == true else {
            return
        }

        if AppDelegate.shared.rootViewController.isShowingSplashScreen {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.remoteConfigUpdated()
            }
            return
        }

        let action = KinAlertAction(title: L10n.UpdateAlert.action, handler: UIApplication.update)

        KinAlertController(title: L10n.UpdateAlert.title,
                           titleImage: Asset.updateAvailableHeaderImage.image,
                           message: L10n.UpdateAlert.message,
                           primaryAction: action,
                           secondaryAction: nil)
            .showInNewWindow()
    }
}
