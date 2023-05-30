// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import DIKit
import Errors
import FeatureKYCDomain
import Localization
import PermissionsKit
import PlatformKit
import PlatformUIKit
import SafariServices
import ToolKit
import Veriff

private typealias Events = AnalyticsEvents.New.KYC
private typealias LocalizedStrings = LocalizationConstants.NewKYC.Steps.IdentityVerification

/// Account verification screen in KYC flow
final class KYCVerifyIdentityController: KYCBaseViewController, ProgressableView {

    var identityVerificationRepository = IdentityVerificationRepository()

    // MARK: ProgressableView

    var barColor: UIColor = UIColor.semantic.success
    var startingValue: Float = 0.9
    @IBOutlet var progressView: UIProgressView!

    enum VerificationProviders {
        case veriff
    }

    // MARK: UIStackView

    @IBOutlet private var documentTypeStackView: UIStackView!

    // MARK: - Public Properties

    weak var delegate: KYCVerifyIdentityDelegate?

    // MARK: - Private Properties

    private let veriffVersion: String = "/v1/"

    private let currentProvider = VerificationProviders.veriff

    private var countryCode: String?

    private var presenter: KYCVerifyIdentityPresenter!
    private let loadingViewPresenter: LoadingViewPresenting = resolve()
    let analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    private let identityVerificationAnalyticsService: IdentityVerificationAnalyticsServiceAPI = resolve()

    private var countrySupportedTrigger: ActionableTrigger!

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCVerifyIdentityController {
        let controller = KYCVerifyIdentityController()
        controller.title = LocalizedStrings.title
        controller.router = coordinator
        controller.pageType = .verifyIdentity
        return controller
    }

    // MARK: - KYCRouterDelegate

    override func apply(model: KYCPageModel) {
        guard case .verifyIdentity(let countryCode) = model else { return }
        self.countryCode = countryCode
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.semantic.light
        dependenciesSetup()
        embedContentView()
    }

    // MARK: Helpers

    private func embedContentView() {
        let view = IdentityVerificationView(
            store: Store(
                initialState: IdentityVerification.State(),
                reducer: IdentityVerification.reducer,
                environment: IdentityVerification.Environment(
                    onCompletion: startVerification,
                    supportedDocumentTypes: supportedDocumentTypes,
                    analyticsRecorder: analyticsRecorder,
                    mainQueue: .main
                )
            )
        )
        embed(view)
    }

    private func supportedDocumentTypes() -> AnyPublisher<[KYCDocumentType], NabuNetworkError> {
        guard let code = countryCode else { return .just([]) }

        return identityVerificationRepository
            .supportedDocumentTypes(countryCode: code)
    }

    // MARK: - Lifecycle Methods

    func startVerification() {
        analyticsRecorder.record(event: Events.preVerificationCTAClicked)
        analyticsRecorder.record(event: AnalyticsEvents.KYC.kycVerifyIdStartButtonClick)
        switch currentProvider {
        case .veriff:
            presenter.didTapNext()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLeftBarButtonItem()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsRecorder.record(event: Events.preVerificationViewed)
        updateLeftBarButtonItem()
    }

    override func navControllerCTAType() -> NavigationCTA {
        .dismiss
    }

    override func navControllerRightBarButtonTapped(_ navController: KYCOnboardingNavigationController) {
        analyticsRecorder.record(event: Events.preVerificationDismissed)
        super.navControllerRightBarButtonTapped(navController)
    }

    private func updateLeftBarButtonItem() {
        navigationItem.hidesBackButton = true
    }

    private func dependenciesSetup() {
        let interactor = KYCVerifyIdentityInteractor()
        let identityPresenter = KYCVerifyIdentityPresenter(interactor: interactor)
        identityPresenter.identityView = self
        identityPresenter.cameraPromptingDelegate = self
        identityPresenter.microphonePromptingDelegate = self
        presenter = identityPresenter
        delegate = presenter
    }

    /// Begins identity verification and presents the view
    ///
    /// - Parameters:
    ///   - document: enum of identity types mapped to an identity provider
    ///   - provider: the current provider of verification services
    fileprivate func startVerificationFlow(
        _ document: KYCDocumentType? = nil,
        provider: VerificationProviders = .veriff
    ) {
        switch provider {
        case .veriff:
            veriffCredentialsRequest()
        }
    }

    private func didSelect(_ document: KYCDocumentType) {
        startVerificationFlow(document, provider: currentProvider)
    }
}

extension KYCVerifyIdentityController: ActionableLabelDelegate {
    func targetRange(_ label: ActionableLabel) -> NSRange? {
        countrySupportedTrigger.actionRange()
    }

