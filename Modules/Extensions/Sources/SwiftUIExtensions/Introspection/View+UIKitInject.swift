/// Extracted from Introspect library
/// https://github.com/siteline/SwiftUI-Introspect

#if canImport(UIKit)

import SwiftUI

extension View {
    @ViewBuilder
    func inject(_ view: some View) -> some View {
        overlay(view.frame(width: 0, height: 0))
    }
}

// MARK: View Finding

enum Introspect {
    /// Finds the view host of a specific view.
    static func findViewHost(_ view: UIView) -> UIView? {
        var superview = view.superview
        while let s = superview {
            if NSStringFromClass(type(of: s)).contains("ViewHost") {
                return s
            }
            superview = s.superview
        }
        return nil
    }

    /// Finds a previous sibling that contains a view of the specified type.
    static func previousSibling<AnyViewType: UIView>(
        containing type: AnyViewType.Type,
        from entry: UIView
    ) -> AnyViewType? {

        guard let superview = entry.superview,
              let entryIndex = superview.subviews.firstIndex(of: entry),
              entryIndex > 0
        else {
            return nil
        }

        for subview in superview.subviews[0..<entryIndex].reversed() {
            if let typed = findChild(ofType: type, in: subview) {
                return typed
            }
        }

        return nil
    }

    /// Finds a subview of the specified type.
    /// This method will recursively look for this view.
    static func findChild<AnyViewType: UIView>(
        ofType type: AnyViewType.Type,
        in root: UIView
    ) -> AnyViewType? {
        for subview in root.subviews {
            if let typed = subview as? AnyViewType {
                return typed
            } else if let typed = findChild(ofType: type, in: subview) {
                return typed
            }
        }
        return nil
    }

    static func previousSibling<AnyViewControllerType: UIViewController>(
        ofType type: AnyViewControllerType.Type,
        from entry: UIViewController
    ) -> AnyViewControllerType? {

        guard let parent = entry.parent,
              let entryIndex = parent.children.firstIndex(of: entry),
              entryIndex > 0
        else {
            return nil
        }

        for child in parent.children[0..<entryIndex].reversed() {
            if let typed = child as? AnyViewControllerType {
                return typed
            }
        }

        return nil
    }

    static func findAncestor<AnyViewType: UIView>(ofType type: AnyViewType.Type, from entry: UIView) -> AnyViewType? {
        var superview = entry.superview
        while let s = superview {
            if let typed = s as? AnyViewType {
                return typed
            }
            superview = s.superview
        }
        return nil
    }
}

#endif
