import Blockchain
import SwiftUI

@MainActor
public struct SiteMap {

    let app: AppProtocol

    public init(app: AppProtocol) {
        self.app = app
    }

    @ViewBuilder public func view(
        for ref: Tag.Reference,
        in context: Tag.Context = [:]
    ) throws -> some View {
        switch ref {
        case blockchain.ux.payment.method.wire.transfer:
            WireTransferView()
        case blockchain.ux.payment.method.wire.transfer.help:
            try WireTransferRowHelp(context[blockchain.ux.payment.method.wire.transfer.help].decode())
        default:
            throw "Unknown View of \(ref) in \(Self.self)"
        }
    }
}
