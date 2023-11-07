// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RxCocoa
import RxSwift

public struct DigitPadButtonViewModel {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.DigitPad
    private typealias LocalizedString = LocalizationConstants.Accessibility.DigitPad

    public enum Content {
        public enum Image {
            case touchId
            case faceId
            case backspace

            /// The computed image value corresponding to `self`.
            var image: UIImage {
                let name: String = switch self {
                case .backspace:
                    "backspace-icon"
                case .faceId:
                    "face_id_icon"
                case .touchId:
                    "touch_id_icon"
                }
                return UIImage(named: name)!.withRenderingMode(.alwaysTemplate)
            }

            /// Accessibility id for image
            var accessibility: Accessibility {
                let accessibility: Accessibility = switch self {
                case .backspace:
                    Accessibility(
                        id: AccessibilityId.backspaceButton,
                        label: LocalizedString.backspace
                    )
                case .faceId:
                    Accessibility(
                        id: AccessibilityId.faceIdButton,
                        label: LocalizedString.faceId
                    )
                case .touchId:
                    Accessibility(
                        id: AccessibilityId.touchIdButton,
                        label: LocalizedString.touchId
                    )
                }
                return accessibility
            }
        }

        /// Image based button
        case image(type: Image, tint: UIColor)

        /// Text based button
        case label(text: String, tint: UIColor)

        /// Just an empty content
        case none

        /// Tint of the content
        var tint: UIColor {
            switch self {
            case .image(type: _, tint: let color):
                color
            case .label(text: _, tint: let color):
                color
            case .none:
                .clear
            }
        }

        /// Accessibility for any nested value
        var accessibility: Accessibility {
            switch self {
            case .image(type: let image, tint: _):
                image.accessibility
            case .label(text: let value, tint: _):
                .id("\(AccessibilityId.digitButtonFormat)\(value)")
            case .none:
                .none
            }
        }
    }

    public struct Background {
        let cornerRadius: CGFloat
        let highlightColor: UIColor

        /// Just a clear background
        public static var clear: Background {
            Background(cornerRadius: 0, highlightColor: .clear)
        }

        public init(cornerRadius: CGFloat = 4, highlightColor: UIColor) {
            self.cornerRadius = cornerRadius
            self.highlightColor = highlightColor
        }
    }

    public static var empty: DigitPadButtonViewModel {
        DigitPadButtonViewModel(content: .none, background: .clear)
    }

    // MARK: - Properties

    let content: Content
    let background: Background

    private let tapRelay = PublishRelay<Content>()
    var tapObservable: Observable<Content> {
        tapRelay.asObservable()
    }

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(content: Content, background: Background) {
        self.content = content
        self.background = background
        tapRelay
            .bind { _ in
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
            }
            .disposed(by: disposeBag)
    }

    /// Invocation makes `tapRelay` to stream a new value
    func tap() {
        tapRelay.accept(content)
    }
}
