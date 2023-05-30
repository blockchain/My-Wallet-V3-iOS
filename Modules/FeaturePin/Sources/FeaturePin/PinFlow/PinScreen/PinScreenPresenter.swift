// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import FeatureAuthenticationDomain
import FeatureSettingsDomain
import LocalAuthentication
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

private enum PinScreenPresenterError: Error {
    case absentPinValueWhenAuthenticateUsingBiometrics
}

/// Presenter for PIN screen
final class PinScreenPresenter {

    // MARK: - Properties

    var trailingButton: Screen.Style.TrailingButton {
        let title = Bundle.versionAndBuildNumber()
        switch flow {
        case .create:
            return .content(Screen.NavigationBarContent(title: title))
        case .createPin:
            return .none
        case .authenticate(from: let origin, logoutRouting: _):
            switch origin {
            case .background, .attachedOn:
                return .questionMark
            case .foreground:
                return .none
            }
        default:
            return .none
        }
    }

    var leadingButton: Screen.Style.LeadingButton {
        switch flow {
        case .authenticate(from: let origin, logoutRouting: _):
            switch origin {
            case .background, .attachedOn:
                return .text(value: LocalizationConstants.Pin.logoutButton)
            case .foreground:
                return .none
            }
        case .change, .enableBiometrics:
            return .back
        case .create:
            return .none
        case .createPin:
            return .none
        }
    }

    var titleView: Screen.Style.TitleView {
        switch flow {
        case .change:
            return .text(value: LocalizationConstants.Pin.changePinTitle)
        default:
            return .image(name: "logo_large", width: 40)
        }
    }

    var barStyle: Screen.Style.Bar {
        switch flow {
        case .change:
            return .darkContent(background: .primary)
        default:
            return .mutedContent(ignoresStatusBar: true, background: .clear)
        }
    }

    let contentColor: UIColor
    let backgroundColor: UIColor

    // MARK: Rx

    private let disposeBag = DisposeBag()
    private let verificationQueue: ConcurrentDispatchQueueScheduler

    private let pinProcessingObservable: Observable<Pin>
    let pin = BehaviorRelay<Pin?>(value: nil)

    private let isProcessingRelay = BehaviorRelay<Bool>(value: false)

    /// When `true`, the the presenter is pending for an update from the interactor
    var isProcessing: Observable<Bool> {
        isProcessingRelay
            .observe(on: MainScheduler.instance)
    }

    private let digitPadIsEnabledRelay = BehaviorRelay<Bool>(value: true)
    var digitPadIsEnabled: Observable<Bool> {
        digitPadIsEnabledRelay
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
    }

    private let remainingLockTimeMessageRelay = BehaviorRelay<String>(value: "")
    var remainingLockTimeMessage: Observable<String> {
        remainingLockTimeMessageRelay
            .observe(on: MainScheduler.instance)
    }

    // MARK: Routing

    private let performEffect: PinRouting.RoutingType.Effect
    private let forwardRouting: PinRouting.RoutingType.Forward
    let backwardRouting: PinRouting.RoutingType.Backward!

    // MARK: Services

    private let interactor: PinInteracting
    private let recorder: Recording
    private let appSettings: AppSettingsAuthenticating
    private let cloudSettings: CloudBackupConfiguring
    private let biometryProvider: BiometryProviding
    private let credentialsStore: CredentialsStoreAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let legacyGuidRepository: LegacyGuidRepositoryAPI
    private let legacySharedKeyRepository: LegacySharedKeyRepositoryAPI
    private let reachability: Reachability

    // MARK: - View Models

    let digitPadViewModel: DigitPadViewModel
    let securePinViewModel: SecurePinViewModel

    /// The flow which `useCase` is under
    let flow: PinRouting.Flow

    /// The use case for the screen
    let useCase: PinScreenUseCase

    // MARK: - Setup

