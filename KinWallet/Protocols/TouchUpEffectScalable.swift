//
//  TouchUpEffectScalable.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

protocol TouchUpEffectScalable: class {
    func beginTouchUpEffect(with scale: CGFloat, completion: ((Bool) -> Void)?)
    func endTouchUpEffect(_ completion: ((Bool) -> Void)?)
}

extension UIView: TouchUpEffectScalable {
    func beginTouchUpEffect(with scale: CGFloat = 0.9, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform.init(scaleX: scale, y: scale)
        }, completion: completion)
    }

    func endTouchUpEffect(_ completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = .identity
        }, completion: completion)
    }
}
