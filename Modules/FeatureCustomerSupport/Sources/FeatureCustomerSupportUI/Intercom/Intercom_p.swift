import Foundation

public protocol IntercomUserAttributes_p: AnyObject {
    init()
    var userId: String? { get set }
    var email: String? { get set }
    var languageOverride: String? { get set }
}

public protocol Intercom_p: AnyObject {

    associatedtype UserAttributes: IntercomUserAttributes_p

    static func setApiKey(_ key: String, forAppId: String)

    static func unreadConversationCount() -> UInt

    static func loginUser(
        with attributes: UserAttributes,
        completion: ((Result<Void, Error>) -> Void)?
    )

    static func logout()

    static func showMessenger()
    static func showHelpCenter()
    static func hide()

    static func logEvent(withName name: String)
    static func logEvent(withName name: String, metaData: [AnyHashable: Any])
}