    init(
        useCase: PinScreenUseCase,
        flow: PinRouting.Flow,
        interactor: PinInteracting,
        biometryProvider: BiometryProviding,
        appSettings: AppSettingsAuthenticating,
        cloudSettings: CloudBackupConfiguring,
        legacyGuidRepository: LegacyGuidRepositoryAPI,
        legacySharedKeyRepository: LegacySharedKeyRepositoryAPI,
        recorder: Recording,
        credentialsStore: CredentialsStoreAPI,
        backwardRouting: PinRouting.RoutingType.Backward?,
        forwardRouting: @escaping PinRouting.RoutingType.Forward,
        performEffect: @escaping PinRouting.RoutingType.Effect,
        reachability: Reachability,
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.useCase = useCase
        self.flow = flow
        self.interactor = interactor
        self.recorder = recorder
        self.appSettings = appSettings
        self.biometryProvider = biometryProvider
        self.backwardRouting = backwardRouting
        self.cloudSettings = cloudSettings
        self.forwardRouting = forwardRouting
        self.credentialsStore = credentialsStore
        self.performEffect = performEffect
        self.analyticsRecorder = analyticsRecorder
        self.legacyGuidRepository = legacyGuidRepository
        self.legacySharedKeyRepository = legacySharedKeyRepository
        self.reachability = reachability

        self.verificationQueue = ConcurrentDispatchQueueScheduler(qos: .userInitiated)

        self.contentColor = UIColor.semantic.title
        self.backgroundColor = UIColor.semantic.background
        let emptyPinColor = UIColor.semantic.light
        let buttonHighlightColor = UIColor.semantic.title.withAlphaComponent(0.08)

        // Setup the bottom leading button (biometrics) if necessary
        let customButtonViewModel: DigitPadButtonViewModel

        switch useCase {
        case .authenticateBeforeChanging, .authenticateOnLogin:
            let currentBiometricsType = biometryProvider.configuredType
            if currentBiometricsType.isValid {
                let biometricButtonImage: DigitPadButtonViewModel.Content.Image!
                switch currentBiometricsType {
                case .faceID:
                    biometricButtonImage = .faceId
                case .touchID:
                    biometricButtonImage = .touchId
                case .none:
                    biometricButtonImage = nil
                }
                let buttonBackground = DigitPadButtonViewModel.Background(
                    highlightColor: buttonHighlightColor
                )
                customButtonViewModel = DigitPadButtonViewModel(
                    content: .image(type: biometricButtonImage, tint: contentColor),
                    background: buttonBackground
                )
            } else {
                customButtonViewModel = .empty
            }
        case .authenticateBeforeEnablingBiometrics, .create, .select:
            customButtonViewModel = .empty
        }

        // Setup the subject
        let securePinTitle: String
        switch useCase {
        case .authenticateBeforeChanging, .authenticateBeforeEnablingBiometrics, .authenticateOnLogin:
            securePinTitle = LocalizationConstants.Pin.enterYourPinLabel
        case .select:
            securePinTitle = LocalizationConstants.Pin.createYourPinLabel
        case .create:
            securePinTitle = LocalizationConstants.Pin.confirmYourPinLabel
        }

        self.digitPadViewModel = DigitPadViewModel(
            padType: .pin(maxCount: 4),
            customButtonViewModel: customButtonViewModel,
            contentTint: contentColor,
            buttonHighlightColor: buttonHighlightColor
        )
        self.securePinViewModel = SecurePinViewModel(
            title: securePinTitle,
            tint: contentColor,
            emptyPinColor: emptyPinColor
        )

        // Bind PIN length to fill count
        digitPadViewModel.valueLengthObservable
            .bindAndCatch(to: securePinViewModel.fillCountRelay)
            .disposed(by: disposeBag)

        // Get the pin string once it's filled, map it to `Pin`, unwrap it.
        self.pinProcessingObservable = digitPadViewModel.valueInsertedObservable
            .withLatestFrom(digitPadViewModel.valueObservable)
            .map { Pin(string: $0) }
            .filter { $0 != nil }
            .map { $0! }

        // Bind pin processing to pin relay
        pinProcessingObservable
            .bindAndCatch(to: pin)
            .disposed(by: disposeBag)

        // Bind tapping on the biometrics button to authentication using biometrics
        digitPadViewModel.customButtonTapObservable
            .bind { [unowned self] in
                authenticateUsingBiometricsIfNeeded()
            }
            .disposed(by: disposeBag)

        // A count down timer starting from `remaining` seconds
        let timer = digitPadViewModel.remainingLockTimeObservable
            .flatMapLatest { remaining -> Observable<Int> in
                // Create a count down timer that counts for `remaining` seconds
                Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
                    .take(remaining) // takes the first `remaining` seconds
                    .map { $0 + 1 } // timer increment by 1 every time
                    .map { remaining - $0 } // `remaining` - timer value equals actual seconds remaining
            }

        // bind the timer to the lock time message shown when key pad is disabled
        timer
            .map(formatRemainingLockTimeMessage)
            .bindAndCatch(to: remainingLockTimeMessageRelay)
            .disposed(by: disposeBag)

        // bind the timer to the visibility of the key pad
        timer
            // check if seconds remaining is 0, if yes, enable keypad, otherwise disable
            .map { $0 == 0 }
            .bindAndCatch(to: digitPadIsEnabledRelay)
            .disposed(by: disposeBag)
    }

