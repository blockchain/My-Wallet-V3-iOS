//
//  HttpMethod.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Alamofire
import Foundation

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}
