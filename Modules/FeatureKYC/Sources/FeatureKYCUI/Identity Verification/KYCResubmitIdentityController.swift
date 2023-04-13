// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureKYCDomain
import Localization
import PermissionsKit
import PlatformKit
import PlatformUIKit
import ToolKit
import Veriff

/// Account verification screen in KYC flow
final class KYCResubmitIdentityController: KYCBaseViewController, ProgressableView {

    // MARK: ProgressableView

    var barColor: UIColor = .green
    var startingValue: Float = 0.9
    @IBOutlet var progressView: UIProgressView!

    enum VerificationProviders {
        case veriff
    }

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCResubmitIdentityController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .verifyIdentity
        return controller
    }

    // MARK: - Views

    @IBOutlet private var resubmitButton: PrimaryButtonContainer!
    @IBOutlet private var summary: UILabel!
    @IBOutlet private var reasonsTitle: UILabel!
    @IBOutlet private var reasonsDescription: UILabel!
    @IBOutlet private var imageTopConstraint: NSLayoutConstraint!

    // MARK: - Public Properties

    weak var delegate: KYCVerifyIdentityDelegate?

    // MARK: - Private Properties

    private let currentProvider = VerificationProviders.veriff

    private var countryCode: String?

    private var presenter: KYCVerifyIdentityPresenter!
    private let loadingViewPresenter: LoadingViewPresenting = resolve()
    private let identityVerificationAnalyticsService: IdentityVerificationAnalyticsServiceAPI = resolve()
    let analyticsRecorder: AnalyticsEventRecorderAPI = resolve()

    // MARK: - KYCRouterDelegate

    override func apply(model: KYCPageModel) {
        guard case .verifyIdentity(let countryCode) = model else { return }
        self.countryCode = countryCode
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        dependenciesSetup()
        resubmitButton.actionBlock = { [unowned self] in
            switch currentProvider {
            case .veriff:
                startVerificationFlow()
            }
        }
        summary.text = LocalizationConstants.KYC.documentsNeededSummary
        reasonsTitle.text = LocalizationConstants.KYC.reasonsTitle
        reasonsDescription.text = LocalizationConstants.KYC.reasonsDescription

        if !Constants.Booleans.IsUsingScreenSizeLargerThan5s {
            imageTopConstraint.constant = 24
        }
        setupProgressView()
    }

    private func dependenciesSetup() {
        let interactor = KYCVerifyIdentityInteractor()
        let identityPresenter = KYCVerifyIdentityPresenter(interactor: interactor)
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

extension KYCResubmitIdentityController {

    func showErrorMessage(_ message: String) {
        let alertPresenter: AlertViewPresenterAPI = DIKit.resolve()
        alertPresenter.standardError(message: message)
    }
}

extension KYCResubmitIdentityController: VeriffController {

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

extension KYCResubmitIdentityController: CameraPromptingDelegate {}

extension KYCResubmitIdentityController: MicrophonePromptingDelegate {
    func onMicrophonePromptingComplete() {
        startVerificationFlow()
    }
}
