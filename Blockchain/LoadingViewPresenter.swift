//
//  LoadingViewPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Presenter in charge of displaying a view that displays a loading screen
@objc class LoadingViewPresenter: NSObject {

    static let shared = LoadingViewPresenter()

    @objc private lazy var busyView: BCFadeView = {
        let busyView = BCFadeView.instanceFromNib()
        busyView.frame = UIScreen.main.bounds
        busyView.alpha = 0.0
        return busyView
    }()

    @objc var isLoadingShown: Bool {
        return busyView.superview != nil && busyView.alpha == 1.0
    }

    /// sharedInstance function declared so that the LoadingViewPresenter singleton can be accessed
    /// from Obj-C. Should deprecate this once all Obj-c references have been removed.
    @objc class func sharedInstance() -> LoadingViewPresenter { return shared }

    private override init() {
        super.init()
    }

    @objc func hideBusyView() {
        let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController

        if let topViewController = topMostViewController as? TopViewController {
            topViewController.hideBusyView?()
            return
        }

        guard self.isLoadingShown else {
            return
        }

        // After fading out is completed, it will also be removed from the superview
        self.busyView.fadeOut()
    }

    // TODO: Show/hide/update methods can be called from any thread so we need to make sure to
    // explicitly dispatch the actions to the main thread. Once the wallet-rearch is completed, the
    // show/hide/update logic should not be dispatched to the main thread and instead callers should
    // guarantee to call these methods in the main thread.
    @objc func showBusyView(withLoadingText text: String) {
        let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController

        if let topViewController = topMostViewController as? TopViewController {
            topViewController.showBusyView?(withLoadingText: text)
            return
        }

        if AppCoordinator.shared.tabControllerManager.isSending() && ModalPresenter.shared.modalView != nil {
            print("Send progress modal is presented - will not show busy view")
            return
        }

        guard !self.isLoadingShown else {
            return
        }

        self.attachToMainWindow()

        self.busyView.labelBusy.text = text
        self.busyView.fadeIn()
    }

    @objc func updateBusyViewLoadingText(text: String) {
        let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController

        if let topViewController = topMostViewController as? TopViewController {
            topViewController.updateBusyViewLoadingText?(text)
            return
        }

        guard self.isLoadingShown else {
            return
        }

        self.busyView.labelBusy.text = text
    }

    private func attachToMainWindow() {
        guard !isLoadingShown else {
            print("Loading view already attached.")
            return
        }

        for window in UIApplication.shared.windows.reversed() {
            let onMainScreen    = window.screen == UIScreen.main
            let isVisible       = !window.isHidden && window.alpha > 0
            let levelIsNormal   = window.windowLevel == UIWindowLevelNormal
            let levelIsStatus   = window.windowLevel == UIWindowLevelStatusBar

            if onMainScreen && isVisible && (levelIsNormal || levelIsStatus) {
                window.addSubview(busyView)
                busyView.frame = window.bounds
                break
            }
        }
    }
}
