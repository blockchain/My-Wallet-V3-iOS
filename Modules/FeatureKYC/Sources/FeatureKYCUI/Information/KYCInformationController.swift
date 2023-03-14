// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import DIKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

/// A reusable view for displaying static information
final class KYCInformationController: KYCBaseViewController {

    /// typealias for an action to be taken when the primary button/CTA is tapped
    typealias PrimaryButtonAction = (KYCInformationController) -> Void

    /// Action invoked when the primary button is tapped
    var primaryButtonAction: PrimaryButtonAction?

    var informationView: KYCProgressInformationView?

    /// The view model
    var viewModel: KYCInformationViewModel?

    /// The view configuration for this view
    var viewConfig = KYCInformationViewConfig.defaultConfig

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCInformationController {
        let controller = KYCInformationController()
        controller.router = coordinator
        controller.pageType = .accountStatus
        return controller
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true

        informationView = KYCProgressInformationView(
            viewModel: .init(get: {
                self.viewModel
            }, set: { value in
                self.viewModel = value
            }),
            config: .init(get: {
                self.viewConfig
            }, set: { value in
                self.viewConfig = value ?? .defaultConfig
            }),
            buttonCallback: { [unowned self] in
                if let primaryButtonAction {
                    primaryButtonAction(self)
                } else {
                    dismiss(animated: true)
                }
            }
        )
        embed(informationView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        informationView?.viewModel = viewModel
        informationView?.config = viewConfig
    }

    override func navControllerCTAType() -> NavigationCTA {
        .dismiss
    }

    override func navControllerRightBarButtonTapped(_ navController: KYCOnboardingNavigationController) {
        router.handle(event: .nextPageFromPageType(pageType, nil))
    }
}

struct KYCProgressInformationView: View {
    @Binding var viewModel: KYCInformationViewModel?
    @Binding var config: KYCInformationViewConfig?

    var buttonCallback: (() -> Void)?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 20) {
                        if let image = viewModel?.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 77.0, height: 77.0)
                        }
                        VStack(spacing: 5) {
                            if let title = viewModel?.title {
                                Text(title)
                                    .typography(.title3)
                            }
                            if let subtitle = viewModel?.subtitle {
                                Text(subtitle)
                                    .typography(.body1)
                            }
                            if let description = viewModel?.description {
                                Text(description)
                                    .typography(.body1)
                            }
                        }
                    }
                    .padding()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.textTitle)

                    if let bottomDescriptionTitle = viewModel?.bottomDescriptionTitle {
                        VStack(spacing: 5) {
                            Text(bottomDescriptionTitle)
                                .typography(.body1)

                            if let bottomDescription = viewModel?.bottomDescription {
                                Text(bottomDescription)
                                    .typography(.paragraph1)
                                    .foregroundColor(Color.textDetail)
                            }
                        }
                        .padding()
                        .multilineTextAlignment(.center)
                    }
                }
                .frame(width: geometry.size.width)
                .frame(height: geometry.size.height)
            }
        }

        if config?.isPrimaryButtonEnabled ?? false,
           let buttonTitle = viewModel?.buttonTitle
        {
            PrimaryButton(
                title: buttonTitle
            ) {
                buttonCallback?()
            }
            .frame(alignment: .bottom)
            .padding([.horizontal, .bottom])
        }
    }
}
