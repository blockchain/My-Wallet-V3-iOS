// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI
import UIKit

enum CustomSheetPresentation {}

struct ModalSheetContext: Equatable {

    /// A `CGFloat` specifying the progress how much the modal is expanded or collapsed.
    /// `1.0` is fully expanded whereas `0.0` is fully collapsed
    let progress: CGFloat

    /// A `CGPoint` of the `x` and `y` position of the modal
    let offset: CGPoint

    static let zero = ModalSheetContext(progress: 0.0, offset: .zero)
}

extension View {

    @ViewBuilder
    func presentationDetents(
        selectedDetent: Binding<UISheetPresentationController.Detent.Identifier>,
        largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?,
        limitDetents: Binding<Bool>,
        modalOffset: Binding<ModalSheetContext>
    ) -> some View {
        background(
            CustomSheetPresentation.Representable(
                selectedDetent: selectedDetent,
                largestUndimmedDetent: largestUndimmedDetentIdentifier,
                limitDetents: limitDetents,
                modalOffset: modalOffset
            )
        )
    }
}

extension CustomSheetPresentation {

    struct Representable: UIViewControllerRepresentable {
        let selectedDetent: Binding<UISheetPresentationController.Detent.Identifier>
        let largestUndimmedDetent: UISheetPresentationController.Detent.Identifier?
        let limitDetents: Binding<Bool>
        let modalOffset: Binding<ModalSheetContext>

        func makeUIViewController(context: Context) -> Controller {
            Controller(
                selectedDetent: selectedDetent,
                largestUndimmedDetent: largestUndimmedDetent,
                limitDetents: limitDetents,
                modalOffset: modalOffset
            )
        }

        func updateUIViewController(_ controller: Controller, context: Context) {
            controller.update(
                selectedDetent: selectedDetent,
                largestUndimmedDetent: largestUndimmedDetent,
                limitDetents: limitDetents,
                modalOffset: modalOffset
            )
        }
    }

    final class Controller: UIViewController, UISheetPresentationControllerDelegate {
        private var observation: NSKeyValueObservation?

        private var selectedDetent: Binding<UISheetPresentationController.Detent.Identifier>
        private var modalOffset: Binding<ModalSheetContext>
        private var largestUndimmedDetent: UISheetPresentationController.Detent.Identifier?
        private var limitDetents: Binding<Bool>
        private weak var _delegate: UISheetPresentationControllerDelegate?

        init(
            selectedDetent: Binding<UISheetPresentationController.Detent.Identifier>,
            largestUndimmedDetent: UISheetPresentationController.Detent.Identifier?,
            limitDetents: Binding<Bool>,
            modalOffset: Binding<ModalSheetContext>
        ) {
            self.selectedDetent = selectedDetent
            self.largestUndimmedDetent = largestUndimmedDetent
            self.modalOffset = modalOffset
            self.limitDetents = limitDetents
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            if let controller = parent?.sheetPresentationController {
                if controller.delegate !== self {
                    _delegate = controller.delegate
                    controller.delegate = self
                }
            }
            update(
                selectedDetent: selectedDetent,
                largestUndimmedDetent: largestUndimmedDetent,
                limitDetents: limitDetents,
                modalOffset: modalOffset
            )
        }

