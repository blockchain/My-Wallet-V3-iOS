// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxSwift

final class MockBiometryProvider: BiometryProviding {
    var supportedBiometricsType: Biometry.BiometryType = .touchID
    let canAuthenticate: Result<Biometry.BiometryType, Biometry.EvaluationError>
    var configuredType: Biometry.BiometryType
    let configurationStatus: Biometry.Status

    private let authenticatesSuccessfully: Bool

    init(
        authenticatesSuccessfully: Bool,
        canAuthenticate: Result<Biometry.BiometryType, Biometry.EvaluationError>,
        configuredType: Biometry.BiometryType,
        configurationStatus: Biometry.Status
    ) {
        self.authenticatesSuccessfully = authenticatesSuccessfully
        self.canAuthenticate = canAuthenticate
        self.configuredType = configuredType
        self.configurationStatus = configurationStatus
    }

    func authenticate(reason: Biometry.Reason) -> Single<Void> {
        switch canAuthenticate {
        case .success:
            .just(())
        case .failure(let error):
            .error(error)
        }
    }
}
