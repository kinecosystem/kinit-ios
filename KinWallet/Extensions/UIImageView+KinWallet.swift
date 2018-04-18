//
//  UIImageView+KinWallet.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

private var identifierKey = 0

extension UIImageView {
    func loadImage(url remoteURL: URL, placeholderColor: UIColor, size: CGSize? = nil) {
        let image = UIImage.from(placeholderColor, size: size ?? frame.size)
        loadImage(url: remoteURL, placeholderImage: image)
    }

    func loadImage(url remoteURL: URL, placeholderImage: UIImage? = nil) {
        if let placeholder = placeholderImage {
            image = placeholder
        }

        objc_setAssociatedObject(self, &identifierKey, remoteURL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        ResourceDownloader.shared.requestResource(url: remoteURL) { (url, origin, _) in
            DispatchQueue.main.async {
                guard let url = url else {
                    return
                }

                let identifier = objc_getAssociatedObject(self, &identifierKey) as? URL

                if remoteURL == identifier {
                    let applyImage = {
                        self.image = UIImage(contentsOfFile: url.path)
                    }

                    if origin == .remote {
                        UIView.transition(with: self,
                                          duration: 0.25,
                                          options: .transitionCrossDissolve,
                                          animations: applyImage,
                                          completion: nil)
                    } else {
                        applyImage()
                    }
                }
            }
        }
    }
}
