// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import FeatureWalletConnectDomain
import WalletCore
import Web3Wallet
import XCTest

// keys and data were taken from Wallet Core tests
final class FeatureWalletConnectDomainTests: XCTestCase {

    func test_recover_public_key() throws {
        let message: Data = Data(hex: "de4e9524586d6fce45667f9ff12f661e79870c4105fa0fb58af976619bb11432")
        let signature: Data = Data(hex: "00000000000000000000000000000000000000000000000000000000000000020123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef80")
        let recovered = try EthereumKit.recoverPubKey(from: signature, message: message)
        XCTAssertEqual(
            recovered.hex,
            "0456d8089137b1fd0d890f8c7d4a04d0fd4520a30b19518ee87bd168ea12ed8090329274c4c6c0d9df04515776f2741eeffc30235d596065d718c3973e19711ad0"
        )
    }

    func test_recover_public_key_intergration() throws {
        let privateKey = WalletCore.PrivateKey(data: .init(hex: "4f96ed80e9a7555a6f74b3d658afdd9c756b0a40d4ca30c42c2039eb449bb904"))
        let publicKey = privateKey?.getPublicKeySecp256k1(compressed: false)
        XCTAssertEqual(
            publicKey!.data.hex,
            "0463ade8ebc212b85e7e4278dc3dcb4f9cc18aab912ef5d302b5d1940e772e9e1a9213522efddad487bbd5dd7907e8e776f918e9a5e4cb51893724e9fe76792a4f"
        )
        let message = Data(hex: "6468eb103d51c9a683b51818fdb73390151c9973831d2cfb4e9587ad54273155")
        let signature = Data(hex: "92c336138f7d0231fe9422bb30ee9ef10bf222761fe9e04442e3a11e88880c646487026011dae03dc281bc21c7d7ede5c2226d197befb813a4ecad686b559e5800")
        // create WalletConnect's EthereumSignature serialized and try to recover
        let wcEthSignature = EthereumSignature(serialized: signature).serialized
        let recovered = try EthereumKit.recoverPubKey(from: wcEthSignature, message: message)
        XCTAssertEqual(recovered.hex, publicKey!.data.hex)
    }

    // same as above with v=27
    func test_recover_public_key_intergration_alt_one() throws {
        let privateKey = WalletCore.PrivateKey(data: .init(hex: "4f96ed80e9a7555a6f74b3d658afdd9c756b0a40d4ca30c42c2039eb449bb904"))
        let publicKey = privateKey?.getPublicKeySecp256k1(compressed: false)
        XCTAssertEqual(
            publicKey!.data.hex,
            "0463ade8ebc212b85e7e4278dc3dcb4f9cc18aab912ef5d302b5d1940e772e9e1a9213522efddad487bbd5dd7907e8e776f918e9a5e4cb51893724e9fe76792a4f"
        )
        let message = Data(hex: "6468eb103d51c9a683b51818fdb73390151c9973831d2cfb4e9587ad54273155")
        let signature = Data(hex: "92c336138f7d0231fe9422bb30ee9ef10bf222761fe9e04442e3a11e88880c646487026011dae03dc281bc21c7d7ede5c2226d197befb813a4ecad686b559e581b")
        // create WalletConnect's EthereumSignature serialized and try to recover
        let wcEthSignature = EthereumSignature(serialized: signature).serialized
        let recovered = try EthereumKit.recoverPubKey(from: wcEthSignature, message: message)
        XCTAssertEqual(recovered.hex, publicKey!.data.hex)
    }

    // same as above with v=35+2
    func test_recover_public_key_intergration_alt_two() throws {
        let privateKey = WalletCore.PrivateKey(data: .init(hex: "4f96ed80e9a7555a6f74b3d658afdd9c756b0a40d4ca30c42c2039eb449bb904"))
        let publicKey = privateKey?.getPublicKeySecp256k1(compressed: false)
        XCTAssertEqual(
            publicKey!.data.hex,
            "0463ade8ebc212b85e7e4278dc3dcb4f9cc18aab912ef5d302b5d1940e772e9e1a9213522efddad487bbd5dd7907e8e776f918e9a5e4cb51893724e9fe76792a4f"
        )
        let message = Data(hex: "6468eb103d51c9a683b51818fdb73390151c9973831d2cfb4e9587ad54273155")
        let signature = Data(hex: "92c336138f7d0231fe9422bb30ee9ef10bf222761fe9e04442e3a11e88880c646487026011dae03dc281bc21c7d7ede5c2226d197befb813a4ecad686b559e5825")
        // create WalletConnect's EthereumSignature serialized and try to recover
        let wcEthSignature = EthereumSignature(serialized: signature).serialized
        let recovered = try EthereumKit.recoverPubKey(from: wcEthSignature, message: message)
        XCTAssertEqual(recovered.hex, publicKey!.data.hex)
    }

    func test_sign_and_recover() throws {
        let privateKey = WalletCore.PrivateKey(data: .init(hex: "4f96ed80e9a7555a6f74b3d658afdd9c756b0a40d4ca30c42c2039eb449bb904"))
        let publicKey = privateKey?.getPublicKeySecp256k1(compressed: false)
        XCTAssertEqual(
            publicKey!.data.hex,
            "0463ade8ebc212b85e7e4278dc3dcb4f9cc18aab912ef5d302b5d1940e772e9e1a9213522efddad487bbd5dd7907e8e776f918e9a5e4cb51893724e9fe76792a4f"
        )

        let message = Data(hex: "6468eb103d51c9a683b51818fdb73390151c9973831d2cfb4e9587ad54273155")

        let signature = privateKey!.sign(digest: message, curve: .secp256k1)
        XCTAssertEqual(
            signature!.hex,
            "92c336138f7d0231fe9422bb30ee9ef10bf222761fe9e04442e3a11e88880c646487026011dae03dc281bc21c7d7ede5c2226d197befb813a4ecad686b559e5800"
        )
        let wcEthSignature = EthereumSignature(serialized: signature!)

        let recovered = try EthereumKit.recoverPubKey(from: wcEthSignature.serialized, message: message)
        XCTAssertEqual(
            publicKey!.data.hex,
            recovered.hex
        )
    }
}
