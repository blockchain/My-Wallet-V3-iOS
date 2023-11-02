// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// The type of the presentation
public enum PresentationType {

    /// Presents a modal over a given view controller
    case modal(from: ViewControllerAPI)

    /// Presents a modal over the top most view controller
    case modalOverTopMost

    /// Navigates from a given view controller
    case navigation(from: ViewControllerAPI)

    /// Navigates from the current view controller, pushes the controller on the stack
    case navigationFromCurrent

    public var leadingButton: Screen.Style.LeadingButton {
        isModal ? .close : .back
    }

    public var isModal: Bool {
        switch self {
        case .modal, .modalOverTopMost:
            true
        case .navigation, .navigationFromCurrent:
            false
        }
    }
}
