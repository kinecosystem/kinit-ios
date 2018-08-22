//
//  UIBarButtonItem.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    static var grayBarButtonItem: UIBarButtonItem {
        let buttonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        buttonItem.tintColor = UIColor.kin.darkGray

        return buttonItem
    }
}
