// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct DerivationResponse: Equatable, Codable {
    enum Format: String, Codable {
        case legacy
        case segwit = "bech32"

        var purpose: Int {
            switch self {
            case .legacy:
                44
            case .segwit:
                84
            }
        }
    }

    let type: Format?
    let purpose: Int?
    let xpriv: String?
    let xpub: String?
    let addressLabels: [AddressLabelResponse]
    let cache: AddressCacheResponse

    enum CodingKeys: String, CodingKey {
        case type
        case purpose
        case xpriv
        case xpub
        case addressLabels = "address_labels"
        case cache
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decodeIfPresent(Format.self, forKey: .type)
        self.purpose = try container.decodeIfPresent(Int.self, forKey: .purpose)
        self.xpriv = try container.decodeIfPresent(String.self, forKey: .xpriv)
        self.xpub = try container.decodeIfPresent(String.self, forKey: .xpub)
        self.addressLabels = try container.decodeIfPresent([AddressLabelResponse].self, forKey: .addressLabels) ?? []
        self.cache = try container.decodeIfPresent(AddressCacheResponse.self, forKey: .cache) ?? AddressCacheResponse.empty
    }

    init(
        type: DerivationResponse.Format?,
        purpose: Int?,
        xpriv: String?,
        xpub: String?,
        addressLabels: [AddressLabelResponse],
        cache: AddressCacheResponse
    ) {
        self.type = type
        self.purpose = purpose
        self.xpriv = xpriv
        self.xpub = xpub
        self.addressLabels = addressLabels
        self.cache = cache
    }
}

extension DerivationResponse.Format {

    var toType: DerivationType {
        switch self {
        case .legacy:
            .legacy
        case .segwit:
            .segwit
        }
    }

    static func create(from model: DerivationResponse.Format?) -> DerivationType? {
        guard let model else { return nil }
        switch model {
        case .legacy:
            return .legacy
        case .segwit:
            return .segwit
        }
    }

    static func create(type: DerivationType?) -> DerivationResponse.Format? {
        guard let type else { return nil }
        switch type {
        case .legacy:
            return .legacy
        case .segwit:
            return .segwit
        }
    }
}

extension DerivationType {
    var toDerivationFormat: DerivationResponse.Format {
        switch self {
        case .legacy:
            .legacy
        case .segwit:
            .segwit
        }
    }
}

// MARK: - Derivation Creation

extension WalletPayloadKit.Derivation {
    static func from(model: DerivationResponse) -> Derivation {
        Derivation(
            type: DerivationResponse.Format.create(from: model.type),
            purpose: model.purpose,
            xpriv: model.xpriv,
            xpub: model.xpub,
            addressLabels: transform(from: model.addressLabels),
            cache: transform(from: model.cache)
        )
    }

    var derivationResponse: DerivationResponse {
        DerivationResponse(
            type: DerivationResponse.Format.create(type: type),
            purpose: DerivationResponse.Format.create(type: type)?.purpose,
            xpriv: xpriv,
            xpub: xpub,
            addressLabels: addressLabels.map(\.toAddressLabelResponse),
            cache: cache.toAddressCacheResponse
        )
    }
}

func transform(from model: [AddressLabelResponse]) -> [WalletPayloadKit.AddressLabel] {
    model.map { label in
        WalletPayloadKit.AddressLabel(
            index: label.index,
            label: label.label
        )
    }
}

func transform(from model: AddressCacheResponse) -> WalletPayloadKit.AddressCache {
    WalletPayloadKit.AddressCache(
        receiveAccount: model.receiveAccount,
        changeAccount: model.changeAccount
    )
}
