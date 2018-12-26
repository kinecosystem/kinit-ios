//
//  UIImage+KinWallet.swift
//  Kinit
//

import UIKit

extension UIImage {
    class func from(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1), oval: Bool = false) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()

        if oval {
            UIGraphicsGetCurrentContext()?.fillEllipse(in: rect)
        } else {
            UIRectFill(rect)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func tinted(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!.resizableImage(withCapInsets: capInsets, resizingMode: resizingMode)
    }

    static func applyingBlackAndWhite(to sourceImage: UIImage) -> UIImage {
        return sourceImage.applyingBlackAndWhite()
    }

    func applyingBlackAndWhite() -> UIImage {
        guard
            let currentCGImage = cgImage,
            let filter = CIFilter(name: "CIColorMonochrome") else {
            return self
        }

        let currentCIImage = CIImage(cgImage: currentCGImage)

        filter.setValue(currentCIImage, forKey: "inputImage")
        filter.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
        filter.setValue(1.0, forKey: "inputIntensity")

        guard let outputImage = filter.outputImage else {
            return self
        }

        let context = CIContext()

        guard let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else {
            return self
        }

        return UIImage(cgImage: cgimg)
    }
}
