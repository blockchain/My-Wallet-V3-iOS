// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CryptoSwift
import EthereumKit
import MoneyKit
import PlatformKit
import WalletConnectSign

func txTarget(
    _ request: WalletConnectSign.Request,
    session: WalletConnectSign.Session,
    network: EVMNetwork,
    txCompleted: @escaping TransactionTarget.TxCompleted,
    txRejected: @escaping () -> AnyPublisher<Void, Never>
) -> (any TransactionTarget)? {
    guard let method = WalletConnectSupportedMethods(rawValue: request.method) else {
         return nil
    }
    let dappAddress = URL(string: session.peer.url)?.host ?? ""
    let dappName = session.peer.name
    let dappLogo = session.peer.icons.first ?? ""

    switch method {
    case .ethSendTransaction,
        .ethSignTransaction:
        guard let transaction = sendTx(from: request) else {
            return nil
        }
        return EthereumSendTransactionTarget(
            dAppAddress: dappAddress,
            dAppLogoURL: dappLogo,
            dAppName: dappAddress,
            method: method == .ethSignTransaction ? .sign : .send,
            network: network,
            onTransactionRejected: txRejected,
            onTxCompleted: txCompleted,
            transaction: transaction
        )

    case .personalSign,
         .ethSignTypedData,
        .ethSign:
        guard let signValues = signMessage(from: request) else {
            return nil
        }
        return EthereumSignMessageTarget(
            account: signValues.account,
            dAppAddress: dappAddress,
            dAppLogoURL: dappLogo,
            dAppName: dappName,
            message: signValues.message,
            network: network,
            onTransactionRejected: txRejected,
            onTxCompleted: txCompleted
        )
    }
}

func signMessage(from request: WalletConnectSign.Request) -> (account: String, message: EthereumSignMessageTarget.Message)? {
    guard let params = try? request.params.get([String].self) else {
        return nil
    }
    guard let method = WalletConnectSignMethod(rawValue: request.method) else {
        return nil
    }
    guard let address = method.address(from: params),
          let message = method.message(from: params) else {
        return nil
    }

    switch method {
    case .personalSign,
         .ethSign:
        guard let data = Data(hexString: message) else {
            return nil
        }
        return (address, .data(data))
    case .ethSignTypedData:
        return (address, .typedData(message))
    }
}

func sendTx(from request: WalletConnectSign.Request) -> EthereumJsonRpcTransaction? {
    guard let transaction = try? request.params.get([EthereumJsonRpcTransaction].self) else {
        return nil
    }
    return transaction.first
}
