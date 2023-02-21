// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainNamespace
import Combine
import DIKit
import Errors
@testable import FeatureUserTagSyncDomain
import XCTest

final class FeatureUserTagSyncDomainTests: XCTestCase {
    var app: AppProtocol!
    var mockUserTagService: MockUserTagService!
    var sut: UserTagObserver! {
        didSet { sut?.start() }
    }

    private var cancellable = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        app = App.test
        mockUserTagService = MockUserTagService()
        sut = UserTagObserver(app: app, userTagSyncService: mockUserTagService)
        app.remoteConfiguration.override(blockchain.api.nabu.gateway.user.tag.service.is.enabled, with: true)
    }

    override func tearDown() {
        mockUserTagService = nil
        super.tearDown()
    }

    func testSyncWhenUserHasNoTagsAndFlagIsTrue() throws {
        // GIVEN
        let remoteSuperAppMvpFlagValue = false
        let remoteSuperAppV1FlagValue = false
        app.remoteConfiguration.override(blockchain.app.configuration.app.superapp.is.enabled, with: remoteSuperAppMvpFlagValue)
        app.remoteConfiguration.override(blockchain.app.configuration.app.superapp.v1.is.enabled, with: remoteSuperAppV1FlagValue)
        app.state.set(blockchain.user.is.superapp.user, to: nil)
        app.state.set(blockchain.user.is.superapp.v1.user, to: nil)

        // WHEN
        app.post(event: blockchain.user.event.did.update)

        let methodUpdateSuperAppMvpCallExpectation = expectation(description: "Update super app mvp tag called")
        let methodUpdateSuperAppV1CallExpectation = expectation(description: "Update super app v1 tag called")

        var updatedMVPTagValue: Bool?
        mockUserTagService.updateSuperAppTagsCalledWithSuperAppMvpValue
            .sink { updatedValue in
                updatedMVPTagValue = updatedValue
                methodUpdateSuperAppMvpCallExpectation.fulfill()
            }
            .store(in: &cancellable)

        var updatedV1TagValue: Bool?
        mockUserTagService.updateSuperAppTagsCalledWithSuperAppV1Value
            .sink { updatedValue in
                updatedV1TagValue = updatedValue
                methodUpdateSuperAppV1CallExpectation.fulfill()
            }
            .store(in: &cancellable)

        wait(for: [methodUpdateSuperAppMvpCallExpectation, methodUpdateSuperAppV1CallExpectation], timeout: 1)

        // THEN
        XCTAssertEqual(updatedMVPTagValue, remoteSuperAppMvpFlagValue)
        XCTAssertEqual(updatedV1TagValue, remoteSuperAppV1FlagValue)
    }

    func testSyncWhenUserHasTagButTheFlagIsDifferent() throws {
        // GIVEN
        let remoteSuperAppMvpFlagValue = false
        app.remoteConfiguration.override(blockchain.app.configuration.app.superapp.is.enabled, with: remoteSuperAppMvpFlagValue)
        app.state.set(blockchain.user.is.superapp.user, to: true)

        let remoteSuperAppV1FlagValue = true
        app.remoteConfiguration.override(blockchain.app.configuration.app.superapp.v1.is.enabled, with: remoteSuperAppV1FlagValue)
        app.state.set(blockchain.user.is.superapp.v1.user, to: true)

        // WHEN
        app.post(event: blockchain.user.event.did.update)

        let methodUpdateSuperAppMvpCallExpectation = expectation(description: "Update super app mvp tag called")
        let methodUpdateSuperAppV1CallExpectation = expectation(description: "Update super app v1 tag called")

        var updatedMVPTagValue: Bool?
        mockUserTagService.updateSuperAppTagsCalledWithSuperAppMvpValue
            .sink { updatedValue in
                updatedMVPTagValue = updatedValue
                methodUpdateSuperAppMvpCallExpectation.fulfill()
            }
            .store(in: &cancellable)

        var updatedV1TagValue: Bool?
        mockUserTagService.updateSuperAppTagsCalledWithSuperAppV1Value
            .sink { updatedValue in
                updatedV1TagValue = updatedValue
                methodUpdateSuperAppV1CallExpectation.fulfill()
            }
            .store(in: &cancellable)

        wait(for: [methodUpdateSuperAppMvpCallExpectation, methodUpdateSuperAppV1CallExpectation], timeout: 1)

        // THEN
        XCTAssertEqual(updatedMVPTagValue, remoteSuperAppMvpFlagValue)
        XCTAssertEqual(updatedV1TagValue, remoteSuperAppV1FlagValue)
    }

    func testSyncNotCalledWhenFlagsAreTheSame() throws {
        // GIVEN
        let remoteSuperAppMvpFlagValue = true
        app.remoteConfiguration.override(blockchain.app.configuration.app.superapp.is.enabled, with: remoteSuperAppMvpFlagValue)
        app.state.set(blockchain.user.is.superapp.user, to: remoteSuperAppMvpFlagValue)
        let remoteSuperAppV1FlagValue = true
        app.remoteConfiguration.override(blockchain.app.configuration.app.superapp.v1.is.enabled, with: remoteSuperAppV1FlagValue)
        app.state.set(blockchain.user.is.superapp.v1.user, to: remoteSuperAppV1FlagValue)

        // WHEN
        app.post(event: blockchain.user.event.did.update)

        // THEN
        XCTAssertFalse(mockUserTagService.updateSuperAppTagsMethodCalled)
    }
}

class MockUserTagService: UserTagServiceAPI {
    var updateSuperAppTagsCalledWithSuperAppMvpValue = PassthroughSubject<Bool?, Never>()
    var updateSuperAppTagsCalledWithSuperAppV1Value = PassthroughSubject<Bool?, Never>()

    var updateSuperAppTagsMethodCalled = false

    func updateSuperAppTags(
        isSuperAppMvpEnabled: Bool,
        isSuperAppV1Enabled: Bool
    ) -> AnyPublisher<Void, NetworkError> {
        updateSuperAppTagsMethodCalled = true
        updateSuperAppTagsCalledWithSuperAppV1Value.send(isSuperAppV1Enabled)
        updateSuperAppTagsCalledWithSuperAppMvpValue.send(isSuperAppMvpEnabled)
        return .just(())
    }
}
