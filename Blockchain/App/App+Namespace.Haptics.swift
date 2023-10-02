import BlockchainNamespace
import Combine
import UIKit

final class AppHapticObserver: Client.Observer {

    unowned let app: AppProtocol

    private let generator = (
        notification: UINotificationFeedbackGenerator(), ()
    )

    private let notification: [Tag: UINotificationFeedbackGenerator.FeedbackType] = [
        blockchain.ui.device.haptic.feedback.notification.success[]: .success,
        blockchain.ui.device.haptic.feedback.notification.error[]: .error,
        blockchain.ui.device.haptic.feedback.notification.warning[]: .warning
    ]

    private let impact: [Tag: UIImpactFeedbackGenerator] = [
        blockchain.ui.device.haptic.feedback.impact.heavy[]: UIImpactFeedbackGenerator(style: .heavy),
        blockchain.ui.device.haptic.feedback.impact.medium[]: UIImpactFeedbackGenerator(style: .medium),
        blockchain.ui.device.haptic.feedback.impact.soft[]: UIImpactFeedbackGenerator(style: .soft),
        blockchain.ui.device.haptic.feedback.impact.rigid[]: UIImpactFeedbackGenerator(style: .rigid),
        blockchain.ui.device.haptic.feedback.impact.light[]: UIImpactFeedbackGenerator(style: .light)
    ]

    init(app: AppProtocol) {
        self.app = app
    }

    private var subscription = (
        impact: BlockchainEventSubscription?.none,
        notification: BlockchainEventSubscription?.none
    )

    func start() {
        subscription.impact = app.on(impact.keys) { [impact] event in
            for (type, feedback) in impact where event.tag.is(type) {
                return await feedback.impactOccurred()
            }
        }
        .start()
        subscription.notification = app.on(notification.keys) { [notification, generator] event in
            for (type, feedback) in notification where event.tag.is(type) {
                return await generator.notification.notificationOccurred(feedback)
            }
        }
        .start()
    }

    func stop() {
        subscription = (nil, nil)
    }
}
