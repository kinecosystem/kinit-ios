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
                   applying imageTransform: ((UIImage) -> UIImage)? = nil,
                   completion: ((UIImage) -> Void)? = nil) {
        let image = UIImage.from(placeholderColor, size: size ?? frame.size)
        loadImage(url: remoteURL,
                  placeholderImage: image,
                  transitionDuration: transitionDuration,
                  completion: completion)
    }

    func loadImage(url remoteURL: URL,
                   placeholderImage: UIImage? = nil,
                   transitionDuration: TimeInterval = 0.25,
                   applying imageTransform: ((UIImage) -> UIImage)? = nil,
                   completion: ((UIImage) -> Void)? = nil) {
        if let placeholder = placeholderImage {
            image = placeholder
        }

        objc_setAssociatedObject(self, &identifierKey, remoteURL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        ResourceDownloader.shared.requestResource(url: remoteURL) { (url, origin, _) in
            guard let url = url else {
                return
            }

            DispatchQueue.main.async {
                let identifier = objc_getAssociatedObject(self, &identifierKey) as? URL

                guard remoteURL == identifier else {
                    return
                }

                let applyImage = {
                    if let image = UIImage(contentsOfFile: url.path) {
                        let imageToUse = imageTransform?(image) ?? image
                        self.image = imageToUse
                        completion?(imageToUse)
                    }
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
