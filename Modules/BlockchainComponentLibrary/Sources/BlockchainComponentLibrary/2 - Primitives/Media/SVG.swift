// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Darwin
import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

@objc
private class CGSVGDocument: NSObject {}

// private var CGSVGDocumentRetain: (@convention(c) (CGSVGDocument?) -> Unmanaged<CGSVGDocument>?) = load("CGSVGDocumentRetain")
private var CGSVGDocumentRetain: (@convention(c) (CGSVGDocument?) -> Unmanaged<CGSVGDocument>?) = load("==gbpFGdlJFduVWb1N2bEdkVTd0Q".deobfuscated)

// private var CGSVGDocumentRelease: (@convention(c) (CGSVGDocument?) -> Void) = load("CGSVGDocumentRelease")
private var CGSVGDocumentRelease: (@convention(c) (CGSVGDocument?) -> Void) = load("=U2chVGblJFduVWb1N2bEdkVTd0Q".deobfuscated)

// private var CGSVGDocumentCreateFromData: (@convention(c) (CFData?, CFDictionary?) -> Unmanaged<CGSVGDocument>?) = load("CGSVGDocumentCreateFromData")
private var CGSVGDocumentCreateFromData: (@convention(c) (CFData?, CFDictionary?) -> Unmanaged<CGSVGDocument>?) = load("hRXYE12byZUZ0FWZyNEduVWb1N2bEdkVTd0Q".deobfuscated)

// private var CGSVGDocumentWriteToData: (@convention(c) (CGSVGDocument?, CFData?, CFDictionary?) -> Void) = load("CGSVGDocumentWriteToData")
private var CGSVGDocumentWriteToData: (@convention(c) (CGSVGDocument?, CFData?, CFDictionary?) -> Void) = load("hRXYE9GVlRXaydFduVWb1N2bEdkVTd0Q".deobfuscated)

// private var CGContextDrawSVGDocument: (@convention(c) (CGContext?, CGSVGDocument?) -> Void) = load("CGContextDrawSVGDocument")
private var CGContextDrawSVGDocument: (@convention(c) (CGContext?, CGSVGDocument?) -> Void) = load("05WZtV3YvR0RWN1dhJHR0hXZ052bDd0Q".deobfuscated)

// private var CGSVGDocumentGetCanvasSize: (@convention(c) (CGSVGDocument?) -> CGSize) = load("CGSVGDocumentGetCanvasSize")
private var CGSVGDocumentGetCanvasSize: (@convention(c) (CGSVGDocument?) -> CGSize) = load("=UmepN1chZnbhNEdldEduVWb1N2bEdkVTd0Q".deobfuscated)

#if canImport(UIKit)
// private typealias ImageWithCGSVGDocument = @convention(c) (AnyObject, Selector, CGSVGDocument) -> UIImage
private typealias ImageWithCGSVGDocument = @convention(c) (AnyObject, Selector, CGSVGDocument) -> UIImage
#endif

// private var ImageWithCGSVGDocumentSEL: Selector = NSSelectorFromString("_imageWithCGSVGDocument:")
private var ImageWithCGSVGDocumentSEL: Selector = NSSelectorFromString("6Qnbl1Wdj9GRHZ1UHNEa0l2VldWYtl2X".deobfuscated)

// private let CoreSVG = dlopen("/System/Library/PrivateFrameworks/CoreSVG.framework/CoreSVG", RTLD_NOW)
private let CoreSVG = dlopen("=ckVTVmcvN0LrJ3b3VWbhJnZuckVTVmcvN0LztmcvdXZtFmcGVGdhZXayB1L5JXYyJWaM9SblR3c5N1L".deobfuscated, RTLD_NOW)

private func load<T>(_ name: String) -> T { unsafeBitCast(dlsym(CoreSVG, name), to: T.self) }

public final class SVG: Codable {

    deinit { CGSVGDocumentRelease(document) }

    fileprivate let document: CGSVGDocument
    fileprivate let string: String

    public convenience init(_ value: StaticString) {
        self.init(
            value.hasPointerRepresentation
                ? value.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
                : .init(value.unicodeScalar)
        )!
    }

    public convenience init?(_ value: String) {
        self.init(Data(value.utf8))
    }

