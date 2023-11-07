// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Font {

    // MARK: Private

    private let type: FontType
    private let size: FontSize

    // MARK: Init

    public init(_ type: FontType, size: FontSize) {
        self.type = type
        self.size = size
    }

    public enum FontType {
        case branded(FontName)
    }

    public enum FontSize {
        case standard(StandardSize)
        case custom(Double)

        var value: Double {
            switch self {
            case .standard(let size):
                size.value
            case .custom(let value):
                value
            }
        }
    }

    public enum FontName: String {
        case montserratRegular = "Montserrat-Regular"
        case montserratSemiBold = "Montserrat-SemiBold"
        case montserratLight = "Montserrat-Light"
        case montserratMedium = "Montserrat-Medium"
        case montserratBold = "Montserrat-Bold"
    }

    public enum StandardSize {
        case small(Level)
        case medium(Level)
        case large(Level)
        case custom(Double)

        /// `Level` goes from high to low in terms of
        /// font sizes. In other words `h1` should be a larger
        /// font size than `h2`.
        public enum Level {
            case h1
            case h2
            case h3
            case h4
            case h5
        }
    }
}

extension Font.StandardSize {
    var value: Double {
        let isAboveSE = DevicePresenter.type > .superCompact
        switch self {
        case .small(let level):
            switch level {
            case .h1:
                return isAboveSE ? 16.0 : 13.0
            case .h2:
                return isAboveSE ? 15.0 : 12.0
            case .h3:
                return isAboveSE ? 14.0 : 11.0
            case .h4:
                return isAboveSE ? 13.0 : 11.0
            case .h5:
                return isAboveSE ? 11.0 : 10.0
            }
        case .medium(let level):
            switch level {
            case .h1:
                return isAboveSE ? 19.0 : 16.0
            case .h2:
                return isAboveSE ? 18.0 : 15.0
            case .h3, .h4, .h5:
                return isAboveSE ? 17.0 : 14.0
            }
        case .large(let level):
            switch level {
            case .h1:
                return isAboveSE ? 48.0 : 45.0
            case .h2:
                return isAboveSE ? 25.0 : 22.0
            case .h3:
                return isAboveSE ? 23.0 : 20.0
            case .h4:
                return isAboveSE ? 21.0 : 18.0
            case .h5:
                return isAboveSE ? 20.0 : 17.0
            }
        case .custom(let value):
            return value
        }
    }
}

extension Font {
    public var result: UIFont {
        switch type {
        case .branded(let fontName):
            guard let font = UIFont(name: fontName.rawValue, size: CGFloat(size.value)) else {
                assertionFailure("\(fontName.rawValue) font does not exist.")
                return UIFont.systemFont(ofSize: CGFloat(size.value))
            }
            return font
        }
    }
}
