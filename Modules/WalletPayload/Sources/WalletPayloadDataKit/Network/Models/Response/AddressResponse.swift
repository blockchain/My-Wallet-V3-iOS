// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct AddressResponse: Equatable, Codable {
    let addr: String
    let priv: String?
    let tag: Int?
    let label: String?
    let createdTime: Int?
    let createdDeviceName: String?
    let createdDeviceVersion: String?

    enum CodingKeys: String, CodingKey {
        case addr
        case priv
        case tag
        case label
        case createdTime = "created_time"
        case createdDeviceName = "created_device_name"
        case createdDeviceVersion = "created_device_version"
    }
}

extension WalletPayloadKit.Address {
    static func from(model: AddressResponse) -> Address {
        Address(
            addr: model.addr,
            priv: model.priv,
            tag: model.tag,
            label: model.label,
            createdTime: model.createdTime,
            createdDeviceName: model.createdDeviceName,
            createdDeviceVersion: model.createdDeviceVersion
        )
    }

    var toAddressResponse: AddressResponse {
        AddressResponse(
            addr: addr,
            priv: priv,
            tag: tag,
            label: label,
            createdTime: createdTime,
            createdDeviceName: createdDeviceName,
            createdDeviceVersion: createdDeviceVersion
        )
    }
}
