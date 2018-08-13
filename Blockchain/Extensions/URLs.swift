//
//  URLs.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension URL {

    /// Returns the query arguments of this URL as a key-value pair
    var queryArgs: [String: String] {
        guard let query = self.query else {
            return [:]
        }

        return query.queryArgs
    }

    /// Attempts to launch this URL
    func launch() {
        UIApplication.shared.open(self, options: [:])
    }

    public static func endpoint(_ baseURL: URL, pathComponents: [String]?, queryParameters: [String: String]?) -> URL? {
        guard var mutableBaseURL: URL = (baseURL as NSURL).copy() as? URL else { return nil }

        if let pathComponents = pathComponents {
            for compenent in pathComponents {
                if compenent != pathComponents.last {
                    mutableBaseURL = mutableBaseURL.appendingPathComponent(compenent, isDirectory: true)
                } else {
                    mutableBaseURL = mutableBaseURL.appendingPathComponent(compenent, isDirectory: false)
                }
            }
        }

        var queryItems = [URLQueryItem]()

        if let queryParameters = queryParameters {
            if queryParameters.keys.count == 0 {
                return mutableBaseURL
            }

            for keyValue in queryParameters.keys {
                if let value = queryParameters[keyValue] {
                    let queryItem = URLQueryItem(name: keyValue, value: value)
                    queryItems.append(queryItem)
                }
            }
        }

        guard var components: URLComponents = URLComponents(url: mutableBaseURL as URL, resolvingAgainstBaseURL: false) else { return nil }

        components.queryItems = queryItems

        return components.url
    }
}
