// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MoneyKit
import XCTest

final class FileLoaderTests: XCTestCase {

    var fileProviderMock: FilePathProviderMock!
    var sut: FileLoaderAPI!

    override func setUp() {
        super.setUp()
        fileProviderMock = FilePathProviderMock()
        sut = FileLoader(filePathProvider: fileProviderMock, jsonDecoder: .init())
    }

    override func tearDown() {
        super.tearDown()
        fileProviderMock = nil
        sut = nil
    }

    func testDecodesFromFirstFile() {
        fileProviderMock.underlyingURLs = [
            .init(fileName: Constants.firstTryFileName.rawValue, origin: .documentsDirectory): createValidFile()
        ]
        XCTAssertNoThrow(try getValue.get())
    }

    func testDecodesFromSecondFileIfFirstMissing() {
        fileProviderMock.underlyingURLs = [
            .init(fileName: Constants.secondTryFileName.rawValue, origin: .bundle): createValidFile()
        ]
        XCTAssertNoThrow(try getValue.get())
    }

    func testDecodesFromSecondFileIfFirstMalformed() {
        fileProviderMock.underlyingURLs = [
            .init(fileName: Constants.firstTryFileName.rawValue, origin: .bundle): createEmptyFile(),
            .init(fileName: Constants.secondTryFileName.rawValue, origin: .bundle): createValidFile()
        ]
        XCTAssertNoThrow(try getValue.get())
    }

    func testThrowsIfFirstMalformedAndSecondIsMalformed() {
        fileProviderMock.underlyingURLs = [
            .init(fileName: Constants.firstTryFileName.rawValue, origin: .bundle): createEmptyFile(),
            .init(fileName: Constants.secondTryFileName.rawValue, origin: .bundle): createEmptyFile()
        ]
        XCTAssertThrowsError(try getValue.get())
    }

    func testThrowsIfFirstMissingAndSecondIsMalformed() {
        fileProviderMock.underlyingURLs = [
            .init(fileName: Constants.secondTryFileName.rawValue, origin: .bundle): createEmptyFile()
        ]
        XCTAssertThrowsError(try getValue.get())
    }

    func testThrowsIfFirstAndSecondAreMissing() {
        XCTAssertThrowsError(try getValue.get())
    }

    private enum Constants {
        static let firstTryFileName: FileName = .remoteCustodial
        static let firstTryOrigin: FileOrigin = .bundle
        static let secondTryFileName: FileName = .localCustodial
        static let secondTryOrigin: FileOrigin = .documentsDirectory
    }

    private var getValue: Result<TestClass, FileLoaderError> {
        sut.load(fileName: Constants.firstTryFileName, fallBack: Constants.secondTryFileName, as: TestClass.self)
    }

    private struct TestClass: Decodable {
        let testProperty: String
    }

    private func createValidFile() -> URL {
        let dirPath = NSTemporaryDirectory()
        let uuid = UUID().uuidString
        let filePath = "\(dirPath)/\(uuid).json"
        FileManager.default.createFile(
            atPath: filePath,
            contents: "{\"testProperty\":\"value\"}".data(using: .utf8)
        )
        return URL(fileURLWithPath: filePath)
    }

    private func createEmptyFile() -> URL {
        let dirPath = NSTemporaryDirectory()
        let uuid = UUID().uuidString
        let filePath = "\(dirPath)/\(uuid).json"
        FileManager.default.createFile(
            atPath: filePath,
            contents: "".data(using: .utf8)
        )
        return URL(string: filePath)!
    }
}
