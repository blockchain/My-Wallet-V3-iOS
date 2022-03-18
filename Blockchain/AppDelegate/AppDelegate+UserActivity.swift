// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Firebase
import UIKit

extension AppDelegate {
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        let handled = DynamicLinks.dynamicLinks()
            .handleUniversalLink(userActivity.webpageURL!) { dynamiclink, _ in
                guard let url = dynamiclink?.url else { return }
                app.post(
                    event: blockchain.app.process.deep_link,
                    context: [blockchain.app.process.deep_link.url[]: url]
                )
            }

        viewStore.send(.appDelegate(.userActivity(userActivity)))

        guard handled else {
            return handle(userActivity: userActivity)
        }

        return handled
    }

    @discardableResult private func handle(userActivity: NSUserActivity) -> Bool {
        if let url = userActivity.webpageURL {
            app.post(
                event: blockchain.app.process.deep_link,
                context: [blockchain.app.process.deep_link.url[]: url]
            )
        }
        return viewStore.appSettings.userActivityHandled
    }
}
