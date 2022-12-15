// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI
import UIComponentsKit

/// A view that shows a text showing how many items out of a set are "complete" where the text is
/// inscribed into a progress indicator providing a visual representation to the same information.
public struct CountedProgressView: View {

    public enum Size {
        case normal
        case large
    }

    public let size: Size
    public let completedItemsCount: Int
    public let totalItemsCount: Int
    public let lineWidth: Length
    public let strokeColor: Color
    public let backgroundColor: Color

    public var progressPercentage: Float {
        guard totalItemsCount > .zero else {
            return .zero
        }
        return Float(completedItemsCount) / Float(totalItemsCount)
    }

    public init(
        size: Size = .normal,
        completedItemsCount: Int,
        totalItemsCount: Int,
        lineWidth: Length = Size.normal.lineWidth,
        strokeColor: Color = .semantic.primary,
        backgroundColor: Color = .semantic.light
    ) {
        self.size = size
        self.completedItemsCount = completedItemsCount
        self.totalItemsCount = totalItemsCount
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.backgroundColor = backgroundColor
    }

    public init(
        size: Size = .normal,
        completedItemsCount: Int,
        totalItemsCount: Int,
        strokeColor: Color = .semantic.primary,
        backgroundColor: Color = .semantic.light
    ) {
        self.size = size
        self.completedItemsCount = completedItemsCount
        self.totalItemsCount = totalItemsCount
        self.lineWidth = size.lineWidth
        self.strokeColor = strokeColor
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        ProgressView(value: progressPercentage)
            .progressViewStyle(
                IndeterminateProgressStyle(
                    stroke: strokeColor,
                    background: backgroundColor,
                    lineWidth: lineWidth,
                    indeterminate: false,
                    lineCap: .round
                )
            )
            .inscribed(
                Text("\(completedItemsCount)/\(totalItemsCount)")
                    .typography(size.typography)
                    .foregroundColor(.semantic.primary)
            )
            .frame(width: size.edgeSize, height: size.edgeSize)
    }
}

struct CountedProgressView_Previews: PreviewProvider {

    static var previews: some View {
        CountedProgressView(completedItemsCount: 0, totalItemsCount: 3)
        CountedProgressView(completedItemsCount: 1, totalItemsCount: 3)
        CountedProgressView(completedItemsCount: 2, totalItemsCount: 3)
        CountedProgressView(completedItemsCount: 3, totalItemsCount: 3)
    }
}

extension CountedProgressView.Size {
    var edgeSize: CGFloat {
        switch self {
        case .normal:
            return 48
        case .large:
            return 69
        }
    }

    var typography: Typography {
        switch self {
        case .normal:
            return .paragraph2
        case .large:
            return .title2
        }
    }

    public var lineWidth: Length {
        switch self {
        case .normal:
            return .pt(4)
        case .large:
            return .pt(6)
        }
    }
}
