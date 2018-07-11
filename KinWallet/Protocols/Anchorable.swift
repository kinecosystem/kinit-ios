//
//  Anchorable.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

protocol Anchorable {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: Anchorable {}
extension UILayoutGuide: Anchorable {}
