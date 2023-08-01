// Similar to open source solutions like https://github.com/dkk/WrappingHStack but built with `Layout` protocol

import SwiftUI

@available(iOS 16.0, *)
public struct OverflowHStack: Layout {

    public var alignment: Alignment
    public var horizontalSpacing: CGFloat?
    public var verticalSpacing: CGFloat?

    @inlinable public init(
        alignment: Alignment = .center,
        horizontalSpacing: CGFloat? = nil,
        verticalSpacing: CGFloat? = nil
    ) {
        self.alignment = alignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .horizontal
        return properties
    }

    public struct Cache {
        var minSize: CGSize
        var rows: (Int, [Row])?
    }

    public func makeCache(subviews: Subviews) -> Cache {
        Cache(minSize: size(subviews: subviews))
    }

    public func updateCache(_ cache: inout Cache, subviews: Subviews) {
        cache.minSize = size(subviews: subviews)
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let rows = arrange(proposal: proposal, subviews: subviews, cache: &cache)
        if rows.isEmpty { return cache.minSize }
        let width = proposal.width ?? rows.map { $0.width }.reduce(.zero) { max($0, $1) }
        var height: CGFloat = .zero
        if let lastRow = rows.last {
            height = lastRow.offset + lastRow.height
        }
        return CGSize(width: width, height: height)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        let rows = arrange(proposal: proposal, subviews: subviews, cache: &cache)
        let anchor = UnitPoint(alignment)
        for row in rows {
            for element in row.elements {
                let x: CGFloat = element.offset + anchor.x * (bounds.width - row.width)
                let y: CGFloat = row.offset + anchor.y * (row.height - element.size.height)
                let point = CGPoint(x: x + bounds.minX, y: y + bounds.minY)
                subviews[element.index].place(at: point, anchor: .topLeading, proposal: proposal)
            }
        }
    }
}

@available(iOS 16.0, *)
extension OverflowHStack {

    struct Row {
        var elements: [(index: Int, size: CGSize, offset: CGFloat)] = []
        var offset: CGFloat = .zero
        var width: CGFloat = .zero
        var height: CGFloat = .zero
    }

    private func arrange(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> [Row] {
        guard subviews.isNotEmpty else { return [] }
        if cache.minSize.width > (proposal.width ?? .infinity), cache.minSize.height > (proposal.height ?? .infinity) {
            return []
        }
        let sizes = subviews.map { $0.sizeThatFits(proposal) }
        let hash = hash(proposal: proposal, sizes: sizes)
        if let (oldHash, oldRows) = cache.rows, oldHash == hash {
            return oldRows
        }
        var currentX = CGFloat.zero
        var currentRow = Row()
        var rows = [Row]()
        for ((index, subview), size) in zip(subviews.indexed(), sizes) {
            var spacing = CGFloat.zero
            if let previousIndex = currentRow.elements.last?.index {
                spacing = horizontalSpacing(subviews[previousIndex], subview)
            }
            if currentX + size.width + spacing > (proposal.width ?? .infinity), !currentRow.elements.isEmpty {
                currentRow.width = currentX
                rows.append(currentRow)
                currentRow = Row()
                spacing = .zero
                currentX = .zero
            }
            currentRow.elements.append((index, size, currentX + spacing))
            currentX += size.width + spacing
        }
        if !currentRow.elements.isEmpty {
            currentRow.width = currentX
            rows.append(currentRow)
        }
        var currentY = CGFloat.zero
        var previousMaxHeightIndex: Int?
        for index in rows.indices {
            let maxHeightIndex = rows[index].elements.max { $0.size.height < $1.size.height }!.index
            let size = sizes[maxHeightIndex]
            var spacing = CGFloat.zero
            if let previousMaxHeightIndex {
                spacing = verticalSpacing(subviews[previousMaxHeightIndex], subviews[maxHeightIndex])
            }
            rows[index].offset = currentY + spacing
            currentY += size.height + spacing
            rows[index].height = size.height
            previousMaxHeightIndex = maxHeightIndex
        }
        cache.rows = (hash, rows)
        return rows
    }

    private func hash(proposal: ProposedViewSize, sizes: [CGSize]) -> Int {
        let proposal = proposal.replacingUnspecifiedDimensions(by: .infinity)
        var hasher = Hasher()
        for size in [proposal] + sizes {
            hasher.combine(size.width)
            hasher.combine(size.height)
        }
        return hasher.finalize()
    }

    private func size(subviews: Subviews) -> CGSize {
        subviews
            .map { subview in subview.sizeThatFits(.zero) }
            .reduce(CGSize.zero) { largest, next in
                CGSize(width: max(largest.width, next.width), height: max(largest.height, next.height))
            }
    }

    private func horizontalSpacing(_ lhs: LayoutSubview, _ rhs: LayoutSubview) -> CGFloat {
        if let horizontalSpacing { return horizontalSpacing }
        return lhs.spacing.distance(to: rhs.spacing, along: .horizontal)
    }

    private func verticalSpacing(_ lhs: LayoutSubview, _ rhs: LayoutSubview) -> CGFloat {
        if let verticalSpacing { return verticalSpacing }
        return lhs.spacing.distance(to: rhs.spacing, along: .vertical)
    }
}

private extension CGSize {
    static var infinity: Self {
        .init(width: CGFloat.infinity, height: CGFloat.infinity)
    }
}

private extension UnitPoint {
    init(_ alignment: Alignment) {
        switch alignment {
        case .leading:
            self = .leading
        case .topLeading:
            self = .topLeading
        case .top:
            self = .top
        case .topTrailing:
            self = .topTrailing
        case .trailing:
            self = .trailing
        case .bottomTrailing:
            self = .bottomTrailing
        case .bottom:
            self = .bottom
        case .bottomLeading:
            self = .bottomLeading
        default:
            self = .center
        }
    }
}
