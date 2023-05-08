// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import WalletConnectSwift

public protocol WalletConnectRouterAPI {
    func showConnectedDApps(_ completion: (() -> Void)?)
    func showSessionDetails(session: WalletConnectSession) -> AnyPublisher<Void, Never>
    func openWebsite(for client: Session.ClientMeta)
}
