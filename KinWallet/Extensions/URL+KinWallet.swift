//
//  URL+KinWallet.swift
//  Kinit
//

import UIKit

extension URL {
    func kinImagePathAdjustedForDevice() -> URL {
        var components = path.components(separatedBy: "/")

        guard var last = components.last else {
            return self
        }

        let isPng = last.hasSuffix(".png")
        let isJpg = last.hasSuffix(".jpg")

        guard isPng || isJpg else {
            return self
        }

        var urlComponents = URLComponents()
        components.insert("ios", at: components.count - 1)
        components.removeLast()

        let newSuffix: String
        let fileExtension: String

        if isPng {
            newSuffix = (UIScreen.main.scale > 2 ? "@3x.png" : "@2x.png")
            fileExtension = ".png"
        } else {
            newSuffix = (UIScreen.main.scale > 2 ? "@3x.jpg" : "@2x.jpg")
            fileExtension = ".jpg"
        }

        last = last.replacingOccurrences(of: fileExtension, with: newSuffix)
        components.append(last)

        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = components.joined(separator: "/")

        return urlComponents.url ?? self
    }
}
