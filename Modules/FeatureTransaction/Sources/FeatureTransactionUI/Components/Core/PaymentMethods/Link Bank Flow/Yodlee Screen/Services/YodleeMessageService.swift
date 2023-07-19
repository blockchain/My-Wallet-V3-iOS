// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxSwift

struct YodleeSuccessData: Equatable {
    let providerAccountId: String
    let accountId: String
}

final class YodleeMessageService {

    enum MessageError: LocalizedError {
        case providerIdNotFound
        case accountIdNotFound
        case generic
    }

    enum Effect: Equatable {
        case openExternal(url: URL)
        case success(data: YodleeSuccessData)
        case closed(reason: String)
        case error(MessageError)
        case none

        var isSuccess: Bool {
            guard case .success = self else {
                return false
            }
            return true
        }

        var isFailure: Bool {
            guard case .error = self else {
                return false
            }
            return true
        }

        var successData: YodleeSuccessData? {
            switch self {
            case .success(let data):
                return data
            default:
                return nil
            }
        }
    }

    let effect: Observable<Effect>

    private let messageHandler: YodleeMessageHandler

    init(
        messageHandler: YodleeMessageHandler,
        parser: @escaping (DataMessage) -> Effect
    ) {
        self.messageHandler = messageHandler

        self.effect = messageHandler.receivedMessage
            .map(\.data)
            .map { type -> Effect in
                switch type {
                case .externalLink(let data):
                    guard let url = URL(string: data.url) else {
                        return .none
                    }
                    return .openExternal(url: url)
                case .message(let data):
                    return parser(data)
                }
            }
            .share(replay: 1, scope: .whileConnected)
    }

    /// Enables the monitor of events from the message handler
    func startMonitorEvents() {
        messageHandler.registerForEvents()
    }
}

// MARK: - Yodlee Message Parsing

func yodleeMessageParser(data: DataMessage) -> YodleeMessageService.Effect {
    guard data.action != nil else {
        return .none
    }
    if let sites = data.sites, !sites.isEmpty {
        if let siteData = sites.first, let siteStatus = siteData.status, siteStatus == .success {
            return parse(status: siteStatus, reason: siteData.reason, providerAccountId: siteData.providerAccountId, accountId: siteData.accountId)
        } else {
            return .error(.generic)
        }
    } else if let status = data.status {
        return parse(status: status, reason: data.reason, providerAccountId: data.providerAccountId, accountId: nil)
    } else {
        return .error(.generic)
    }
}

private func parse(status: MessageStatus, reason: String?, providerAccountId: Int?, accountId: String?) -> YodleeMessageService.Effect {
    guard case .success = status else {
        return .closed(reason: reason ?? "unknown reason")
    }
    guard let providerAccountId else {
        return .error(.providerIdNotFound)
    }
    guard let accountId else {
        return .error(.accountIdNotFound)
    }
    return .success(data: .init(providerAccountId: String(providerAccountId), accountId: accountId))
}
