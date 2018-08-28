//
//  NSAttributedString+Conveniences.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

@objc public extension NSMutableAttributedString {

    /// Sets the foreground color of the substring `text` to the provided `color`
    /// if `text` is within this attributed string's range.
    ///
    /// - Parameters:
    ///   - color: the foreground color to set
    ///   - text: the text to set a foreground color to
    public func addForegroundColor(_ color: UIColor, to text: String) {
        guard let range = string.range(of: text) else {
            Logger.shared.info("Cannot add color to attributed string. Text is not in range.")
            return
        }
        addAttribute(
            NSAttributedStringKey.foregroundColor,
            value: color,
            range: NSRange(range, in: string)
        )
    }
}

public extension NSAttributedString {

    var height: CGFloat {
        return heightForWidth(width: CGFloat.greatestFiniteMagnitude)
    }

    var width: CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let rect = boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.width)
    }

    public func boundingRectForWidth(_ width: CGFloat) -> CGRect {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesDeviceMetrics], context: .none)
    }

    public func fontAttribute() -> UIFont? {
        guard length > 0 else { return nil }
        guard let font = attribute(NSAttributedStringKey.font, at: 0, effectiveRange: nil) as? UIFont else { return nil }
        return font
    }

    public func heightForWidth(width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: width == CGFloat.greatestFiniteMagnitude ? 0 : CGFloat.greatestFiniteMagnitude)
        let rect = boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.height)
    }

    public func withFont(_ font: UIFont) -> NSAttributedString {
        if fontAttribute() == .none {
            let copy = NSMutableAttributedString(attributedString: self)
            copy.addAttribute(NSAttributedStringKey.font, value: font, range: NSMakeRange(0, copy.length))
            return copy
        }
        return copy() as! NSAttributedString
    }
}