    public init?(_ data: Data) {
        guard let document = CGSVGDocumentCreateFromData(data as CFData, nil)?.takeUnretainedValue() else { return nil }
        guard CGSVGDocumentGetCanvasSize(document) != .zero else { return nil }
        self.document = document
        self.string = String(decoding: data, as: UTF8.self)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let svg = try Self(Data(container.decode(String.self).utf8)) else {
            throw DecodingError.valueNotFound(String.self, .init(codingPath: decoder.codingPath, debugDescription: "SVG expected String"))
        }
        self.document = svg.document
        self.string = svg.string
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }

    #if canImport(UIKit)
    public var image: UIImage {
        let ImageWithCGSVGDocument = unsafeBitCast(UIImage.method(for: ImageWithCGSVGDocumentSEL), to: ImageWithCGSVGDocument.self)
        let image = ImageWithCGSVGDocument(UIImage.self, ImageWithCGSVGDocumentSEL, document)
        return image
    }
    #else
    public var image: NSImage {
        // private let CGSVGImageRepClass = NSClassFromString("_NSSVGImageRep")
        // private let CGSVGImageRepDocumentIvar = class_getInstanceVariable(CGSVGImageRepClass, "_document")
        fatalError(#function + " is unsupported on macOS")
    }
    #endif

    public var size: CGSize {
        CGSVGDocumentGetCanvasSize(document)
    }

    public func draw(in context: CGContext) {
        draw(in: context, size: size)
    }

    public func draw(in context: CGContext, size target: CGSize, maskedTo maskColor: Color? = nil) {

        var target = target

        let ratio = (
            x: target.width / size.width,
            y: target.height / size.height
        )

        let rect = (
            document: CGRect(origin: .zero, size: size), ()
        )

        let scale: (x: CGFloat, y: CGFloat)

        if target.width <= 0 {
            scale = (ratio.y, ratio.y)
            target.width = size.width * scale.x
        } else if target.height <= 0 {
            scale = (ratio.x, ratio.x)
            target.width = size.width * scale.y
        } else {
            let min = min(ratio.x, ratio.y)
            scale = (min, min)
            target.width = size.width * scale.x
            target.height = size.height * scale.y
        }

        let transform = (
            scale: CGAffineTransform(scaleX: scale.x, y: scale.y),
            aspect: CGAffineTransform(translationX: (target.width / scale.x - rect.document.width) / 2, y: (target.height / scale.y - rect.document.height) / 2)
        )

        #if canImport(UIKit) || os(watchOS)
        context.translateBy(x: 0, y: target.height)
        context.scaleBy(x: 1, y: -1)
        #endif
        context.concatenate(transform.scale)
        context.concatenate(transform.aspect)

        CGContextDrawSVGDocument(context, document)

        if let maskColor = maskColor?.cgColor {
            context.saveGState()
            context.setBlendMode(.sourceAtop)
            context.setFillColor(maskColor)
            context.fill(CGRect(origin: .zero, size: target))
            context.restoreGState()
        }
    }
}

extension SVG: OptionalDataInit {

    public convenience init?(_ data: Data?) {
        guard let data else { return nil }
        self.init(data)
    }
}

extension SVG: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        "SVG(size: \(size))"
    }

    public var debugDescription: String {
        string
    }
}

extension SVG {

    public static let none = SVG(
        """
        <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200">
        <path fill="none" stroke="#999" stroke-width="2" d="M1,1V199H199V1z"/>
        </svg>
        """
    )!
}

#if canImport(UIKit)
extension SVG: UIViewRepresentable {

    public final class View: UIView {

        var svg: SVG

        public init(_ svg: SVG) {
            self.svg = svg
            super.init(frame: .init(origin: .zero, size: svg.size))
            isOpaque = false
        }

        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override public func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            svg.draw(in: context, size: rect.size)
        }
    }

    public var view: View { View(self) }

    public func makeUIView(context: Context) -> View {
        View(self)
    }

    public func updateUIView(_ view: UIViewType, context: Context) {
        view.setNeedsDisplay()
    }
}
#else

extension SVG: NSViewRepresentable {

    public final class View: NSView {
        var svg: SVG
        public init(_ svg: SVG) {
            self.svg = svg
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override public func draw(_ rect: CGRect) {
            guard let context = NSGraphicsContext.current?.cgContext else { return }
            svg.draw(in: context, size: rect.size)
        }
    }

    public var view: View { View(self) }

    public func makeNSView(context: Context) -> some NSView {
        View(self)
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.setNeedsDisplay(nsView.bounds)
    }
}
#endif

extension String {
    fileprivate var deobfuscated: String { Data(base64Encoded: String(reversed()))!.string }
}

extension Data {
    fileprivate var string: String { String(decoding: self, as: UTF8.self) }
}
