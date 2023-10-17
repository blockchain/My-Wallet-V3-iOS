@testable import BlockchainNamespace
import ComposableArchitectureExtensions
import FirebaseProtocol
import XCTest

@MainActor
final class BlockchainNamespaceTests: XCTestCase {

    var app: AppProtocol!

    override func setUp() {
        super.setUp()
        app = App(remote: Mock.RemoteConfiguration())
    }

    func test() async {
        let fileName = "Folder/TestFileName"
        let lineTag = 1
        let lineString = 2
        let lineBoolean = 3
        let lineInteger = 4
        let store = TestStore(
            initialState: TestState(),
            reducer: { TestReducer(app: app) }
        )

        app.post(event: blockchain.db.type.string)
        app.post(event: blockchain.db.type.integer)

        await store.send(.observation(.start))

        app.post(event: blockchain.db.type.tag, file: fileName, line: lineTag)

        app.post(event: blockchain.db.type.string, file: fileName, line: lineString)
        await store.receive(
            .observation(
                .event(blockchain.db.type.string[].reference, context: [
                    blockchain.ux.type.analytics.event.source.file[]: fileName,
                    blockchain.ux.type.analytics.event.source.line[]: lineString
                ])
            )
        ) { state in
            state.event = blockchain.db.type.string[].reference
            state.context = [
                blockchain.ux.type.analytics.event.source.file[]: fileName,
                blockchain.ux.type.analytics.event.source.line[]: lineString
            ]
        }

        app.post(event: blockchain.db.type.boolean, file: fileName, line: lineBoolean)
        await store.receive(
            .observation(
                .event(blockchain.db.type.boolean[].reference, context: [
                    blockchain.ux.type.analytics.event.source.file[]: fileName,
                    blockchain.ux.type.analytics.event.source.line[]: lineBoolean
                ])
            )
        ) { state in
            state.event = blockchain.db.type.boolean[].reference
            state.context = [
                blockchain.ux.type.analytics.event.source.file[]: fileName,
                blockchain.ux.type.analytics.event.source.line[]: lineBoolean
            ]
        }

        app.post(event: blockchain.db.type.integer, context: [blockchain.db.type.string: "context"], file: fileName, line: lineInteger)
        await store.receive(
            .observation(
                .event(blockchain.db.type.integer[].reference, context: [
                    blockchain.db.type.string[]: "context",
                    blockchain.ux.type.analytics.event.source.file[]: fileName,
                    blockchain.ux.type.analytics.event.source.line[]: lineInteger
                ])
            )
        ) { state in
            state.event = blockchain.db.type.integer[].reference
            state.context = [
                blockchain.db.type.string[]: "context",
                blockchain.ux.type.analytics.event.source.file[]: fileName,
                blockchain.ux.type.analytics.event.source.line[]: lineInteger
            ]
        }

        await store.send(.observation(.stop))

        app.post(event: blockchain.db.type.boolean)
    }
}

struct TestState: Equatable {
    var event: Tag.Reference?
    var context: Tag.Context?
}

enum TestAction: BlockchainNamespaceObservationAction, Equatable {
    case observation(BlockchainNamespaceObservation)
}

struct TestReducer: Reducer {
    typealias State = TestState
    typealias Action = TestAction

    let app: AppProtocol

    var body: some Reducer<State, Action> {
        BlockchainNamespaceReducer(app: app, events: [
            blockchain.db.type.string,
            blockchain.db.type.integer,
            blockchain.db.type.boolean
        ])
        Reduce { state, action in
            switch action {
            case .observation(.event(let event, context: let context)):
                state.event = event
                state.context = context
                return .none
            case .observation:
                return .none
            }
        }
    }
}
