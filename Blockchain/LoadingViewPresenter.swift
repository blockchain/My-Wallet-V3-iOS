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

    private lazy var busyView: BCFadeView = {
        let busyView = BCFadeView(frame: UIScreen.main.bounds)
        busyView.alpha = 0.0
        return busyView
    }()

    /// sharedInstance function declared so that the LoadingViewPresenter singleton can be accessed
    /// from Obj-C. Should deprecate this once all Obj-c references have been removed.
    @objc class func sharedInstance() -> LoadingViewPresenter { return shared }

    private override init() {
        super.init()
    }

    func initialize() {
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(busyView)
    }

    @objc func hideBusyView() {
        let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController

        if let topViewController = topMostViewController as? TopViewController {
            topViewController.hideBusyView?()
            return
        }

        if busyView.alpha == 1.0 {
            busyView.fadeOut()
        }
    }

    @objc func showBusyView(withLoadingText text: String) {
        let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController

        if let topViewController = topMostViewController as? TopViewController {
            topViewController.showBusyView?(withLoadingText: text)
            return
        }

        // TODO: state check for pinEntryViewController should not be here
        if let pinEntryViewController = topMostViewController as? PEPinEntryController {
            if pinEntryViewController.inSettings &&
                text != LocalizationConstants.syncingWallet &&
                text != LocalizationConstants.verifying {
                print("Verify optional PIN view is presented - will not update busy views unless verifying or syncing")
                return
            }
        }

        if AppCoordinator.shared.tabControllerManager.isSending() && ModalPresenter.shared.modalView != nil {
            print("Send progress modal is presented - will not show busy view")
            return
        }

        busyView.labelBusy.text = text

        UIApplication.shared.keyWindow?.rootViewController?.view.bringSubview(toFront: busyView)

        if busyView.alpha < 1.0 {
            busyView.fadeIn()
        }
    }

    @objc func updateBusyViewLoadingText(text: String) {
        let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController

        if let topViewController = topMostViewController as? TopViewController {
            topViewController.updateBusyViewLoadingText?(text)
            return
        }

        // TODO: state check for pinEntryViewController should not be here
        if let pinEntryViewController = topMostViewController as? PEPinEntryController {
            if pinEntryViewController.inSettings &&
                text != LocalizationConstants.syncingWallet &&
                text != LocalizationConstants.verifying {
                print("Verify optional PIN view is presented - will not update busy views unless verifying or syncing")
                return
            }
        }

        if busyView.alpha == 1.0 {
            busyView.labelBusy.text = text
        }
    }
}
