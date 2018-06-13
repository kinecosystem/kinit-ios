//
//  RootTabBarController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {
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

    override var shouldAutorotate: Bool {
        return false
    }
}
