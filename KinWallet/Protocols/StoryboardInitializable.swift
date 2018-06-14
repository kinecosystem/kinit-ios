//
//  StoryboardInitializable.swift
//  Kinit
//

import UIKit

protocol AutoCases {}

protocol StoryboardInitializable where Self: UIViewController {
    static func instantiateFromStoryboard() -> Self
}
