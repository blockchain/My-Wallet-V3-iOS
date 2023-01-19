// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

// TODO: Modularize to play nicer with different flows.
/// At the moment all the logic is centralized in the view model - there should be
/// another object to take up responsibility for logic.
public final class DigitPadViewModel {

    // MARK: - Types

    public enum PadType {
        case pin(maxCount: Int)
        case number
    }

    // MARK: - Properties

    /// Background color of the DigitPadView
    public let backgroundColor: UIColor

    /// The digits sorted by index (i.e 0 index represents zero-digit, 5 index represents the fifth digit)
    public let digitButtonViewModelArray: [DigitPadButtonViewModel]

    /// Backspace button
    public let backspaceButtonViewModel: DigitPadButtonViewModel

    /// Custom button, is located on the bottom-left side of the pad
    public let customButtonViewModel: DigitPadButtonViewModel

    /// Relay for bottom leading button taps
    private let customButtonTapRelay = PublishRelay<Void>()
    public var customButtonTapObservable: Observable<Void> {
        customButtonTapRelay.asObservable()
    }

    /// Tap observable for the backspace button
    public var backspaceButtonTapObservable: Observable<Void> {
        backspaceButtonViewModel.tapObservable
            .map { _ -> Void in () }
    }

    /// Relay for pin value. subscribe to it to get the pin stream
    public let valueRelay = BehaviorRelay<String>(value: "")
    public var valueObservable: Observable<String> {
        valueRelay.asObservable()
    }

    /// Observes the current length of the value
    public let valueLengthObservable: Observable<Int>

    /// Relay for tapping
    private let valueInsertedPublishRelay = PublishRelay<Void>()
    public var valueInsertedObservable: Observable<Void> {
        valueInsertedPublishRelay.asObservable()
    }

    /// Relay for the current digit pad remaining lock time
    private let remainingLockTimeRelay = PublishRelay<Int>()
    public var remainingLockTimeObservable: Observable<Int> {
        remainingLockTimeRelay.asObservable()
    }

    /// The raw `String` value
    public var value: String {
        valueRelay.value
    }

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        padType: PadType,
        customButtonViewModel: DigitPadButtonViewModel = .empty,
        contentTint: UIColor = .black,
        buttonHighlightColor: UIColor = .clear,
        backgroundColor: UIColor = .clear
    ) {

        let buttonBackground = DigitPadButtonViewModel.Background(highlightColor: buttonHighlightColor)

        // Initialize all buttons
        self.digitButtonViewModelArray = (0...9).map {
            DigitPadButtonViewModel(content: .label(text: "\($0)", tint: contentTint), background: buttonBackground)
        }

        self.backgroundColor = backgroundColor

        self.backspaceButtonViewModel = DigitPadButtonViewModel(
            content: .image(type: .backspace, tint: contentTint),
            background: buttonBackground
        )
        self.customButtonViewModel = customButtonViewModel

        // Digit count of the value
        self.valueLengthObservable = valueRelay.map(\.count).share(replay: 1)

        // Bind backspace to an action
        backspaceButtonViewModel.tapObservable
            .bind { [unowned self] _ in
                switch padType {
                case .pin:
                    let value = String(self.valueRelay.value.dropLast())
                    self.valueRelay.accept(value)
                case .number:
                    break
                }
            }
            .disposed(by: disposeBag)

        // Bind taps on the bottom left view to an action
        customButtonViewModel.tapObservable
            .map { _ in () }
            .bindAndCatch(to: customButtonTapRelay)
            .disposed(by: disposeBag)

        // Merge all digit observables into one stream of digits
        let buttons: [DigitPadButtonViewModel]
        switch padType {
        case .number:
            buttons = digitButtonViewModelArray + [customButtonViewModel]
        case .pin:
            buttons = digitButtonViewModelArray
        }
        let tapObservable = Observable.merge(buttons.map(\.tapObservable))

        tapObservable
            .bind { [unowned self] content in
                switch content {
                case .label(text: let digit, tint: _):
                    switch padType {
                    case .number:
                        self.valueRelay.accept(digit)
                        self.valueInsertedPublishRelay.accept(())
                    case .pin(maxCount: let count):
                        let value = "\(self.value)\(digit)"
                        if self.value.count < count {
                            self.valueRelay.accept(value)
                        }
                        if self.value.count == count {
                            self.valueInsertedPublishRelay.accept(())
                        }
                    }
                case .image, .none:
                    break
                }
            }
            .disposed(by: disposeBag)
    }

    /// Resets the pin to a given value
    public func reset(to value: String = "") {
        valueRelay.accept(value)
        valueInsertedPublishRelay.accept(())
    }

    /// Emits the updated lock time (seconds) due to new incorrect PIN attempt
    public func remainingLockTimeDidChange(remaining: Int) {
        remainingLockTimeRelay.accept(remaining)
    }
}
