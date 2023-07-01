// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Examples
import SwiftUI
import ToolKit
import UIKit

public enum DebugScreenContext: String, Hashable {
    case tag
}

public protocol DebugCoordinating {
    /// Enables the debug menu which can be activated by shaking the device
    func enableDebugMenu(for window: UIWindow?)

    /// Removes the debug menu from being presented
    func disableDebugMenu()
}

final class DebugCoordinator: NSObject, DebugCoordinating {

    private var motion: AnyCancellable?

    private var notificationCenter: NotificationCenter = .default
    private var viewController: UIViewController?

    private var window: UIWindow?

    override init() {
        super.init()
        self.motion = notificationCenter.publisher(for: UIDevice.deviceDidShakeNotification)
            .sink(to: DebugCoordinator.shake, on: self)
    }

    func enableDebugMenu(for window: UIWindow?) {
        self.window = window
    }

    func disableDebugMenu() {
        window = nil
    }

    private func shake() {
        guard viewController == nil else {
            return dismiss()
        }
        let hosting = UIHostingController(rootView: DebugView(window: window).app(resolve()))
        hosting.presentationController?.delegate = self
        window?.rootViewController?.topMostViewController?.present(hosting, animated: true)
        viewController = hosting
    }

    private func dismiss() {
        viewController?.dismiss(animated: true)
        viewController = nil
    }
}

extension DebugCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewController = nil
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "UIDeviceDidShakeNotification")
}

extension UIWindow {

    @_dynamicReplacement(for: motionEnded)
    func _motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}