    func actionRequestingExecution(label: ActionableLabel) {
        countrySupportedTrigger.execute()
    }
}

extension KYCVerifyIdentityController: KYCVerifyIdentityView {}

extension KYCVerifyIdentityController {
    func showErrorMessage(_ message: String) {
        let alertPresenter: AlertViewPresenterAPI = DIKit.resolve()
        alertPresenter.standardError(message: message)
    }
}

extension KYCVerifyIdentityController: VeriffController {

    func sessionDidEndWithResult(_ result: VeriffSdk.Result) {
        switch result.status {
        case .error(let error):
            trackInternalVeriffError(.init(veriffError: error))
            onVeriffError(message: error.localizedErrorMessage)
        case .done:
            onVeriffSubmissionCompleted()
        case .canceled:
            onVeriffCancelled()
        @unknown default:
            onVeriffCancelled()
        }
    }

    func onVeriffSubmissionCompleted() {
        analyticsRecorder.record(event: AnalyticsEvents.KYC.kycVeriffInfoSubmitted)
        loadingViewPresenter.show(with: LocalizationConstants.KYC.submittingInformation)
        delegate?.submitVerification(
            onCompleted: { [unowned self] in
                dismiss(animated: true, completion: {
                    self.router.handle(event: .nextPageFromPageType(self.pageType, nil))
                })
            },
            onError: { error in
                self.dismiss(animated: true, completion: {
                    let alertPresenter: AlertViewPresenterAPI = DIKit.resolve()
                    alertPresenter.standardError(message: LocalizationConstants.Errors.genericError)
                })
                Logger.shared.error("Failed to submit verification \(String(describing: error))")
            }
        )
    }

    func onVeriffError(message: String) {
        showErrorMessage(message)
    }

    func trackInternalVeriffError(_ error: InternalVeriffError) {
        switch error {
        case .localError:
            identityVerificationAnalyticsService.recordLocalError()
        case .serverError:
            identityVerificationAnalyticsService.recordServerError()
        case .networkError:
            identityVerificationAnalyticsService.recordNetworkError()
        case .uploadError:
            identityVerificationAnalyticsService.recordUploadError()
        case .videoFailed:
            identityVerificationAnalyticsService.recordVideoFailure()
        case .unknown:
            identityVerificationAnalyticsService.recordUnknownError()
        case .cameraUnavailable,
             .microphoneUnavailable,
             .deprecatedSDKVersion:
            break
        }
    }

    @objc
    func onVeriffCancelled() {
        loadingViewPresenter.hide()
        dismiss(animated: true, completion: { [weak self] in
            guard let this = self else { return }
            this.router.handle(event: .nextPageFromPageType(this.pageType, nil))
        })
    }

    func veriffCredentialsRequest() {
        delegate?.createCredentials(onSuccess: { [weak self] credentials in
            self?.launchVeriffController(credentials: credentials)
        }, onError: { [weak self] error in
            Logger.shared.error("Failed to get Veriff credentials. Error: \(String(describing: error))")
            self?.onVeriffError(message: String(describing: error))
        })
    }
}

extension KYCVerifyIdentityController: CameraPromptingDelegate {}

extension KYCVerifyIdentityController: MicrophonePromptingDelegate {
    func onMicrophonePromptingComplete() {
        startVerificationFlow()
    }
}
