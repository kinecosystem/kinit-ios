//
//  UIImageView+KinWallet.swift
//  Kinit
//

import UIKit

private var identifierKey = 0
private var imagesCache = [String: UIImage]()

extension UIImageView {
    static func prepareKinImagesCache() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMemoryWarning),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
    }

    @objc static func didReceiveMemoryWarning() {
        imagesCache.removeAll()
    }

    func loadImage(url remoteURL: URL,
                   placeholderColor: UIColor,
                   size: CGSize? = nil,
                   transitionDuration: TimeInterval = 0.25,
                   useInMemoryCache: Bool = false,
                   applying transform: ((UIImage) -> UIImage)? = nil,
                   completion: ((UIImage) -> Void)? = nil) {
        let image = UIImage.from(placeholderColor, size: size ?? frame.size)
        loadImage(url: remoteURL,
                  placeholderImage: image,
                  transitionDuration: transitionDuration,
                  useInMemoryCache: useInMemoryCache,
                  applying: transform,
                  completion: completion)
    }

    func loadImage(url remoteURL: URL,
                   placeholderImage: UIImage? = nil,
                   transitionDuration: TimeInterval = 0.25,
                   useInMemoryCache: Bool = false,
                   applying transform: ((UIImage) -> UIImage)? = nil,
                   completion: ((UIImage) -> Void)? = nil) {
        if let placeholder = placeholderImage {
            image = placeholder
        }

        objc_setAssociatedObject(self, &identifierKey, remoteURL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let cacheIdentifier = remoteURL.absoluteString

        if useInMemoryCache, let cachedImage = imagesCache[cacheIdentifier] {
            self.setImage(cachedImage,
                          applying: transform,
                          transitionDuration: transitionDuration,
                          origin: .localCache,
                          completion: completion)
            return
        }

        ResourceDownloader.shared.requestResource(url: remoteURL) { (url, origin, _) in
            guard let url = url else {
                return
            }

            DispatchQueue.main.async {
                let identifier = objc_getAssociatedObject(self, &identifierKey) as? URL

                guard remoteURL == identifier,
                    let loadedImage = UIImage(contentsOfFile: url.path),
                    let origin = origin else {
                        return
                }

                if useInMemoryCache {
                    imagesCache[cacheIdentifier] = loadedImage
                }

                self.setImage(loadedImage,
                              applying: transform,
                              transitionDuration: transitionDuration,
                              origin: origin,
                              completion: completion)
            }
        }
    }

    private func setImage(_ image: UIImage,
                          applying transform: ((UIImage) -> UIImage)? = nil,
                          transitionDuration: TimeInterval = 0.25,
                          origin: ResourceOrigin,
                          completion: ((UIImage) -> Void)? = nil) {
        let imageToUse = transform?(image) ?? image
        let applyImage = {
            self.image = imageToUse
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

        completion?(imageToUse)
    }
}
