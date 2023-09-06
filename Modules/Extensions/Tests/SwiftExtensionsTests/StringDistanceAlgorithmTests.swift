import SwiftExtensions
import XCTest

final class StringDistanceAlgorithmTests: XCTestCase {

    func test_distance_JaroWinkler() {
        let algorithm = JaroWinklerAlgorithm(caseInsensitive: false)

        XCTAssertEqual("".distance(between: "", using: algorithm), 0)
        XCTAssertEqual("".distance(between: "Dorothy", using: algorithm), 1)
        XCTAssertEqual("search".distance(between: "find", using: algorithm), 1)
        XCTAssertEqual("search".distance(between: "search", using: algorithm), 0)

        XCTAssertEqual("MARTHA".distance(between: "MARHTA", using: algorithm), 0.079, accuracy: 0.01)
        XCTAssertEqual("DWAYNE".distance(between: "DUANE", using: algorithm), 0.19, accuracy: 0.01)
        XCTAssertEqual("DIXON".distance(between: "DICKSONX", using: algorithm), 0.286, accuracy: 0.01)
        XCTAssertEqual("YBS".distance(between: "Yorkshire Building Society", using: algorithm), 0.46, accuracy: 0.01)

        XCTAssertEqual("kitten".distance(between: "sitting", using: algorithm), 0.254, accuracy: 0.01)
        XCTAssertEqual("君子和而不同".distance(between: "小人同而不和", using: algorithm), 0.445, accuracy: 0.01)

        XCTAssertEqual("0x".distance(between: "0xdeadbeef", using: algorithm), 0.32, accuracy: 0.01)
        XCTAssertEqual("0xdeadbeef".distance(between: "0x", using: algorithm), 0.32, accuracy: 0.01)
    }

    func test_distance_Fuzzy() {
        let algorithm = FuzzyAlgorithm(caseInsensitive: false)

        XCTAssertEqual("".distance(between: "", using: algorithm), 0)
        XCTAssertEqual("".distance(between: "Dorothy", using: algorithm), 1)
        XCTAssertEqual("search".distance(between: "find", using: algorithm), 1)
        XCTAssertEqual("search".distance(between: "search", using: algorithm), 0)

        XCTAssertEqual("MRT".distance(between: "MARHTA", using: algorithm), 0.1)
        XCTAssertEqual("DXAUNE".distance(between: "DWAYNE", using: algorithm), 1)
        XCTAssertEqual("YBS".distance(between: "Yorkshire Building Society", using: algorithm), 0.1)

        XCTAssertEqual("君子和而不同".distance(between: "小人同而不和", using: algorithm), 1)

        XCTAssertEqual("0x".distance(between: "0xdeadbeef", using: algorithm), 0.1)
        XCTAssertEqual("0xdeadbeef".distance(between: "0x", using: algorithm), 0)
    }

    func test_distance_Contains() {
        let algorithm = StringContainsAlgorithm(caseInsensitive: false)

        XCTAssertEqual("".distance(between: "", using: algorithm), 0)
        XCTAssertEqual("".distance(between: "Dorothy", using: algorithm), 1)
        XCTAssertEqual("search".distance(between: "find", using: algorithm), 1)
        XCTAssertEqual("sear".distance(between: "search", using: algorithm), 0)

        XCTAssertEqual("MRT".distance(between: "MARHTA", using: algorithm), 1)
        XCTAssertEqual("DXAUNE".distance(between: "DWAYNE", using: algorithm), 1)
        XCTAssertEqual("YBS".distance(between: "Yorkshire Building Society", using: algorithm), 1)

        XCTAssertEqual("君子和而不同".distance(between: "小人同而不和", using: algorithm), 1)

        XCTAssertEqual("0x".distance(between: "0xdeadbeef", using: algorithm), 0)
        XCTAssertEqual("0xdeadbeef".distance(between: "0x", using: algorithm), 0)
    }
}
