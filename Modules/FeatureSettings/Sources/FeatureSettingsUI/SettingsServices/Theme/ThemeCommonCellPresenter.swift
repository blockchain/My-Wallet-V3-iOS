// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitectureExtensions
import Dispatch
import FeatureSettingsDomain
import Foundation
import Localization

final class ThemeCommonCellPresenter: CommonCellPresenting {
    var isLoading: Bool = true

    private let app: AppProtocol

    var subtitle: AnyPublisher<LoadingState<String>, Never> {
        app.publisher(for: blockchain.app.settings.theme.mode, as: DarkModeSetting.self)
            .map(\.value)
            .map { theme -> LoadingState<String> in
                let theme = theme ?? DarkModeSetting.automatic
                return .loaded(next: theme.title)
            }
            .prepend(LoadingState<String>.loading)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [weak self] output in
                    self?.isLoading = output.isLoading
                }
            )
            .eraseToAnyPublisher()
    }

    init(app: AppProtocol) {
        self.app = app
    }
}
