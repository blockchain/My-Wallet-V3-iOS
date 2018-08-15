//
//  Result.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The model you're expecting can be anything.
/// Some endpoints may not return an error, and
/// sometimes you may want to return a `error`
/// result but don't have an error to provide.
enum Result<A> {
    case success(A)
    case error(Error?)
}
