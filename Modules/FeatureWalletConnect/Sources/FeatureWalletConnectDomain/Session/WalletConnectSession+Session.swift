// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit
import WalletConnectSwift

extension WalletConnectSession {
    public func session(address: String) -> Session? {
        guard let wcURL = WCURL(url) else {
            return nil
        }
        guard let dAppInfo = dAppInfo.dAppInfo else {
            return nil
        }
        return Session(
            url: wcURL,
            dAppInfo: dAppInfo,
            walletInfo: walletInfo.walletInfo(
                address: address,
                chainID: dAppInfo.chainId ?? 1
            )
        )
    }
}

extension WalletConnectSession.WalletInfo {
    fileprivate func walletInfo(address: String, chainID: Int) -> Session.WalletInfo {
        Session.WalletInfo(
            approved: true,
            accounts: [address],
            chainId: chainID,
            peerId: clientId,
            peerMeta: .blockchain
        )
    }
}

extension WalletConnectSession.DAppInfo {
    fileprivate var dAppInfo: Session.DAppInfo? {
        guard let peerMeta = peerMeta.clientMeta else {
            return nil
        }
        return Session.DAppInfo(
            peerId: peerId,
            peerMeta: peerMeta,
            chainId: chainId,
            approved: true
        )
    }
}

extension Session.ClientMeta: Hashable {
    public static var blockchain: Session.ClientMeta {
        Session.ClientMeta(
            name: "Blockchain.com",
            description: nil,
            icons: [URL(string: "https://www.blockchain.com/static/apple-touch-icon.png")!],
            url: URL(string: "https://blockchain.com")!
        )
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(icons)
        hasher.combine(url)
        hasher.combine(scheme)
    }
}

extension WalletConnectSession.ClientMeta {
    fileprivate var clientMeta: Session.ClientMeta? {
        guard let url = URL(string: url) else {
            return nil
        }
        return Session.ClientMeta(
            name: name,
            description: description,
            icons: icons.compactMap(URL.init),
            url: url
        )
    }
}

extension WalletConnectSwift.Session: Equatable, Hashable {
    public static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.url == rhs.url
        && lhs.dAppInfo == rhs.dAppInfo
        && lhs.walletInfo == rhs.walletInfo
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(dAppInfo)
        hasher.combine(walletInfo)
    }
}

extension WalletConnectSwift.Session.WalletInfo: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(approved)
        hasher.combine(accounts)
        hasher.combine(chainId)
        hasher.combine(peerMeta)
        hasher.combine(peerId)
    }
}

extension WalletConnectSwift.Session.DAppInfo: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(peerId)
        hasher.combine(peerMeta)
        hasher.combine(chainId)
    }
}
