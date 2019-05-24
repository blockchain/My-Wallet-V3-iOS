//
//  DateFormatter+Conveniences.swift
//  PlatformKit
//
//  Created by AlexM on 5/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension DateFormatter {
    public static let iso8601Format: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
}
