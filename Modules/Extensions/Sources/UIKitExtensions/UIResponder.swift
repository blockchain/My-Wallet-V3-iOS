#if canImport(UIKit)
import UIKit

extension UIResponder {

    public var responderViewController: UIViewController? {
        if let vc = self as? UIViewController {
            vc
        } else if let nextResponder = next {
            nextResponder.responderViewController
        } else {
            nil
        }
    }
}
#endif
