// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

public struct SwitchViewModel {

    // MARK: - Types

    public struct Theme {
        public let fillColor: UIColor
        public let thumbTintColor: UIColor?

        public init(
            fillColor: UIColor,
            thumbTintColor: UIColor? = nil
        ) {
            self.fillColor = fillColor
            self.thumbTintColor = thumbTintColor
        }
    }

    // MARK: - Properties

    /// The theme of the view
    public var theme: Theme {
        get {
            Theme(
                fillColor: fillColorRelay.value,
                thumbTintColor: thumbTintColorRelay.value
            )
        }
        set {
            fillColorRelay.accept(newValue.fillColor)
            thumbTintColorRelay.accept(newValue.thumbTintColor)
        }
    }

    /// Fill color of the switch when it is enabled
    public var fillColor: Driver<UIColor> {
        fillColorRelay.asDriver()
    }

    /// Tint color of the thumb view
    public var thumbTintColor: Driver<UIColor?> {
        thumbTintColorRelay.asDriver()
    }

    public var isOn: Driver<Bool> {
        isOnRelay.asDriver()
    }

    public var isEnabled: Driver<Bool> {
        isEnabledRelay.asDriver()
    }

    /// Accessibility for the badge view
    public let accessibility: Accessibility

    /// The background color relay
    public let fillColorRelay = BehaviorRelay<UIColor>(value: .primaryButton)

    /// Streams events when the component is being tapped
    public let isSwitchedOnRelay = PublishRelay<Bool>()

    /// Whether or not the switch is on. Defaults to false
    public let isOnRelay = BehaviorRelay<Bool>(value: false)

    /// Whether or not the switch is enabled. Defaults to true
    public let isEnabledRelay = BehaviorRelay<Bool>(value: true)

    /// The fill color of the thumb portion of a `UISwitch`
    /// This is optional as this is the default behavior of a `UISwitch`
    public let thumbTintColorRelay = BehaviorRelay<UIColor?>(value: nil)

    private let disposeBag = DisposeBag()

    /// - parameter accessibility: accessibility for the view
    public init(
        accessibility: Accessibility,
        isOn: Bool = false,
        isEnabled: Bool = true
    ) {
        self.accessibility = accessibility
        isEnabledRelay.accept(isEnabled)
        isOnRelay.accept(isOn)
    }
}

extension SwitchViewModel {

    /// Returns a primary `SwitchViewModel` using `.primaryButton` as the
    /// fill color and the default thumb color.
    public static func primary(
        accessibilityId: String = Accessibility.Identifier.General.defaultSwitchView,
        isOn: Bool = false,
        isEnabled: Bool = true
    ) -> SwitchViewModel {
        var viewModel = SwitchViewModel(
            accessibility: .id(accessibilityId),
            isOn: isOn,
            isEnabled: isEnabled
        )
        viewModel.theme = Theme(
            fillColor: .semantic.primary
        )
        return viewModel
    }
}
