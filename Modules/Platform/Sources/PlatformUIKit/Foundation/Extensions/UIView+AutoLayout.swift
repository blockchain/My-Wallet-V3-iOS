// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit
extension UILayoutPriority {
    /// Owns `999` as value, one prior to the highest (`1000`) that can still be changed w/o crashing
    public static let penultimateHigh = UILayoutPriority(rawValue: 999)
    public static let penultimateLow = UILayoutPriority(rawValue: 1)

    public static func += (lhs: inout UILayoutPriority, value: Float) throws {
        lhs = UILayoutPriority(rawValue: lhs.rawValue + value)
    }

    public static func -= (lhs: inout UILayoutPriority, value: Float) throws {
        lhs = UILayoutPriority(rawValue: lhs.rawValue - value)
    }
}

extension UIView {

    // MARK: - Types

    public typealias Priority = UILayoutPriority
    public typealias Attribute = NSLayoutConstraint.Attribute
    public typealias Relation = NSLayoutConstraint.Relation
    public typealias Constraints = [Attribute: NSLayoutConstraint]

    /// A frame that comprise a center and size
    public struct Frame {
        public let center: LayoutForm.Constraints
        public let size: LayoutForm.Constraints
    }

    /// A layout from
    public enum LayoutForm {

        /// Center layout form
        case center

        /// Size layout form
        case size

        public struct Constraints {
            public let horizontal: NSLayoutConstraint
            public let vertical: NSLayoutConstraint

            public func setConstant(horizontal: CGFloat, vertical: CGFloat) {
                self.horizontal.constant = horizontal
                self.vertical.constant = vertical
            }

            public func set(priority: UILayoutPriority) {
                horizontal.priority = priority
                vertical.priority = priority
            }
        }

        fileprivate var attributes: (horizontal: Attribute, vertical: Attribute) {
            let horizontal: Attribute
            let vertical: Attribute

            switch self {
            case .size:
                horizontal = .width
                vertical = .height
            case .center:
                horizontal = .centerX
                vertical = .centerY
            }
            return (horizontal: horizontal, vertical: vertical)
        }
    }

    /// Describes an axis
    public enum Axis {
        case horizontal
        case vertical

        public struct Constraints {
            public let leading: NSLayoutConstraint
            public let trailing: NSLayoutConstraint

            public func set(offset: CGFloat) {
                leading.constant = offset
                trailing.constant = -offset
            }
        }

        fileprivate var attributes: (leading: Attribute, trailing: Attribute) {
            let leading: Attribute
            let trailing: Attribute

            switch self {
            case .horizontal:
                leading = .leading
                trailing = .trailing
            case .vertical:
                leading = .top
                trailing = .bottom
            }
            return (leading: leading, trailing: trailing)
        }
    }

    public enum Dimension {
        case width
        case height

        fileprivate var attribute: Attribute {
            switch self {
            case .width:
                .width
            case .height:
                .height
            }
        }
    }

    // MARK: - Content Hugging Priority

    public var horizontalContentHuggingPriority: Priority {
        get {
            contentHuggingPriority(for: .horizontal)
        }
        set {
            setContentHuggingPriority(newValue, for: .horizontal)
        }
    }

    public var verticalContentHuggingPriority: Priority {
        get {
            contentHuggingPriority(for: .vertical)
        }
        set {
            setContentHuggingPriority(newValue, for: .vertical)
        }
    }

    public var contentHuggingPriority: (horizontal: Priority, vertical: Priority) {
        get {
            (horizontalContentHuggingPriority, verticalContentHuggingPriority)
        }
        set {
            horizontalContentHuggingPriority = newValue.horizontal
            verticalContentHuggingPriority = newValue.vertical
        }
    }

    // MARK: - Content Compression Resistance Priority

    public var verticalContentCompressionResistancePriority: Priority {
        get {
            contentCompressionResistancePriority(for: .vertical)
        }
        set {
            setContentCompressionResistancePriority(newValue, for: .vertical)
        }
    }

