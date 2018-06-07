//
//  String+EscapeJS.swift
//  Blockchain
//
//  Created by Maurice A. on 5/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension String {
    func escapedForJS(wrapInQuotes: Bool = false) -> String {
        var output = self
        let insensitive = NSString.CompareOptions.caseInsensitive
        output = output
            .replacingOccurrences(of: "\\", with: "\\\\", options: insensitive)    // Reverse solidus
            .replacingOccurrences(of: "\"", with: "\\\"", options: insensitive)    // Quotation mark
            .replacingOccurrences(of: "'", with: "\\'", options: insensitive)      // Single quote
            .replacingOccurrences(of: "\u{8}", with: "\\b", options: insensitive)  // Backspace
            .replacingOccurrences(of: "\u{12}", with: "\\f", options: insensitive) // Formfeed
            .replacingOccurrences(of: "\n", with: "\\n", options: insensitive)     // Newline
            .replacingOccurrences(of: "\r", with: "\\r", options: insensitive)     // Carriage return
            .replacingOccurrences(of: "\t", with: "\\t", options: insensitive)     // Horizontal tab
        return wrapInQuotes ? "\"\(output)\"" : output
    }
}

@objc extension NSString {
    func escapedForJS() -> String {
        return (self as String).escapedForJS()
    }
}
