// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftExtensions
import XCTest

final class DictionaryTests: XCTestCase {

    func test_deepMap() throws {

        let input: [String: Any] = [
            "a": 0,
            "b": [
                "a": 1
            ],
            "c": [
                [
                    "a": 2
                ],
                "b"
            ] as [Any]
        ]

        let expected: [String: Any] = [
            "a": 1,
            "b": [
                "a": 2
            ],
            "c": [
                [
                    "a": 3
                ],
                "b"
            ] as [Any]
        ]

        let actual = input.deepMap(.mappingOverArrays) { key, value in
            if let i = value as? Int {
                return (key, i + 1)
            } else {
                return (key, value)
            }
        }

        let x = try JSONSerialization.data(withJSONObject: expected, options: .sortedKeys)
        let y = try JSONSerialization.data(withJSONObject: actual, options: .sortedKeys)

        XCTAssertEqual(x, y)
    }
}