    func viewDidLoad() {}
}

// MARK: - Navigation

extension PinScreenPresenter {
    func leadingButtonPressed() {
        if !useCase.isAuthenticateOnLogin {
            backwardRouting()
        } else {
            logout()
        }
    }

    // TODO: Display an overlay for the pin
    func trailingButtonPressed() {}
}

// MARK: - Error Display

/// Formatting remaining PIN lock time error message
/// - parameter duration: the lock time duration in seconds
private func formatRemainingLockTimeMessage(duration: Int) -> String {
    var message = ""
    if duration > 0, duration <= 60 {
        message = LocalizationConstants.Pin.tryAgain +
            String(" \(duration)") + LocalizationConstants.Pin.seconds
    } else if duration > 60, duration <= 3600 {
        message = LocalizationConstants.Pin.tryAgain +
            String(" \(duration / 60)") + LocalizationConstants.Pin.minutes +
            String(" \(duration % 60)") + LocalizationConstants.Pin.seconds
    } else if duration > 3600 {
        message = LocalizationConstants.Pin.tryAgain +
            String(" \(duration / 3600)") + LocalizationConstants.Pin.hours +
            String(" \((duration / 60) % 60)") + LocalizationConstants.Pin.minutes +
            String(" \(duration % 60)") + LocalizationConstants.Pin.seconds
    }
    return message
}

// MARK: - API & Functionality

extension PinScreenPresenter {

    /// Resets the pin
    /// - parameter value: the value to reset the pin to
    func reset(to value: String = "") {
        digitPadViewModel.reset(to: value)
    }

