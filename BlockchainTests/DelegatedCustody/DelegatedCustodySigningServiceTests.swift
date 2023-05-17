// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainApp
import Combine
import DelegatedSelfCustodyDomain
import XCTest

final class DelegatedCustodySigningServiceTests: XCTestCase {

    var subject: DelegatedCustodySigningService!

    override func setUp() {
        subject = DelegatedCustodySigningService()
        super.setUp()
    }

    func testSecp256k1Derivation1() throws {
        try runTestSecp256k1Derivation(
            data: "fd09c5d898ca107a3cbc535065c66345d929e34a77beb687e8caf4a7a3683098",
            privateKey: "0d371300cd074054ef8248f5640a6dcbe60bdd1fad900be94e0d62fd9168caae",
            expectedResult: "bae592f9d4bcd845e8929cb753478f00350381dfd0cffa27876ed812564a8cc142ba9afa2f631b757eed4580948650c5fbd16644f294ba9b664fd1d646b3993800"
        )
    }

    func testSecp256k1Derivation2() throws {
        try runTestSecp256k1Derivation(
            data: "fd09c5d898ca107a3cbc535065c66345d929e34a77beb687e8caf4a7a3683098",
            privateKey: "320dc1afd9ffa43b98a541e58f0d464a1d0983921eb8878cab975f3aadc02653",
            expectedResult: "79dd15512c741ef7de052587e08d62b3603de6e928e8f3df47145d8f1404880a39d3dd9ee4ebbc84e0e946c0d1b4f3d340570101a98b7f8990addcca73ae96ac00"
        )
    }

    func runTestSecp256k1Derivation(
        data: String,
        privateKey: String,
        expectedResult: String
    ) throws {
        let data = Data(hex: data)
        let privateKey = Data(hex: privateKey)
        let signed = subject.sign(
            data: data,
            privateKey: privateKey,
            algorithm: .secp256k1
        )
        let result = try signed.get()
        XCTAssertEqual(result.hex, expectedResult)
    }
}
