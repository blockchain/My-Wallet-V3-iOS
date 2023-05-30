//
//  Copyright © 2022 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol MobileIntelligence_p: AnyObject {

    associatedtype Options: MobileIntelligenceOptions_p
    associatedtype OptionsBuilder: MobileIntelligenceOptionsBuilder_p where OptionsBuilder.Options == Options, OptionsBuilder.OptionsBuilder == OptionsBuilder
    associatedtype UpdateOptions: MobileIntelligenceUpdateOptions_p
    associatedtype Response: MobileIntelligenceResponse_p

    static func start(withOptions options: Options) -> AnyObject

    static func submitData(completion: @escaping ((Response) -> Void))
    static func updateOptions(options: UpdateOptions, completion: ((Response) -> Void)?)

    static func trackField(forKey key: String, text: String)
    static func trackFieldFocus(forKey key: String, hasFocus: Bool)
}

public protocol MobileIntelligenceOptions_p: Codable {

    var clientId: String? { get set }
    var sessionKey: String? { get set }
    var userIdHash: String? { get set }
    var environment: String? { get set }
    var flow: String? { get set }
    var partnerId: String? { get set }
    var enableBehaviorBiometrics: Bool { get set }
    var enableClipboardTracking: Bool { get set }
    var enableFieldTracking: Bool { get set }

    static var ENV_SANDBOX: String { get }
    static var ENV_PRODUCTION: String { get }

    init()
}

public protocol MobileIntelligenceUpdateOptions_p: Codable {

    var userIdHash: String? { get set }
    var sessionKey: String { get set }
    var flow: String { get set }

    init()
}

public protocol MobileIntelligenceResponse_p: Codable {

    var status: Bool? { get set }
    var message: String? { get set }
}

public protocol MobileIntelligenceOptionsBuilder_p {

    associatedtype OptionsBuilder: MobileIntelligenceOptionsBuilder_p
    associatedtype Options: MobileIntelligenceOptions_p

    static func new() -> OptionsBuilder

    func setClientId(with clientId: String) -> OptionsBuilder
    func setSessionKey(with sessionKey: String) -> OptionsBuilder
    func setUserIdHash(with userIdHash: String) -> OptionsBuilder
    func setEnvironment(with environment: String) -> OptionsBuilder
    func setFlow(with flow: String) -> OptionsBuilder
    func setPartnerId(with partnerId: String) -> OptionsBuilder
    func enableBehaviorBiometrics(with enableBehaviorBiometrics: Bool) -> OptionsBuilder
    func enableClipboardTracking(with enableClipboardTracking: Bool) -> OptionsBuilder
    func enableFieldTracking(with enableFieldTracking: Bool) -> OptionsBuilder
    func setShouldAutoSubmitOnInit(with shouldAutoSubmitOnInit: Bool) -> OptionsBuilder
    func setSourcePlatform(with sourcePlatform: String) -> OptionsBuilder
    func build() -> Options
}
