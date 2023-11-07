// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

extension DependencyContainer {

    public static var featureDebugUI: DependencyContainer = if BuildFlag.isInternal {
        module {
            factory(tag: DebugScreenContext.tag) { DebugCoordinator() as DebugCoordinating }
        }
    } else {
        module {}
    }
}
