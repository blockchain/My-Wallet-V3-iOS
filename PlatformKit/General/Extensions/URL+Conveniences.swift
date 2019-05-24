//
//  URL+Conveniences.swift
//  PlatformKit
//
//  Created by AlexM on 5/17/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension URL {
    
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
