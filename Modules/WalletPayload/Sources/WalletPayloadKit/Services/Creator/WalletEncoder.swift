// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

/// Holds the `Wallet` as encoded and encrypted Data.
public struct EncodedWalletPayload: Equatable {
    public enum PayloadContext: Equatable {
        case encoded(Data)
        case encrypted(Data)

        public var value: Data {
            switch self {
            case .encoded(let data):
                data
            case .encrypted(let data):
                data
            }
        }
    }

    public let payloadContext: PayloadContext
    public let wrapper: Wrapper

    public init(
        payloadContext: PayloadContext,
        wrapper: Wrapper
    ) {
        self.payloadContext = payloadContext
        self.wrapper = wrapper
    }
}

/// Holds the properties required for creating/updating a `Wallet`
public struct WalletCreationPayload: Equatable {
    /// The encoded `InnerWraper` with applied encryption
    public let innerPayload: Data
    /// The checksum of the encrypted `Wallet` payload
    public let checksum: String
    /// The length of the encrypted `Wallet` payload
    public let length: Int
    public let guid: String
    public let sharedKey: String
    public let oldChecksum: String
    public let language: String

    public init(
        data: Data,
        wrapper: Wrapper,
        applyChecksum: (Data) -> String
    ) {
        self.innerPayload = data
        self.checksum = applyChecksum(data)
        self.length = data.count
        self.guid = wrapper.wallet.guid
        self.sharedKey = wrapper.wallet.sharedKey
        self.language = wrapper.language
        self.oldChecksum = wrapper.payloadChecksum
    }
}

public typealias WalletEncryption = (
    _ value: Data,
    _ password: String,
    _ iterations: UInt32
) -> Result<String, WalletEncodingError>

/// Types implementing `WalletEncodingAPI` should be able to create a `EncodedWalletPayload` model.
public protocol WalletEncodingAPI {
    /// Transforms the NativePayload into `Data` and returns an `EncodedWalletPayload` model
    /// - Parameter wrapper: A value of `Wrapper`
    /// - Returns: `AnyPublisher<EncodedWalletPayload, WalletEncodingError>`
    func transform(wrapper: Wrapper) -> AnyPublisher<EncodedWalletPayload, WalletEncodingError>

    /// Encodes the given payload into `WalletCreationPayload`
    /// - Returns: `AnyPublisher<WalletCreationPayload, WalletEncodingError>`
    func encode(
        payload: EncodedWalletPayload,
        applyChecksum: @escaping (Data) -> String
    ) -> AnyPublisher<WalletCreationPayload, WalletEncodingError>
}
