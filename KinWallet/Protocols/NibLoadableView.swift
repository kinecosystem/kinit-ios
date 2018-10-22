//
//  NibLoadableView.swift
//  Kinit
//

import UIKit

protocol NibLoadableView: class {
    static func loadFromNib(from bundle: Bundle) -> Self
}

extension NibLoadableView where Self: UIView {
    static func loadFromNib(from bundle: Bundle = .main) -> Self {
        let nib = bundle.loadNibNamed(nibName, owner: nil, options: nil)
        guard let view = nib?.first as? Self else {
            fatalError("NibLoadableView \(nibName) doesn't have a view from the expected type.")
        }

        return view
    }

    static var nibName: String {
        return String(describing: self)
    }
}
