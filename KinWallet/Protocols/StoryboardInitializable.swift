//
//  StoryboardInitializable.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

protocol AutoCases {}

protocol StoryboardInitializable where Self: UIViewController {
    static func instantiateFromStoryboard() -> Self
}
