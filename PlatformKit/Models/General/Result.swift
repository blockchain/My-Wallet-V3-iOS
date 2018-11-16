//
//  Result.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The model you're expecting can be anything.
/// Some endpoints may not return an error, and
/// sometimes you may want to return a `error`
/// result but don't have an error to provide.
public enum Result<A> {
    case success(A)
    case error(Error?)
}
