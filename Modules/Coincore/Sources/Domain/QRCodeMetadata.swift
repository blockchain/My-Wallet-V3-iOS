// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A simple object describing a QR Code.
public struct QRCodeMetadata {

    /// The content to be encoded in the QR Code.
    public let content: String
    /// The title of the QR code.
    public let title: String

    public init(content: String, title: String) {
        self.content = content
        self.title = title
    }
}
