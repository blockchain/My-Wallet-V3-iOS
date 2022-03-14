// Copyright © Blockchain Luxembourg S.A. All rights reserved.

class BounceButton: UIButton {

    fileprivate var scaleUpAnimationDuration: TimeInterval = 0.05

    fileprivate var scaleDownAnimationDuration: TimeInterval = 0.02

    fileprivate var selectedScale: CGAffineTransform = CGAffineTransform(scaleX: 1.5, y: 1.5)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        scaleUp()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        bounds.contains(point) ? scaleUp() : scaleDown()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        scaleDown()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        scaleDown()
    }

    // MARK: Private

    fileprivate func scaleUp(_ block: (() -> Void)? = nil) {
        guard transform != selectedScale else { return }
        UIView.animate(
            withDuration: scaleUpAnimationDuration,
            delay: 0.0,
            options: [.curveEaseIn],
            animations: {
                self.transform = self.selectedScale
            },
            completion: nil
        )
    }

    fileprivate func scaleDown() {
        guard transform != .identity else { return }
        UIView.animate(
            withDuration: scaleDownAnimationDuration,
            delay: 0.0,
            options: [],
            animations: {
                self.transform = .identity
            }, completion: nil
        )
    }
}
