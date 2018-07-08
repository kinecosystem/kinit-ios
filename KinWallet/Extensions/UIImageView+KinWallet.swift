//
//  UIImageView+KinWallet.swift
//  Kinit
//

import UIKit

private var identifierKey = 0

extension UIImageView {
    func loadImage(url remoteURL: URL,
                   placeholderColor: UIColor,
                   size: CGSize? = nil,
                   transitionDuration: TimeInterval = 0.25,
                   completion: (() -> Void)? = nil) {
        let image = UIImage.from(placeholderColor, size: size ?? frame.size)
        loadImage(url: remoteURL,
                  placeholderImage: image,
                  transitionDuration: transitionDuration,
                  completion: completion)
    }

    func loadImage(url remoteURL: URL,
                   placeholderImage: UIImage? = nil,
                   transitionDuration: TimeInterval = 0.25,
                   completion: (() -> Void)? = nil) {
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
                        completion?()
                    }

                    if origin == .remote {
                        UIView.transition(with: self,
                                          duration: transitionDuration,
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
