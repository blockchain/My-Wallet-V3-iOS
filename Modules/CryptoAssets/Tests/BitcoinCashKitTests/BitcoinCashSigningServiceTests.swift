// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinCashKit
@testable import BitcoinChainKit
import MoneyKit
import WalletCore
import XCTest

final class BchSigningServiceTests: XCTestCase {

    var subject: BchSigningServiceAPI!

    override func setUp() {
        super.setUp()
        subject = BchSigningService()
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func testTransactionSigning1() throws {
        let utxo = UnspentOutput(
            confirmations: 0,
            hash: "050d00e2e18ef13969606f1ceee290d3f49bd940684ce39898159352952b8ce2",
            hashBigEndian: "e28c2b955293159898e34c6840d99bf4d390e2ee1c6f606939f18ee1e2000d05",
            outputIndex: 0,
            script: "76a914aff1e0789e5fe316b729577665aa0a04d5b0f8c788ac",
            transactionIndex: 0,
            value: CryptoValue.create(minor: 5151, currency: .bitcoinCash),
            xpub: .init(m: "", path: "")
        )
        let privateKey = Data(hex: "7fdafb9db5bc501f2096e7d13d331dc7a75d9594af3d251313ba8b6200f4e384")
        let input = BchSigningInput(
            spendableOutputs: [utxo],
            amount: 600,
            change: 4400,
            privateKeys: [privateKey],
            toAddress: "bitcoincash:qz0a0q4kwdvdh4ryl237llla3ldga67s0yq8sduhzl",
            changeAddress: "bitcoincash:qprjwksp2xzluuykx0642xnc9alpr8jd0vvquqclcp",
            dust: nil
        )
        let result = try? subject.sign(input: input).get()
        XCTAssertNotNil(result)
    }

    func testTransactionSigning2() throws {
        let decodedWif = Base58.decode(string: "L1ynYFaszRVVztvSxgd5sPB7r7vduw1jT9ifX4A1nm4ACtqgoob2")!
        let privateKey = PrivateKey(data: decodedWif[1..<33])!
        let utxo = UnspentOutput(
            confirmations: 895,
            hash: "76bfad4cc0d1cbe454c1be0af7f8be2c8b1ca74f23d2a35306997e763b2f2273",
            hashBigEndian: "73222f3b767e990653a3d2234fa71c8b2cbef8f70abec154e4cbd1c04cadbf76",
            outputIndex: 0,
            script: "76a9141aedb27afebe4e4a2a943138ed436c35fe03f2ff88ac",
            transactionIndex: 4178099786226233,
            value: CryptoValue.create(minor: 5461495, currency: .bitcoinCash),
            xpub: UnspentOutput.XPub(
                m: "xpub6CLiRbHDgYwfFn19HnG3Jd6gr2eVWuiT8boBDnznqdVZtHNqG9nHFjQK4tgvRedu4isk8mYy2qNiUUarm5ifwBSHy7iFNsNwokpMZtdwPqG",
                path: "M/0/0"
            )
        )

        let input = BchSigningInput(
            spendableOutputs: [utxo],
            amount: 5000000,
            change: 460800,
            privateKeys: [privateKey.data],
            toAddress: "bitcoincash:qz0a0q4kwdvdh4ryl237llla3ldga67s0yq8sduhzl",
            changeAddress: "bitcoincash:qprjwksp2xzluuykx0642xnc9alpr8jd0vvquqclcp",
            dust: DustMixing(response: bchDustResponse)
        )
        let result = try? subject.sign(input: input).get()
        XCTAssertNotNil(result)
        let encoded = "010000000276bfad4cc0d1cbe454c1be0af7f8be2c8b1ca74f23d2a35306997e763b2f2273000000006b483045022100d63aa96a2c5e715be2b61162f0d7cb0b353c70989230552a4df9701e7be5b46902206d1383d8db5af0fafdb92d8545820c1be631e17628661c6809ce351819b24ed8412103e0f5113d34577a01cc569b911e57a04b012b086e0d5841f4656af90b3cde08e7ffffffff0e6033c9250b754335232d4918420baf2dd8866a47fb9af46e2b7dcd4584de2e4200000000ffffffff03404b4c00000000001976a9149fd782b67358dbd464faa3effffd8fda8eebd07988ac00080700000000001976a91447275a015185fe709633f5551a782f7e119e4d7b88ac22020000000000001976a9147328c1847e220a5b2a5c2897587ae129148e41d188ac00000000"
        XCTAssertEqual(result?.data.hex, encoded)
    }

    private var bchDustResponse: BchDustResponse {
        let data = Data(dustResponse.utf8)
        let decoded = try? JSONDecoder().decode(BchDustResponse.self, from: data)
        return decoded!
    }

    private var dustResponse: String {
        """
        {
            "tx_hash": "0e6033c9250b754335232d4918420baf2dd8866a47fb9af46e2b7dcd4584de2e",
            "tx_hash_big_endian": "2ede8445cd7d2b6ef49afb476a86d82daf0b4218492d233543750b25c933600e",
            "tx_index": 0,
            "tx_output_n": 66,
            "script": "00",
            "value": 546,
            "value_hex": "00000222",
            "confirmations": 1,
            "output_script": "76a9147328c1847e220a5b2a5c2897587ae129148e41d188ac",
            "lock_secret": "454cd1de0c53401c8c29b357f75e9deb"
        }
        """
    }
}
