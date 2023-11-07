// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary

/// Describes the type of content inside the `CompositeStatusView`
public enum CompositeStatusViewType: Equatable {

    public struct Composite: Equatable {
        public enum BaseViewType: Equatable {
            case badgeImageViewModel(BadgeImageViewModel)
            case image(ImageLocation)
            case templateImage(name: String, bundle: Bundle, templateColor: UIColor)
            case text(String)
        }

        public struct SideViewAttributes: Equatable {
            public enum ViewType: Equatable {
                case image(ImageLocation)
                case loader
                case none
            }

            public enum Position: Equatable {
                case radiusDistanceFromCenter
                case rightCorner
            }

            static var none: SideViewAttributes {
                .init(type: .none, position: .radiusDistanceFromCenter)
            }

            let type: ViewType
            let position: Position

            public init(type: ViewType, position: Position) {
                self.type = type
                self.position = position
            }
        }

        let baseViewType: BaseViewType
        let sideViewAttributes: SideViewAttributes
        let backgroundColor: UIColor
        let cornerRadiusRatio: CGFloat

        public init(
            baseViewType: BaseViewType,
            sideViewAttributes: SideViewAttributes,
            backgroundColor: UIColor = .clear,
            cornerRadiusRatio: CGFloat = 0
        ) {
            self.baseViewType = baseViewType
            self.sideViewAttributes = sideViewAttributes
            self.cornerRadiusRatio = cornerRadiusRatio
            self.backgroundColor = backgroundColor
        }
    }

    case loader
    case image(ImageLocation)
    case composite(Composite)
    case none

    var cornerRadiusRatio: CGFloat {
        switch self {
        case .composite(let composite):
            composite.cornerRadiusRatio
        case .loader,
             .image,
             .none:
            0
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .composite(let composite):
            composite.backgroundColor
        case .loader,
             .image,
             .none:
            .clear
        }
    }
}
