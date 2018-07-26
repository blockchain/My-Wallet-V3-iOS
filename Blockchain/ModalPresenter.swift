//
//  ModalPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias OnModalDismissed = () -> Void

typealias OnModalResumed = () -> Void

@objc class ModalPresenter: NSObject {
    static let shared = ModalPresenter()

    @objc private(set) var modalView: BCModalView?

    private var modalChain: [BCModalView] = []

    private var topMostView: UIView? {
        return UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.view
    }

    // class function declared so that the ModalPresenter singleton can be accessed from obj-C
    @objc class func sharedInstance() -> ModalPresenter {
        return ModalPresenter.shared
    }

    private override init() {
        super.init()
    }

    @objc func closeAllModals() {
        LoadingViewPresenter.shared.hideBusyView()

        WalletManager.shared.wallet.isSyncing = false

        guard let modalView = modalView else { return }

        modalView.endEditing(true)
        modalView.removeFromSuperview()

        let animation = CATransition()
        animation.duration = Constants.Animation.duration
        animation.type = kCATransitionFade
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

        UIApplication.shared.keyWindow?.layer.add(animation, forKey: AnimationKeys.hideModal)

        modalView.onDismiss?()
        modalView.onDismiss = nil

        self.modalView = nil

        for modalView in modalChain {
            modalView.myHolderView?.subviews.forEach { $0.removeFromSuperview() }
            modalView.myHolderView?.removeFromSuperview()
            modalView.onDismiss?()
        }

        self.modalChain.removeAll()
    }

    @objc func closeModal(withTransition transition: String) {
        guard let modalView = modalView else {
            print("Cannot close modal. modalView is nil.")
            return
        }

        NotificationCenter.default.post(name: Constants.NotificationKeys.modalViewDismissed, object: nil)

        modalView.removeFromSuperview()

        let animation = CATransition()
        animation.duration = Constants.Animation.duration

        // There are two types of transitions: movement based and fade in/out.
        // The movement based ones can have a subType to set which direction the movement is in.
        // In case the transition parameter is a direction, we use the MoveIn transition and the transition
        // parameter as the direction, otherwise we use the transition parameter as the transition type.
        if transition != kCATransitionFade {
            animation.type = kCATransitionMoveIn
            animation.subtype = transition
        } else {
            animation.type = transition
        }
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        UIApplication.shared.keyWindow?.layer.add(animation, forKey: AnimationKeys.hideModal)

        modalView.onDismiss?()
        modalView.onDismiss = nil

        if let previousModalView = modalChain.last {
            topMostView?.addSubview(previousModalView)
            topMostView?.endEditing(true)

            modalView.onResume?()

            self.modalView = previousModalView
            self.modalChain.removeLast()
        } else {
            self.modalView = nil
        }
    }

    @objc func showModal(
        withContent content: UIView,
        closeType: ModalCloseType,
        showHeader: Bool,
        headerText: String,
        onDismiss: OnModalDismissed? = nil,
        onResume: OnModalResumed? = nil
    ) {

        // Remove the modal if we have one
        if let modalView = modalView {
            modalView.removeFromSuperview()

            if modalView.closeType != ModalCloseTypeNone {
                modalView.onDismiss?()
                modalView.onDismiss = nil
            } else {
                modalChain.append(modalView)
            }

            self.modalView = nil
        }

        // Show modal
        let modalViewToShow = BCModalView(closeType: closeType, showHeader: showHeader, headerText: headerText)
        modalViewToShow.onDismiss = onDismiss
        modalViewToShow.onResume = onResume

        onResume?()

        if let modalContentView = content as? BCModalContentView {
            modalContentView.prepareForModalPresentation()
        }

        content.frame = CGRect(
            x: 0,
            y: 0,
            width: modalViewToShow.myHolderView?.frame.size.width ?? 0,
            height: modalViewToShow.myHolderView?.frame.size.height ?? 0
        )

        //: The pairing instructions view requires a custom background color
        //: due to bottom insets on the iPhone X
        // TODO: remove this stopgap solution when the modal view presenter is deprecated
        if content is PairingInstructionsView {
            modalViewToShow.backgroundColor = .gray1
        }

        modalViewToShow.myHolderView?.addSubview(content)
        topMostView?.addSubview(modalViewToShow)
        topMostView?.endEditing(true)

        // Animate modal
        let animation = CATransition()
        animation.duration = Constants.Animation.duration

        if closeType == ModalCloseTypeBack {
            animation.type = kCATransitionMoveIn
            animation.subtype = kCATransitionFromRight
        } else {
            animation.type = kCATransitionFade
        }

        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        topMostView?.layer.add(animation, forKey: AnimationKeys.showModal)

        modalView = modalViewToShow

        UIApplication.shared.statusBarStyle = .lightContent
    }

    private struct AnimationKeys {
        static let showModal = "ShowModal"
        static let hideModal = "HideModal"
    }
}