    public var horizontalContentCompressionResistancePriority: Priority {
        get {
            contentCompressionResistancePriority(for: .horizontal)
        }
        set {
            setContentCompressionResistancePriority(newValue, for: .horizontal)
        }
    }

    public var contentCompressionResistancePriority: (horizontal: Priority, vertical: Priority) {
        get {
            (horizontalContentCompressionResistancePriority, verticalContentCompressionResistancePriority)
        }
        set {
            horizontalContentCompressionResistancePriority = newValue.horizontal
            verticalContentCompressionResistancePriority = newValue.vertical
        }
    }

    public func maximizeResistanceAndHuggingPriorities() {
        contentCompressionResistancePriority = (horizontal: .required, vertical: .required)
        contentHuggingPriority = (horizontal: .required, vertical: .required)
    }

    /// Layout width and height to a specific value
    @discardableResult
    public func layout(
        size: CGSize,
        relation: Relation = .equal,
        ratio: CGFloat = 1.0,
        priority: Priority = .required
    ) -> LayoutForm.Constraints {
        let width = layout(dimension: .width, to: size.width, relation: relation, ratio: ratio, priority: priority)
        let height = layout(dimension: .height, to: size.height, relation: relation, ratio: ratio, priority: priority)
        return .init(horizontal: width, vertical: height)
    }

