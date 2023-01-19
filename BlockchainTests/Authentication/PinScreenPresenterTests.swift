// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainApp
@testable import FeaturePin
@testable import PlatformKit

import Foundation
import PlatformUIKit
import RxBlocking
import RxSwift
import ToolKit
import XCTest

/// Tests the pin screen presenter
final class PinScreenPresenterTests: XCTestCase {

    private var biometryProvider: BiometryProviding!
    private var appSettings: MockBlockchainSettingsApp!

    override func setUp() {
        super.setUp()
        appSettings = MockBlockchainSettingsApp(pinKey: "key")
        biometryProvider = MockBiometryProvider(
            authenticatesSuccessfully: true,
            canAuthenticate: .failure(.notAllowed),
            configuredType: .none,
            configurationStatus: .unconfigurable(Biometry.EvaluationError.notAllowed)
        )
    }

    override func tearDown() {
        biometryProvider = nil
        appSettings = nil
        super.tearDown()
    }

    // Tests a standard authentication case on login
    func testAuthenticationSuccessOnLogin() {
        let flow = PinRouting.Flow.authenticate(from: .background, logoutRouting: {})
        let useCase = PinScreenUseCase.authenticateOnLogin
        let interactor = MockPinInteractor()
        let forward: PinRouting.RoutingType.Forward = { input in
            XCTAssertEqual(input.password, interactor.expectedPassword)
        }

        let presenter = PinScreenPresenter(
            useCase: useCase,
            flow: flow,
            interactor: interactor,
            biometryProvider: biometryProvider,
            appSettings: appSettings,
            cloudSettings: appSettings,
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: CrashlyticsRecorder(),
            credentialsStore: CredentialsStoreAPIMock(),
            backwardRouting: nil,
            forwardRouting: forward,
            performEffect: { _ in },
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )
        presenter.reset(to: "5740")

        do {
            _ = try presenter.authenticatePin().toBlocking().first()
        } catch {
            XCTFail("expected success. got \(error) instead")
        }
    }

    // Tests a case where the pin inserted is detected as incorrect by the interactor
    func testAuthenticationPinIncorrectOnLogin() {
        let flow = PinRouting.Flow.authenticate(from: .background, logoutRouting: {})
        let useCase = PinScreenUseCase.authenticateOnLogin
        let interactor = MockPinInteractor(expectedError: .incorrectPin("pin incorrect", 0, nil))
        let forward: PinRouting.RoutingType.Forward = { _ in
            XCTFail("expected an error \(PinError.incorrectPin). `forwardRouting` was invoked instead")
        }
        let presenter = PinScreenPresenter(
            useCase: useCase,
            flow: flow,
            interactor: interactor,
            biometryProvider: biometryProvider,
            appSettings: appSettings,
            cloudSettings: appSettings,
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: CrashlyticsRecorder(),
            credentialsStore: CredentialsStoreAPIMock(),
            backwardRouting: nil,
            forwardRouting: forward,
            performEffect: { _ in },
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )
        presenter.reset(to: "5740")

        do {
            _ = try presenter.authenticatePin().toBlocking().first()
            XCTFail("expected \(PinError.incorrectPin). got success instead")
        } catch {
            guard case PinError.incorrectPin = error else {
                XCTFail("expected \(PinError.incorrectPin). got \(error) instead")
                return
            }
        }
    }

    // MARK: - Tests PIN creation

    // Test first phase of pin entry during creation process
    func testCreationSuccessOnFirstEntry() {
        let flow = PinRouting.Flow.create(parent: .init(nil))
        let useCase = PinScreenUseCase.select(previousPin: nil)
        let interactor = MockPinInteractor()
        let forward: PinRouting.RoutingType.Forward = { _ in
        }
        let presenter = PinScreenPresenter(
            useCase: useCase,
            flow: flow,
            interactor: interactor,
            biometryProvider: biometryProvider,
            appSettings: appSettings,
            cloudSettings: appSettings,
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: CrashlyticsRecorder(),
            credentialsStore: CredentialsStoreAPIMock(),
            backwardRouting: nil,
            forwardRouting: forward,
            performEffect: { _ in },
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )
        presenter.reset(to: "5740")

        do {
            _ = try presenter.validateFirstEntry().toBlocking().first()
        } catch {
            XCTFail("expected success in validating first pin entry, got \(error) instead")
        }
    }

    // Tests that selection of invalid pin fails when selecting a new pin
    func testFailureOnInvalidPinSelection() {
        let flow = PinRouting.Flow.create(parent: .init(nil))
        let useCase = PinScreenUseCase.select(previousPin: nil)
        let interactor = MockPinInteractor()
        let forward: PinRouting.RoutingType.Forward = { _ in }
        let presenter = PinScreenPresenter(
            useCase: useCase,
            flow: flow,
            interactor: interactor,
            biometryProvider: biometryProvider,
            appSettings: appSettings,
            cloudSettings: appSettings,
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: CrashlyticsRecorder(),
            credentialsStore: CredentialsStoreAPIMock(),
            backwardRouting: nil,
            forwardRouting: forward,
            performEffect: { _ in },
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )
        presenter.reset(to: Pin.invalid.toString)

        do {
            _ = try presenter.validateFirstEntry().toBlocking().first()
            XCTFail("expected \(PinError.invalid). got success instead")
        } catch {
            guard case PinError.invalid = error else {
                XCTFail("expected \(PinError.invalid). got \(error) instead")
                return
            }
        }
    }

