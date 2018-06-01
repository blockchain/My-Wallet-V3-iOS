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

        guard self.isLoadingShown else {
            print("[LoadingViewPresenter]: Cannot hide busy view, already not shown.")
            return
        }

        // After fading out is completed, it will also be removed from the superview
        self.busyView.fadeOut()
    }

    @objc var currentLoadingText: String? {
        return self.busyView.labelBusy.text
    }

    @objc func showBusyView(withLoadingText text: String) {

        if AppCoordinator.shared.tabControllerManager.isSending() && ModalPresenter.shared.modalView != nil {
            print("Send progress modal is presented - will not show busy view")
            return
        }

        self.busyView.labelBusy.text = text

        guard !self.isLoadingShown else {
            print("[LoadingViewPresenter]: cannot show busy view already shown.")
            return
        }

        self.attachToMainWindow()

        self.busyView.fadeIn()
    }

    @objc func updateBusyViewLoadingText(text: String) {
        let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController

        if let topViewController = topMostViewController as? TopViewController {
            topViewController.updateBusyViewLoadingText?(text)
            return
        }

        guard self.isLoadingShown else {
            print("[LoadingViewPresenter]: Cannot update busy view with text: '\(text)', busy view should be shown.")
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
