// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Extensions
import Foundation
import OptionalSubscripts

var isInTest: Bool { NSClassFromString("XCTestCase") != nil }

extension App {

    public class Test: AppProtocol {

        private var app: AppProtocol

        public var language: Language { app.language }
        public var events: Session.Events { app.events }
        public var state: Session.State { app.state }
        public var clientObservers: Client.Observers { app.clientObservers }
        public var sessionObservers: Session.Observers { app.sessionObservers }
        public var remoteConfiguration: Session.RemoteConfiguration { app.remoteConfiguration }
        public var scheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
        public var deepLinks: DeepLink { app.deepLinks }
        public var local: Optional<Any>.Store { app.local }
        public var napis: NAPI.Store { app.napis }
        public var isInTransaction: Bool { app.isInTransaction }

        public init() {
            self.app = App.debug(scheduler: scheduler.eraseToAnyScheduler())
        }

        public func register(
            napi root: I_blockchain_namespace_napi,
            domain: L,
            policy: L_blockchain_namespace_napi_napi_policy.JSON? = nil,
            repository: @escaping (Tag.Reference) -> AnyPublisher<AnyJSON, Never>,
            in context: Tag.Context
        ) async throws {
            try await app.register(napi: root, domain: domain, policy: policy, repository: repository, in: context)
        }

        public var description: String { "Test \(app)" }

        public func wait(
            _ event: Tag.Event,
            file: String = #fileID,
            line: Int = #line
        ) async throws {
            _ = try await on(event, bufferingPolicy: .unbounded).next(file: file, line: line)
        }

        public func wait<S: Scheduler>(
            _ event: Tag.Event,
            timeout: S.SchedulerTimeType.Stride,
            scheduler: S = DispatchQueue.main,
            file: String = #fileID,
            line: Int = #line
        ) async throws {
            _ = try await on(event).timeout(timeout, scheduler: scheduler).values.next(file: file, line: line)
            await Task.megaYield(count: 100)
        }

        public func post(
            value: AnyHashable,
            of event: Tag.Event,
            file: String = #fileID,
            line: Int = #line
        ) async {
            app.post(value: value, of: event, file: file, line: line)
            await Task.megaYield(count: 100)
        }

        public func post(
            event: Tag.Event,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) async {
            app.post(event: event, context: context, file: file, line: line)
            await Task.megaYield(count: 100)
        }

        public func post(
            _ tag: L_blockchain_ux_type_analytics_error,
            error: some Error,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) async {
            app.post(tag, error: error, context: context, file: file, line: line)
            await Task.megaYield(count: 100)
        }

        public func post(
            error: some Error,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) async {
            app.post(error: error, context: context, file: file, line: line)
            await Task.megaYield(count: 100)
        }

        func post(
            event: Tag.Event,
            reference: Tag.Reference,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) async {
            app.post(event: event, reference: reference, context: context, file: file, line: line)
            await Task.megaYield(count: 100)
        }
    }
}
