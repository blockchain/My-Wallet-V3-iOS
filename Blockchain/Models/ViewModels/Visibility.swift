//
//  Visibility.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

/// We used `Visibility` for hiding and showing
/// specific views. It's easier to read
enum Visibility: Int {
    case hidden
    case visible

    var defaultAlpha: CGFloat {
        return self == .visible ? 1 : 0
    }

    var isHidden: Bool {
        return self == .visible ? false: true
    }
}
