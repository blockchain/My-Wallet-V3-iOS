//
//  QRCode.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 12/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import UIKit

/// Generated a `QRCode` by passing in `CryptoAssetQRMetadata` and then
/// accessing the `.image` property.
public struct QRCode {
    
    private let data: Data
    
    public init?(metadata: CryptoAssetQRMetadata) {
        // TODO:
        // * Decide what to do about this (address vs url)
        // * Add tests
        if let value = metadata.address.data(using: .utf8) {
            self.data = value
        } else {
            return nil
        }
    }
    
    public var image: UIImage? {
        guard let coreImage = ciImage else { return nil }
        return coreImage.nonInterpolatedImage(with: UIScreen.main.scale)
    }
    
    private var ciImage: CIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        return filter.outputImage
    }
}

fileprivate extension CIImage {
    
    func nonInterpolatedImage(with scale: CGFloat) -> UIImage? {
        guard let image = CIContext(options: nil).createCGImage(self, from: extent) else { return nil }
        let size = CGSize(width: extent.size.width * scale, height: extent.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .none
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(image, in: context.boundingBoxOfClipPath)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
}
