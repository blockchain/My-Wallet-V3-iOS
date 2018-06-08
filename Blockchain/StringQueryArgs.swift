//
//  StringQueryArgs.swift
//  Blockchain
//
//  Created by kevinwu on 6/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension String {

    /// Returns query arguments from a string in URL format
    var queryArgs: [String: String] {
        var queryArgs = [String: String]()
        let components = self.components(separatedBy: "&")
        components.forEach {
            let paramValueArray = $0.components(separatedBy: "=")

            if paramValueArray.count == 2,
                let param = paramValueArray[0].removingPercentEncoding,
                let value = paramValueArray[1].removingPercentEncoding {
                queryArgs[param] = value
            }
        }

        return queryArgs
    }
}