        func update(
            selectedDetent: Binding<UISheetPresentationController.Detent.Identifier>,
            largestUndimmedDetent: UISheetPresentationController.Detent.Identifier?,
            limitDetents: Binding<Bool>,
            modalOffset: Binding<ModalSheetContext>
        ) {
            self.selectedDetent = selectedDetent
            self.largestUndimmedDetent = largestUndimmedDetent
            self.limitDetents = limitDetents
            parent?.isModalInPresentation = true
            if let controller = parent?.sheetPresentationController, let presentationController = parent?.presentationController {
                let isLimited = limitDetents.wrappedValue
                if limitDetents.wrappedValue {
                    controller.detents = limitedDetents(presentationController: presentationController)
                } else {
                    controller.detents = fullDetents(presentationController: presentationController)
                }
                DispatchQueue.main.async {
                    controller.animateChanges {
                        controller.selectedDetentIdentifier = selectedDetent.wrappedValue
                        controller.largestUndimmedDetentIdentifier = largestUndimmedDetent != nil ? largestUndimmedDetent! : nil
                    }
                }
                controller.preferredCornerRadius = Spacing.padding3
                controller.prefersGrabberVisible = false
                controller.prefersScrollingExpandsWhenScrolledToEdge = true

                // oh dear... the only way that I found to be accurate enough in order to track the position of a modal sheet
                // is by observing its frame property.
                // Tried PanGesture on the presentedView of SheetPresentationController and it seemed to be only triggered
                // when the gesture originated within the navigation bar of the sheet...
                let heightFractions: (collapsed: CGFloat, expanded: CGFloat) = isLimited
                ? (AppChromeDetents.limited.fraction, AppChromeDetents.expanded.fraction)
                : (AppChromeDetents.collapsed.fraction, AppChromeDetents.expanded.fraction)
                observation = controller.presentedView?.observe(\.frame) { [modalOffset] view, _ in
                    guard let superview = view.superview else {
                        return
                    }

                    let extraModalPadding = superview.safeAreaInsets.top > 20 ? 10.0 : 20.0
                    let frameHeight = superview.safeAreaLayoutGuide.layoutFrame.height - extraModalPadding
                    let leastCollapsedHeight = frameHeight * heightFractions.collapsed
                    let expandedHeight = frameHeight * heightFractions.expanded
                    let effectiveHeight = expandedHeight - leastCollapsedHeight
                    let offsetY = view.frame.minY - superview.safeAreaInsets.top - extraModalPadding
                    let percentage = offsetY / effectiveHeight

                    let offset = CGPoint(
                        x: view.frame.origin.x,
                        y: view.frame.minY - superview.safeAreaInsets.top
                    )
                    modalOffset.wrappedValue = ModalSheetContext(
                        progress: percentage,
                        offset: offset
                    )
                }
            }
        }

        func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
            // Updated when a detent change occured via gesture not when setting the `selectedDetentIdentifier` programmatically.
            guard let identifier = sheetPresentationController.selectedDetentIdentifier?.rawValue else {
                return
            }
            guard selectedDetent.wrappedValue.rawValue != identifier else {
                return
            }
            selectedDetent.wrappedValue = .init(identifier)
        }

        override func responds(to aSelector: Selector!) -> Bool {
            if super.responds(to: aSelector) { return true }
            if _delegate?.responds(to: aSelector) ?? false { return true }
            return false
        }

        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            if super.responds(to: aSelector) { return self }
            return _delegate
        }
    }
}

private func fullDetents(presentationController: UIPresentationController) -> [UISheetPresentationController.Detent] {
    [
        AppChromeDetents.detent(type: .collapsed, context: { [unowned presentationController] context in
            let maxValue = maxHeightResolution(presentationController, context)
            return maxValue * AppChromeDetents.collapsed.fraction
        }),
        AppChromeDetents.detent(type: .semiCollapsed, context: { [unowned presentationController] context in
            let maxValue = maxHeightResolution(presentationController, context)
            return maxValue * AppChromeDetents.semiCollapsed.fraction
        }),
        AppChromeDetents.detent(type: .expanded, context: { [unowned presentationController] context in
            let maxValue = maxHeightResolution(presentationController, context)
            return maxValue * AppChromeDetents.expanded.fraction
        })
    ]
}

private func limitedDetents(presentationController: UIPresentationController) -> [UISheetPresentationController.Detent] {
    [
        AppChromeDetents.detent(type: .limited, context: { [unowned presentationController] context in
            let maxValue = maxHeightResolution(presentationController, context)
            return maxValue * AppChromeDetents.limited.fraction
        }),
        AppChromeDetents.detent(type: .expanded, context: { [unowned presentationController] context in
            let maxValue = maxHeightResolution(presentationController, context)
            return maxValue * AppChromeDetents.expanded.fraction
        })
    ]
}

/// returns the largest value a detent can have
let maxHeightResolution: (UIPresentationController, NSObjectProtocol) -> CGFloat = { presentationController, context in
    if #available(iOS 16, *) {
        if let skata = context as? UISheetPresentationControllerDetentResolutionContext {
            return skata.maximumDetentValue
        } else {
            return fallbackResolution(presentationController)
        }
    } else {
        return fallbackResolution(presentationController)
    }
}

/// returns the largest value a detent can have based on `presentationController`
let fallbackResolution: (UIPresentationController) -> CGFloat = { presentationController in
    guard let containerView = presentationController.containerView else {
        return presentationController.presentedViewController.view.intrinsicContentSize.height.rounded(.up)
    }
    let safeAreaValueToAccountFor: CGFloat
    if containerView.safeAreaInsets.bottom > 0 {
        safeAreaValueToAccountFor = containerView.safeAreaInsets.top + containerView.safeAreaInsets.bottom
    } else {
        safeAreaValueToAccountFor = 0
    }
    let maxValue = containerView.frame.height - safeAreaValueToAccountFor
    return maxValue
}
