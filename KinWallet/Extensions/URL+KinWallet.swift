//
//  URL+KinWallet.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

extension URL {
    func kinImagePathAdjustedForDevice() -> URL {
        var components = path.components(separatedBy: "/")

        guard var last = components.last, last.hasSuffix(".png") else {
            return self
        }

        var urlComponents = URLComponents()
        components.insert("ios", at: components.count - 1)
        components.removeLast()

        let toReplace = (UIScreen.main.scale > 2 ? "@3x.png" : "@2x.png")
        last = last.replacingOccurrences(of: ".png", with: toReplace)
        components.append(last)

        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = components.joined(separator: "/")

        return urlComponents.url ?? self
    }
}
