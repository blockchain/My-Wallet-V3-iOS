#if canImport(UIKit)
@_exported import UIKit
#endif

extension UIView {

    public func bfs<T>(_: T.Type = T.self) -> T? {
        if let value = subviews.compactMap({ $0 as? T }).first {
            return value
        }
        for child in subviews {
            if let value = child.bfs(T.self) { return value }
        }
        return nil
    }

    public func dfs<T>(_: T.Type = T.self) -> T? {
        for child in subviews {
            if let value = child as? T { return value }
            if let value = child.dfs(T.self) { return value }
        }
        return nil
    }
}
