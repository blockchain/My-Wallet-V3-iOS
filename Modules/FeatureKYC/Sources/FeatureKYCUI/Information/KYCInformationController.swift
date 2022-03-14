// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import ToolKit
import UIKit

/// A reusable view for displaying static information
final class KYCInformationController: KYCBaseViewController {

    /// typealias for an action to be taken when the primary button/CTA is tapped
    typealias PrimaryButtonAction = (KYCInformationController) -> Void

    // MARK: - Properties

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelSubtitle: UILabel!
    @IBOutlet private var labelDescription: UILabel!
    @IBOutlet private var buttonPrimaryContainer: PrimaryButtonContainer!

    /// Action invoked when the primary button is tapped
    var primaryButtonAction: PrimaryButtonAction?

    /// The view model
    var viewModel: KYCInformationViewModel?

    /// The view configuration for this view
    var viewConfig = KYCInformationViewConfig.defaultConfig

    @Inject private var analyticsRecorder: AnalyticsEventRecorderAPI

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCInformationController {
        let controller: KYCInformationController = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .accountStatus
        return controller
    }

    // MARK: - IBActions

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.router.finish()
        })
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyViewModel()
        applyViewConfig()
    }

    private func applyViewModel() {
        guard let viewModel = viewModel else {
            imageView.image = nil
            labelTitle.text = ""
            labelSubtitle.superview?.removeFromSuperview()
            labelDescription.text = ""
            buttonPrimaryContainer.title = ""
            var presentingViewControllerName: String = ""
            if let presentingViewController = presentingViewController {
                presentingViewControllerName = NSStringFromClass(
                    presentingViewController.classForCoder
                ).components(separatedBy: ".").last ?? ""
            }
            analyticsRecorder.record(
                event: AnalyticsEvents.KYC.kycInformationControllerViewModelNilError(presentingViewController: presentingViewControllerName)
            )
            return
        }
        imageView.image = viewModel.image
        labelTitle.text = viewModel.title
        if let subtitle = viewModel.subtitle {
            labelSubtitle.text = subtitle
        } else {
            labelSubtitle.superview?.removeFromSuperview()
        }
        labelDescription.text = viewModel.description
        buttonPrimaryContainer.title = viewModel.buttonTitle ?? ""
    }

    private func applyViewConfig() {
        labelTitle.textColor = viewConfig.titleColor
        buttonPrimaryContainer.isHidden = !viewConfig.isPrimaryButtonEnabled
        buttonPrimaryContainer.actionBlock = { [unowned self] in
            self.primaryButtonAction?(self)
        }
        if let tint = viewConfig.imageTintColor {
            imageView.tintColor = tint
        }
    }

    override func navControllerCTAType() -> NavigationCTA {
        .dismiss
    }

    override func navControllerRightBarButtonTapped(_ navController: KYCOnboardingNavigationController) {
        router.handle(event: .nextPageFromPageType(pageType, nil))
    }
}