    // Test second phase of pin entry during creation process
    func testCreationSuccessOnSecondEntry() {
        let selectedPin = Pin(string: "5740")!
        let flow = PinRouting.Flow.create(parent: .init(nil))
        let useCase = PinScreenUseCase.create(firstPin: selectedPin)
        let interactor = MockPinInteractor()
        let forward: PinRouting.RoutingType.Forward = { _ in
        }
        let presenter = PinScreenPresenter(
            useCase: useCase,
            flow: flow,
            interactor: interactor,
            biometryProvider: biometryProvider,
            appSettings: appSettings,
            cloudSettings: appSettings,
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: CrashlyticsRecorder(),
            credentialsStore: CredentialsStoreAPIMock(),
            backwardRouting: nil,
            forwardRouting: forward,
            performEffect: { _ in },
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )
        presenter.reset(to: selectedPin.toString)

        do {
            _ = try presenter.validateSecondEntry().toBlocking().first()
        } catch {
            XCTFail("expected success in validating second pin entry, got \(error) instead")
        }
    }

    // Test pin mismatch when the second pin != first pin
    func testCreationPinsMismatchFailure() {
        let pin = Pin(string: "5740")!
        let flow = PinRouting.Flow.create(parent: .init(nil))
        let useCase = PinScreenUseCase.create(firstPin: pin)
        let interactor = MockPinInteractor()
        let forward: PinRouting.RoutingType.Forward = { input in
            XCTFail("expected \(PinError.pinMismatch). got \(input) instead")
        }
        let backward: PinRouting.RoutingType.Backward = {}
        let presenter = PinScreenPresenter(
            useCase: useCase,
            flow: flow,
            interactor: interactor,
            biometryProvider: biometryProvider,
            appSettings: appSettings,
            cloudSettings: appSettings,
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: CrashlyticsRecorder(),
            credentialsStore: CredentialsStoreAPIMock(),
            backwardRouting: backward,
            forwardRouting: forward,
            performEffect: { _ in },
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )

        // Set a different value than the previosly selected one
        presenter.reset(to: "9154")

        do {
            _ = try presenter.validateSecondEntry().toBlocking().first()
        } catch {
            guard case PinError.pinMismatch = error else {
                XCTFail("expected \(PinError.pinMismatch). got \(error) instead")
                return
            }
        }
    }

    func testAuthenticationBeforeChanging() {
        let pin = "5740"
        let flow = PinRouting.Flow.change(parent: .init(nil), logoutRouting: {})
        let useCase = PinScreenUseCase.authenticateBeforeChanging
        let interactor = MockPinInteractor()
        let forward: PinRouting.RoutingType.Forward = { input in
            XCTAssertEqual(input.pin!.toString, pin)
        }
        let presenter = PinScreenPresenter(
            useCase: useCase,
            flow: flow,
            interactor: interactor,
            biometryProvider: biometryProvider,
            appSettings: appSettings,
            cloudSettings: appSettings,
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: CrashlyticsRecorder(),
            credentialsStore: CredentialsStoreAPIMock(),
            backwardRouting: nil,
            forwardRouting: forward,
            performEffect: { _ in },
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )
        presenter.reset(to: pin)

        do {
            _ = try presenter.verifyPinBeforeChanging().toBlocking().first()
        } catch {
            XCTFail("expected a success. got \(error) instead")
        }
    }

    func testChangingPinToPreviousValueFailure() {
        let previousPin = Pin(string: "5475")!
        let flow = PinRouting.Flow.change(parent: .init(nil), logoutRouting: {})
        let useCase = PinScreenUseCase.select(previousPin: previousPin)
        let interactor = MockPinInteractor()
        let forward: PinRouting.RoutingType.Forward = { _ in }
        let presenter = PinScreenPresenter(
            useCase: useCase,
            flow: flow,
            interactor: interactor,
            biometryProvider: biometryProvider,
            appSettings: appSettings,
            cloudSettings: appSettings,
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: CrashlyticsRecorder(),
            credentialsStore: CredentialsStoreAPIMock(),
            backwardRouting: nil,
            forwardRouting: forward,
            performEffect: { _ in },
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )
        presenter.reset(to: previousPin.toString)

        do {
            _ = try presenter.validateFirstEntry().toBlocking().first()
            XCTFail("expected \(PinError.identicalToPrevious). got success instead")
        } catch {
            guard case PinError.identicalToPrevious = error else {
                XCTFail("expected \(PinError.identicalToPrevious). got \(error) instead")
                return
            }
        }
    }
}
