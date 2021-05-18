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

public protocol QRCodeAPI {
    var image: UIImage? { get }
    init?(string: String)
    init(data: Data)
}

extension QRCodeAPI {
    public init?(metadata: CryptoAssetQRMetadata) {
        self.init(string: metadata.absoluteString)
    }

    public init?(string: String) {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        self.init(data: data)
    }
}

/// Generates a `QRCode` image from a given String or Data object.
public struct QRCode: QRCodeAPI {

    private let data: Data

    public init(data: Data) {
        self.data = data
    }

    public var image: UIImage? {
        guard let ciImage = ciImage else { return nil }
        let scaleXY = UIScreen.main.bounds.width / ciImage.extent.size.width
        let scale = CGAffineTransform(scaleX: scaleXY, y: scaleXY)
        return UIImage(ciImage: ciImage.transformed(by: scale))
    }

    private var ciImage: CIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setDefaults()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        return filter.outputImage
    }
}
