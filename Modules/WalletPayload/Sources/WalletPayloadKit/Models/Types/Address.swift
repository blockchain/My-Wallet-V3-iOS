// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Address: Equatable {
    public let addr: String
    public let priv: String?
    public let tag: Int?
    public let label: String?
    public let createdTime: Int?
    public let createdDeviceName: String?
    public let createdDeviceVersion: String?

    var isArchived: Bool {
        tag == 2
    }

    var isActive: Bool {
        !isArchived
    }

    var isWatchOnly: Bool {
        priv == nil
    }

    public init(
        addr: String,
        priv: String?,
        tag: Int?,
        label: String?,
        createdTime: Int?,
        createdDeviceName: String?,
        createdDeviceVersion: String?
    ) {
        self.addr = addr
        self.priv = priv
        self.tag = tag
        self.label = label
        self.createdTime = createdTime
        self.createdDeviceName = createdDeviceName
        self.createdDeviceVersion = createdDeviceVersion
    }
}
