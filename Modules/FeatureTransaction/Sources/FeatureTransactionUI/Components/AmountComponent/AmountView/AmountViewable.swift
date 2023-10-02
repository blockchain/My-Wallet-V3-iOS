// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import UIKit

/// A view that displays an Amount on the
/// `Enter Amount` screen.
/// At the time of this writing this includes a `SingleAmountView`
/// and an `AmountTranslationView`.
/// All views that show the amount that the user is entering must conform
/// to this protocol. By having a shared API across these views we can support
/// multiple ways of rendering what the user has entered.
public protocol AmountViewable {
    /// The view. Accessed by the `EnterAmountViewController`
    var view: UIView { get }

    /// Connect the inputs from the interactor to the view.
    /// - Parameter input: keypad entry input values.
    func connect(input: Driver<AmountPresenterInput>) -> Driver<AmountPresenterState>
}