    /// Authenticate using set biometrics
    func authenticateUsingBiometricsIfNeeded() {

        // Verify the use case is authentication
        guard useCase.isAuthenticate else {
            return
        }

        // Verify biometrics authenticators are enabled on device and configured in app
        guard biometryProvider.configurationStatus.isConfigured else {
            return
        }

        /*
         At this point, the PIN is assumed to have been kept on
         keychain so it MUST have value, otherwise, report a non-fatal
         */
        guard let pin = appSettings.pin else {
            recorder.error(PinScreenPresenterError.absentPinValueWhenAuthenticateUsingBiometrics)
            return
        }

        biometryProvider.authenticate(reason: .enterWallet)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak digitPadViewModel] _ in
                    // We reset the pin to the value kept by the app settings.
                    // That causes a chain reaction as if the user has filled the pin himself.
                    digitPadViewModel?.reset(to: pin)
                }
            )
            .disposed(by: disposeBag)
    }

    // MARK: - Changing/First Time Setting Pin

    /// Validates that the 1st pin entered by the user during the change pin flow,
    /// or the first time the user is setting a pin, is valid.
    func validateFirstEntry() -> Completable {
        Completable.create { [unowned self] completable in

            // Check for validity
            guard let pin = pin.value, pin.isValid else {
                completable(.error(PinError.invalid))
                return Disposables.create()
            }

            // Check that the current pin is different from the previous pin
            guard pin != useCase.pin else {
                completable(.error(PinError.identicalToPrevious))
                return Disposables.create()
            }

            // A completion to be executed in an case
            let completion = { [unowned self] in
                forwardRouting(.pin(value: pin))
                completable(.completed)
            }

            completion()
            return Disposables.create()
        }
    }

    /// Validates that the 2nd pin entered during the create/change pin flow matches the
    /// 1st pin entered, and if so, it will proceed to change the user's pin.
    func validateSecondEntry() -> Completable {
        Completable.create { [weak self] completable in
            guard let self else { return Disposables.create() }

            // Extract both current and previous pins before comparing them. Both MUST NOT be nil at that point
            guard let previousPin = useCase.pin,
                  let pin = pin.value
            else {
                completable(.error(PinError.nullifiedPinKey))
                return Disposables.create()
            }

            // Current pin must be equal to the previous pin
            guard pin == previousPin else {
                completable(.error(PinError.pinMismatch(recovery: backwardRouting)))
                return Disposables.create()
            }

            // Generate a random key-pair
            guard let keyPair = try? PinStoreKeyPair.generateNewKeyPair() else {
                completable(.error(PinError.custom(LocalizationConstants.Pin.genericError)))
                return Disposables.create()
            }

            // Create the pin payload
            let payload = PinPayload(
                pinCode: pin.toString,
                keyPair: keyPair,
                persistsLocally: biometryProvider.configurationStatus.isConfigured
            )

            isProcessingRelay.accept(true)

            // Create the pin in the remote store
            interactor
                .create(using: payload)
                .observe(on: MainScheduler.instance)
                .do(onDispose: { [weak self] in
                    self?.isProcessingRelay.accept(false)
                })
                .flatMap(weak: self) { (self) in
                    self.backupCredentials(pinDecryptionKey: keyPair.value)
                }
                .subscribe(
                    onCompleted: {
                        completable(.completed)
                    },
                    onError: { error in
                        completable(.error(error))
                    }
                )
                .disposed(by: disposeBag)
            return Disposables.create()
        }
    }

    /// Invoked when user is authenticating himself using his PIN, before selecting a new one
    func verifyPinBeforeChanging() -> Completable {

        // Pin MUST NOT be nil at that point as it accompanies the use-case.
        guard let pin = pin.value else {
            return Completable.error(PinError.nullifiedPinKey)
        }

        return Completable.create { [weak self] completable in
            guard let self else { return Disposables.create() }
            verify()
                .asCompletable()
                .do(onDispose: { [weak self] in
                    self?.isProcessingRelay.accept(false)
                })
                .subscribe(
                    onCompleted: { [weak self] in
                        self?.forwardRouting(.pin(value: pin))
                        completable(.completed)
                    },
                    onError: { error in
                        completable(.error(error))
                    }
                )
                .disposed(by: disposeBag)
            return Disposables.create()
        }
    }

    /// Invoked when user is authenticating himself using pin or biometrics.
    func authenticatePin() -> Completable {
        verify()
            .do(onDispose: { [isProcessingRelay] in
                isProcessingRelay.accept(false)
            })
            .observe(on: verificationQueue)
            .flatMap(weak: self) { (self, pinDecryptionKey) -> Single<String> in
                self.backupOrRestoreCredentials(pinDecryptionKey: pinDecryptionKey)
                    .andThen(.just(pinDecryptionKey))
            }
            .flatMapCompletable(weak: self) { (self, pinDecryptionKey) -> Completable in
                self.authenticatePin(pinDecryptionKey: pinDecryptionKey)
            }
            .observe(on: MainScheduler.instance)
    }

    /// Invoked during Pin Authentication.
    /// Proceeds with pin authentication using pinDecryptionKey to decrypt password.
    private func authenticatePin(pinDecryptionKey: String) -> Completable {
        interactor
            .password(from: pinDecryptionKey)
            .do(
                onSuccess: { [weak self] password in
                    self?.forwardRouting(.authentication(password: password))
                },
                onDispose: { [weak self] in
                    self?.isProcessingRelay.accept(false)
                }
            )
            .asCompletable()
    }

    /// Invoked during Pin Authentication.
    /// Under the 'regular' flow, `isPairedWithWallet` is already true.
    /// Backup credentials to iCloud if `isPairedWithWallet.
    /// Restore wallet guid and sharedKey from iCloud if `isPairedWithWallet` is false.
    private func backupOrRestoreCredentials(pinDecryptionKey: String) -> Completable {
        if shouldBackupCredentials {
            // Wallet is paired, back up credentials.
            return credentialsStore.backup(pinDecryptionKey: pinDecryptionKey)
        } else {
            // Wallet is not paired, attempt to retrieve wallet details from iCloud
            return credentialsStore
                .walletData(pinDecryptionKey: pinDecryptionKey)
                .do(
                    onSuccess: { [weak self] data in
                        // Restore everything to settings so the app can progress normally
                        self?.legacyGuidRepository.directSet(guid: data.guid)
                        self?.legacySharedKeyRepository.directSet(sharedKey: data.sharedKey)
                    }
                )
                .asCompletable()
                // Ignore any error regading restoring from iCloud
                .catch { _ in .empty() }
        }
    }

    private var shouldBackupCredentials: Bool {
        legacyGuidRepository.directGuid != nil
            && legacySharedKeyRepository.directSharedKey != nil
            && appSettings.pinKey != nil
            && appSettings.encryptedPinPassword != nil
            && cloudSettings.cloudBackupEnabled
    }

    /// Invoked during Second Pin Validation.
    /// Backup credentials to iCloud if `isPairedWithWallet.
    private func backupCredentials(pinDecryptionKey: String) -> Completable {
        if shouldBackupCredentials {
            return credentialsStore.backup(pinDecryptionKey: pinDecryptionKey)
        } else {
            return .empty()
        }
    }
}

