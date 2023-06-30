// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(UIKit)
import Foundation
import UIKit

extension UISheetPresentationController {
    public func performDetentInvalidation() {
        if #available(iOS 16, *) {
            invalidateDetents()
        } else {
            let context = NSSelectorFromString("zRnblRXZEVGdhRWasFmdul2X".deobfuscated)
            if responds(to: context) {
                perform(context)
            }
        }
    }
}

extension UISheetPresentationController.Detent {
    public class func heightWithContext(
        context: @escaping @convention(block) (NSObjectProtocol) -> CGFloat
    ) -> UISheetPresentationController.Detent {
        heightWithContext(id: nil, context: context)
    }

    public class func heightWithContext(
        id: String?,
        context: @escaping @convention(block) (NSObjectProtocol) -> CGFloat
    ) -> UISheetPresentationController.Detent {
        if #available(iOS 16, *) {
            if let id {
                return .custom(identifier: .init(id), resolver: { context($0) })
            } else {
                return .custom(resolver: { context($0) })
            }
        } else {
            let detentContext = NSSelectorFromString("6s2YvxmQ0hXZ052bD52bpRXds92clJnOyVWamlGduVGZJhGdpdFduVGdlR2X".deobfuscated)
            guard Self.responds(to: detentContext) else {
                return .large()
            }
            let detent = Self.perform(detentContext, with: id, with: context).takeUnretainedValue()
            guard let detent = detent as? UISheetPresentationController.Detent else {
                return .large()
            }
            return detent
        }
    }
}

// MARK: Private

extension String {
    fileprivate var deobfuscated: String { Data(base64Encoded: String(reversed()))!.string }
}

extension Data {
    fileprivate var string: String { String(decoding: self, as: UTF8.self) }
}
#endif
