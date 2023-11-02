// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RxSwift
import ToolKit

public struct PendingStateViewModel {
    public enum Image {
        case triangleError
        case clock
        case region
        case circleError
        case success
        case custom(ImageLocation)

        public var imageResource: ImageLocation {
            switch self {
            case .circleError:
                .local(name: "circular-error-icon", bundle: .platformUIKit)
            case .region:
                .local(name: "region-error-icon", bundle: .platformUIKit)
            case .triangleError:
                .local(name: "triangle-error-icon", bundle: .platformUIKit)
            case .clock:
                .local(name: "clock-error-icon", bundle: .platformUIKit)
            case .success:
                .local(name: "v-success-icon", bundle: .platformUIKit)
            case .custom(let imageResource):
                imageResource
            }
        }
    }

    let compositeStatusViewType: CompositeStatusViewType
    let title: NSAttributedString
    let subtitleTextViewModel: InteractableTextViewModel
    let button: ButtonViewModel?
    let supplementaryButton: ButtonViewModel?
    let displayCloseButton: Bool

    /// Steams the url upon each tap
    public var tap: Observable<URL> {
        subtitleTextViewModel
            .tap
            .map(\.url)
    }

    private static func title(_ string: String) -> NSAttributedString {
        NSAttributedString(
            string,
            font: .main(.regular, 20),
            color: .semantic.body
        )
    }

    public init(
        compositeStatusViewType: CompositeStatusViewType,
        title: String,
        subtitle: String,
        interactibleText: String? = nil,
        url: String? = nil,
        button: ButtonViewModel? = nil,
        supplementaryButton: ButtonViewModel? = nil,
        displayCloseButton: Bool = false
    ) {
        self.compositeStatusViewType = compositeStatusViewType
        self.title = Self.title(title)
        var inputs: [InteractableTextViewModel.Input] = [.text(string: subtitle)]
        if let interactableText = interactibleText, let url {
            inputs.append(.url(string: interactableText, url: url))
        }

        self.subtitleTextViewModel = .init(
            inputs: inputs,
            textStyle: .init(
                color: .semantic.text,
                font: .main(.regular, 14.0)
            ),
            linkStyle: .init(
                color: .semantic.primary,
                font: .main(
                    .regular,
                    14.0
                )
            ),
            alignment: .center
        )
        self.button = button
        self.supplementaryButton = supplementaryButton
        self.displayCloseButton = displayCloseButton
    }
}