    /// Layout width or height to a specific value
    @discardableResult
    public func layout(
        dimension: Dimension,
        to value: CGFloat,
        relation: Relation = .equal,
        ratio: CGFloat = 1.0,
        priority: UILayoutPriority = .required,
        activate: Bool = true
    ) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: dimension.attribute,
            relatedBy: relation,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: ratio,
            constant: value
        )
        constraint.priority = priority
        constraint.isActive = activate
        return constraint
    }

    @discardableResult
    public func layout(
        edge: Attribute? = nil,
        to otherEdge: Attribute,
        of view: UIView,
        relation: Relation = .equal,
        ratio: CGFloat = 1.0,
        offset: CGFloat = 0,
        priority: UILayoutPriority = .required,
        activate: Bool = true
    ) -> NSLayoutConstraint? {
        guard prepareForAutoLayout() else {
            assertionFailure("\(String(describing: self)) Error in func: \(#function)")
            return nil
        }

        let constraint = NSLayoutConstraint(
            item: self,
            attribute: edge ?? otherEdge,
            relatedBy: relation,
            toItem: view,
            attribute: otherEdge,
            multiplier: ratio,
            constant: offset
        )
        constraint.priority = priority
        constraint.isActive = activate
        return constraint
    }

    @discardableResult
    public func layout(
        edges: Attribute...,
        to view: UIView,
        relation: Relation = .equal,
        ratio: CGFloat = 1.0,
        offset: CGFloat = 0,
        usesSafeAreaLayoutGuide: Bool = false,
        priority: UILayoutPriority = .required
    ) -> Constraints {
        var constraints: Constraints = [:]
        guard prepareForAutoLayout() else {
            assertionFailure("\(String(describing: self)) Error in func: \(#function)")
            return constraints
        }
        let uniqueEdges = Set(edges)
        let secondItem: Any = if usesSafeAreaLayoutGuide {
            view.safeAreaLayoutGuide
        } else {
            view
        }

        for edge in uniqueEdges {
            let constraint = NSLayoutConstraint(
                item: self,
                attribute: edge,
                relatedBy: relation,
                toItem: secondItem,
                attribute: edge,
                multiplier: ratio,
                constant: offset
            )
            constraint.priority = priority
            constraint.isActive = true
            constraints[edge] = constraint
        }
        return constraints
    }

    @discardableResult
    public func layoutToSuperview(
        _ edge: Attribute,
        relation: Relation = .equal,
        usesSafeAreaLayoutGuide: Bool = false,
        ratio: CGFloat = 1,
        offset: CGFloat = 0,
        priority: Priority = .required
    ) -> NSLayoutConstraint? {
        guard prepareForAutoLayout() else {
            assertionFailure("\(String(describing: self)) Error in func: \(#function)")
            return nil
        }
        let superview = superview!

        let secondItem: Any = if usesSafeAreaLayoutGuide {
            superview.safeAreaLayoutGuide
        } else {
            superview
        }

        let constraint = NSLayoutConstraint(
            item: self,
            attribute: edge,
            relatedBy: relation,
            toItem: secondItem,
            attribute: edge,
            multiplier: ratio,
            constant: offset
        )
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func layoutToSuperview(
        _ edges: Attribute...,
        relation: Relation = .equal,
        usesSafeAreaLayoutGuide: Bool = false,
        ratio: CGFloat = 1,
        offset: CGFloat = 0,
        priority: Priority = .required
    ) -> Constraints {
        var constraints: Constraints = [:]
        guard !edges.isEmpty, prepareForAutoLayout() else {
            return constraints
        }
        let superview = superview!

        let secondItem: Any = if usesSafeAreaLayoutGuide {
            superview.safeAreaLayoutGuide
        } else {
            superview
        }

        let uniqueEdges = Set(edges)
        for edge in uniqueEdges {
            let constraint = NSLayoutConstraint(
                item: self,
                attribute: edge,
                relatedBy: relation,
                toItem: secondItem,
                attribute: edge,
                multiplier: ratio,
                constant: offset
            )
            constraint.priority = priority
            constraint.isActive = true
            constraints[edge] = constraint
        }
        return constraints
    }

    @discardableResult
    public func layoutToSuperview(
        axis: Axis,
        usesSafeAreaLayoutGuide: Bool = false,
        offset: CGFloat = 0,
        priority: Priority = .required
    ) -> Axis.Constraints? {
        let attributes = axis.attributes
        guard let leading = layoutToSuperview(
            attributes.leading,
            usesSafeAreaLayoutGuide: usesSafeAreaLayoutGuide,
            offset: offset,
            priority: priority
        ) else {
            return nil
        }
        guard let trailing = layoutToSuperview(
            attributes.trailing,
            usesSafeAreaLayoutGuide: usesSafeAreaLayoutGuide,
            offset: -offset,
            priority: priority
        ) else {
            return nil
        }
        return .init(leading: leading, trailing: trailing)
    }

    @discardableResult
    public func layoutToSuperviewCenter(priority: Priority = .required) -> LayoutForm.Constraints? {
        guard let centerX = layoutToSuperview(.centerX, priority: priority) else {
            return nil
        }
        guard let centerY = layoutToSuperview(.centerY, priority: priority) else {
            return nil
        }
        return .init(horizontal: centerX, vertical: centerY)
    }

    @discardableResult
    public func layoutToSuperviewSize(
        usesSafeAreaLayoutGuide: Bool = false,
        ratio: CGFloat = 1,
        offset: CGFloat = 0,
        priority: Priority = .required
    ) -> LayoutForm.Constraints? {
        guard let width = layoutToSuperview(
            .width,
            usesSafeAreaLayoutGuide: usesSafeAreaLayoutGuide,
            ratio: ratio,
            offset: offset,
            priority: priority
        ) else {
            return nil
        }
        guard let height = layoutToSuperview(
            .height,
            usesSafeAreaLayoutGuide: usesSafeAreaLayoutGuide,
            ratio: ratio,
            offset: offset,
            priority: priority
        ) else {
            return nil
        }
        return .init(horizontal: width, vertical: height)
    }

    @discardableResult
    public func fillSuperview(usesSafeAreaLayoutGuide: Bool = false) -> Frame? {
        guard let center = layoutToSuperviewCenter() else { return nil }
        guard let size = layoutToSuperviewSize(usesSafeAreaLayoutGuide: usesSafeAreaLayoutGuide) else { return nil }
        return .init(center: center, size: size)
    }

    // MARK: - Private Methods

    private func prepareForAutoLayout() -> Bool {
        guard superview != nil else {
            assertionFailure("\(String(describing: self)):\(#function) - superview is unexpectedly nullified")
            return false
        }
        translatesAutoresizingMaskIntoConstraints = false
        return true
    }
}
