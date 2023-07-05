// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Decodable {

    public static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}