// MARK: - Accessors

extension PinScreenPresenter {

    /// Opts out the user
    func logout() {
        interactor.hasLogoutAttempted = true
        flow.logoutRouting?()
        credentialsStore.erase()
    }

    // Should be called after setting pin successfully
    func didSetPinSuccessfully() {
        forwardRouting(.pin(value: pin.value!))
    }

    // MARK: - Pin Validation

    /// Validates if the pin is correct, by generating payload (i.e. pin code and pin key combination)
    /// - Returns: Single wrapping the pin decryption key
    private func verify() -> Single<String> {
        guard reachability.hasInternetConnection else {
            let reset = { [weak self] () -> Void in
                self?.reset()
            }
            return .error(PinError.noInternetConnection(recovery: reset))
        }

        guard let pinKey = appSettings.pinKey else {
            return .error(PinError.nullifiedPinKey)
        }

        // Pin MUST NOT be nil at that point
        let pin = pin.value!

        // Create a pin payload to be validated by the interactor
        let payload = PinPayload(
            pinCode: pin.toString,
            pinKey: pinKey,
            persistsLocally: useCase.isAuthenticateBeforeEnablingBiometrics
        )

        isProcessingRelay.accept(true)

        // Ask the interactor to validate the payload
        return interactor.validate(using: payload)
            .observe(on: MainScheduler.instance)
    }
}

// MARK: - Alert View Models

