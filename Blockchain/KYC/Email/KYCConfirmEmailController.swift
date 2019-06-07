//
//  KYCConfirmEmailController.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

class KYCConfirmEmailController: KYCBaseViewController, BottomButtonContainerView, ProgressableView {

    // MARK: - ProgressableView

    @IBOutlet var progressView: UIProgressView!
    var barColor: UIColor = .green
    var startingValue: Float = 0.3

    // MARK: BottomButtonContainerView

    var originalBottomButtonConstraint: CGFloat!
    var optionalOffset: CGFloat = 0
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!

    // MARK: IBOutlets

    @IBOutlet private var labelHeader: UILabel!
    @IBOutlet private var labelSubHeader: UILabel!
    @IBOutlet private var validationTextFieldEmail: ValidationTextField!
    @IBOutlet private var buttonDidntGetEmail: PrimaryButtonContainer!
    @IBOutlet private var primaryButton: PrimaryButtonContainer!

    // MARK: Private Properties

    private lazy var presenter: KYCVerifyEmailPresenter = {
        return KYCVerifyEmailPresenter(view: self)
    }()

    internal var disposable: Disposable?

    // MARK: Properties

    var email: EmailAddress = "" {
        didSet {
            guard isViewLoaded else { return }
            validationTextFieldEmail.text = email
        }
    }

    // MARK: Factory

    override class func make(with coordinator: KYCCoordinator) -> KYCConfirmEmailController {
        let controller = makeFromStoryboard()
        controller.coordinator = coordinator
        controller.pageType = .confirmEmail
        return controller
    }

    // MARK: - UIViewController Lifecycle Methods

    deinit {
        cleanUp()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        labelHeader.text = LocalizationConstants.KYC.checkYourInbox
        labelSubHeader.text = LocalizationConstants.KYC.confirmEmailExplanation
        validationTextFieldEmail.text = email
        validationTextFieldEmail.isEnabled = false
        let attributedTitle = NSMutableAttributedString(string: LocalizationConstants.KYC.didntGetTheEmail + " " + LocalizationConstants.KYC.sendAgain)
        attributedTitle.addForegroundColor(buttonDidntGetEmail.buttonTitleColor, to: LocalizationConstants.KYC.didntGetTheEmail)
        attributedTitle.addForegroundColor(#colorLiteral(red: 0.06274509804, green: 0.6784313725, blue: 0.8941176471, alpha: 1), to: LocalizationConstants.KYC.sendAgain)
        buttonDidntGetEmail.attributedTitle = attributedTitle
        buttonDidntGetEmail.primaryButtonFont = 2
        buttonDidntGetEmail.activityIndicatorStyle = .gray
        buttonDidntGetEmail.actionBlock = { [unowned self] in
            self.sendVerificationEmail()
        }
        primaryButton.title = LocalizationConstants.KYC.openEmailApp
        primaryButton.actionBlock = { [unowned self] in
            self.primaryButtonTapped()
        }
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpBottomButtonContainerView()
        disposable = presenter.waitForEmailConfirmation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        disposable?.dispose()
        disposable = nil
        super.viewDidDisappear(animated)
    }

    // MARK: - Actions

    private func sendVerificationEmail() {
        guard (email as NSString).isEmail() else {
            return
        }
        presenter.sendVerificationEmail(to: email)
    }

    private func primaryButtonTapped() {
        UIApplication.shared.openMailApplication()
    }
}

extension KYCConfirmEmailController: KYCConfirmEmailView {
    func showLoadingView() {
        buttonDidntGetEmail.isLoading = true
    }

    func sendEmailVerificationSuccess() {
        let origTitle = buttonDidntGetEmail.title
        let origColor = buttonDidntGetEmail.buttonTitleColor

        buttonDidntGetEmail.title = LocalizationConstants.KYC.emailSent
        buttonDidntGetEmail.buttonTitleColor = UIColor.green

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.buttonDidntGetEmail.title = origTitle
            strongSelf.buttonDidntGetEmail.buttonTitleColor = origColor
        }
    }

    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message, in: self)
    }

    func hideLoadingView() {
        buttonDidntGetEmail.isLoading = false
    }

    func emailVerifiedSuccess() {
        Logger.shared.info("Email is verified.")
        coordinator.handle(event: .nextPageFromPageType(pageType, nil))
    }
}
