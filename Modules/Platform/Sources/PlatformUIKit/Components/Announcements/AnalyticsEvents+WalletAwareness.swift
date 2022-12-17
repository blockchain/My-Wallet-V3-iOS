import AnalyticsKit
import PlatformKit
import ToolKit

extension AnalyticsEvents {
    public enum WalletAwareness: AnalyticsEvent {
        case promptShown(isSSOUser: Bool, countOfPrompts: Int)
        case promptActioned(isSSOUser: Bool)
        case promptDismissed(isSSOUser: Bool)

        public var name: String {
            switch self {
            case .promptShown:
                return "Exchange Awareness Prompt Shown"
            case .promptActioned:
                return "Exchange Awareness Prompt Clicked"
            case .promptDismissed:
                return "Exchange Awareness Prompt Dismissed"
            }
        }

        public var params: [String: String]? {
            sharedParams + specificParams
        }

        private var sharedParams: [String: String] {
            [
                "device": "APP-iOS",
                "sso_user": "\(isSSO)",
                "current_origin": "Wallet-Prompt"
            ]
        }

        private var specificParams: [String: String] {
            switch self {
            case .promptActioned, .promptDismissed:
                return [:]
            case .promptShown(_, let countOfPrompts):
                return ["count_of_prompts": "\(countOfPrompts)"]
            }
        }

        private var isSSO: Bool {
            switch self {
            case .promptActioned(let isSSOUser),
                 .promptDismissed(let isSSOUser),
                 .promptShown(let isSSOUser, _):
                return isSSOUser
            }
        }
    }
}