/// In order to separate the alert UI from the pin presenter,
/// the presenter only decides what alert model should be displayed
/// and returns it to the component that requested it.
extension PinScreenPresenter {

    /// Logout alert model
    var logoutAlertModel: AlertModel {
        let okButton = AlertAction(style: .confirm(LocalizationConstants.okString))
        let image = UIImage(named: "lock_icon")!
        return AlertModel(
            headline: LocalizationConstants.Pin.tooManyAttemptsTitle,
            body: LocalizationConstants.Pin.tooManyAttemptsLogoutMessage,
            actions: [okButton],
            image: image,
            style: .sheet
        )
    }

    /// Enabling biometrics alert model (if biometrics is configurable)
    var biometricsAlertModel: AlertModel? {
        let biometricsStatus = biometryProvider.configurationStatus

        // Ensure bioemtrics is configurable before continuing
        guard biometricsStatus.isConfigurable else {
            return nil
        }

        let okButtonAction = { [unowned self] in
            interactor.persist(pin: pin.value!)
        }
        let okButton = AlertAction(
            style: .confirm(LocalizationConstants.okString),
            metadata: .block(okButtonAction)
        )
        let cancelButton = AlertAction(style: .default(LocalizationConstants.Pin.enableBiometricsNotNowButton))
        let title: String
        let image: UIImage
        switch biometricsStatus.biometricsType {
        case .faceID:
            title = LocalizationConstants.Pin.enableFaceIdTitle
            image = UIImage(named: "face_id_icon")!
        default: // touch-id
            title = LocalizationConstants.Pin.enableTouchIdTitle
            image = UIImage(named: "touch_id_icon")!
        }
        let alert = AlertModel(
            headline: title,
            body: LocalizationConstants.Pin.enableBiometricsMessage,
            actions: [okButton, cancelButton],
            image: image.withRenderingMode(.alwaysTemplate),
            style: .sheet
        )
        return alert
    }

    /// Enabling biometrics alert model (if biometrics is configurable)
    var biometricsSheetModel: PinScreenEnableBiometricsInfoViewModel? {
        let biometricsStatus = biometryProvider.configurationStatus

        // Ensure bioemtrics is configurable before continuing
        guard biometricsStatus.isConfigurable else {
            return nil
        }

        let okButtonAction = { [unowned self] in
            interactor.persist(pin: pin.value!)
        }
        let okButton = PinScreenEnableBiometricsInfoViewModel.Button(
            title: LocalizationConstants.okString,
            actionClosure: okButtonAction
        )
        let cancelButton = PinScreenEnableBiometricsInfoViewModel.Button(
            title: LocalizationConstants.Pin.enableBiometricsNotNowButton,
            actionClosure: {}
        )
        let title: String
        let image: Icon
        switch biometricsStatus.biometricsType {
        case .faceID:
            title = LocalizationConstants.Pin.enableFaceIdTitle
            image = .faceID
        default: // touch-id
            title = LocalizationConstants.Pin.enableTouchIdTitle
            image = .fingerprint
        }
        let alert = PinScreenEnableBiometricsInfoViewModel(
            icon: image.color(.primary),
            title: title,
            subtitle: LocalizationConstants.Pin.enableBiometricsMessage,
            acceptButton: okButton,
            cancelButton: cancelButton
        )
        return alert
    }

    /// Set pin success alert model
    var setPinSuccessAlertModel: AlertModel? {
        guard flow.isChange else {
            return nil
        }
        analyticsRecorder.record(event: AnalyticsEvents.New.Security.mobilePinCodeChanged)
        let okButton = AlertAction(style: .confirm(LocalizationConstants.continueString))
        let image = UIImage(named: "success_icon")!
        let alert = AlertModel(
            headline: LocalizationConstants.Pin.pinSuccessfullySet,
            body: "",
            actions: [okButton],
            image: image,
            style: .sheet
        )
        return alert
    }
}
