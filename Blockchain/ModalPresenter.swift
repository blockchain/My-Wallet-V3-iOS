//
//  ModalPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias OnModalDismissed = (() -> Void)

typealias OnModalResumed = (() -> Void)

@objc class ModalPresenter: NSObject {
    static let shared = ModalPresenter()

    private var modalView: BCModalView?

    private var modalChain: [BCModalView] = []

    private var rootView: UIView? {
        return UIApplication.shared.keyWindow?.rootViewController?.view
    }

    // class function declared so that the ModalPresenter singleton can be accessed from obj-C
    @objc class func sharedInstance() -> ModalPresenter {
        return ModalPresenter.shared
    }

    private override init() {
        super.init()
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

            if modalView.closeType != .none {
                modalView.onDismiss?()
                modalView.onDismiss = nil
            } else {
                modalChain.append(modalView)
            }

            self.modalView = nil
        }

        // Show modal
        let modalViewToShow = BCModalView(closeType: closeType, showHeader: showHeader, headerText: headerText)!
        modalViewToShow.onDismiss = onDismiss
        modalViewToShow.onResume = onResume

        onResume?()

        if let modalContentView = content as? BCModalContentView {
            modalContentView.prepareForModalPresentation()
        }

        modalViewToShow.myHolderView.addSubview(content)
        content.frame = CGRect(
            x: 0,
            y: 0,
            width: modalViewToShow.myHolderView.frame.size.width,
            height: modalViewToShow.myHolderView.frame.size.height
        )
        rootView?.addSubview(modalViewToShow)
        rootView?.endEditing(true)

        // Animate modal
        let animation = CATransition()
        animation.duration = 0.2

        if closeType == ModalCloseTypeBack {
            animation.type = kCATransitionMoveIn
            animation.subtype = kCATransitionFromRight
        } else {
            animation.type = kCATransitionFade
        }

        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        rootView?.layer.add(animation, forKey: AnimationKeys.showModal)

        modalView = modalViewToShow

        UIApplication.shared.statusBarStyle = .lightContent
    }

    private struct AnimationKeys {
        static let showModal = "ShowModal"
    }
}
