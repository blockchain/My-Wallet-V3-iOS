// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

struct InitMetadataNodesInput {
    var credentials: Credentials
    var masterKey: MasterKey
    var payloadIsDoubleEncrypted: Bool
    var secondPasswordNode: SecondPasswordNode
}

typealias InitMetadataNodes =
    (InitMetadataNodesInput) -> AnyPublisher<MetadataState, MetadataInitialisationError>

enum NodeStatus: Equatable {
    case loaded(RemoteMetadataNodes)
    case notYetCreated
}

func provideInitMetadataNodes(
    fetch: @escaping FetchMetadataEntry,
    put: @escaping PutMetadataEntry
) -> InitMetadataNodes {
    let loadMetadata = provideLoadRemoteMetadata(
        fetch: fetch
    )
    let loadNodes = provideLoadNodes(fetch: fetch)
    let generateNodes = provideGenerateNodes(
        fetch: fetch,
        put: put
    )
    return provideInitMetadataNodes(
        loadNodes: loadNodes,
        loadMetadata: loadMetadata,
        generateNodes: generateNodes
    )
}

func provideInitMetadataNodes(
    loadNodes: @escaping LoadNodes,
    loadMetadata: @escaping LoadRemoteMetadata,
    generateNodes: @escaping GenerateNodes
) -> InitMetadataNodes {
    { input in
        initMetadataNodes(
            input: input,
            loadNodes: loadNodes,
            loadMetadata: loadMetadata,
            generateNodes: generateNodes
        )
    }
}

private func initMetadataNodes(
    input: InitMetadataNodesInput,
    loadNodes: @escaping LoadNodes,
    loadMetadata: @escaping LoadRemoteMetadata,
    generateNodes: @escaping GenerateNodes
) -> AnyPublisher<MetadataState, MetadataInitialisationError> {
    loadNodes(input.credentials, input.masterKey)
        .catch { error -> AnyPublisher<(NodeStatus, SecondPasswordNode), MetadataInitialisationError> in
            guard case .failedToLoadRemoteMetadataNode(let loadError) = error else {
                return .failure(error)
            }
            guard case .notYetCreated = loadError else {
                return .failure(error)
            }
            return .just((.notYetCreated, input.secondPasswordNode))
        }
        .flatMap { [generateNodes] nodeStatus, secondPasswordNode
            -> AnyPublisher<MetadataState, MetadataInitialisationError> in
            switch nodeStatus {
            case .notYetCreated:
                generateNodes(
                    input.masterKey,
                    secondPasswordNode
                )
                .mapError(MetadataInitialisationError.failedToGenerateNodes)
                .eraseToAnyPublisher()
            case .loaded(let metadataNodes):
                .just(
                    MetadataState(
                        metadataNodes: metadataNodes,
                        secondPasswordNode: secondPasswordNode
                    )
                )
            }
        }
        .eraseToAnyPublisher()
}

typealias LoadNodes =
    (Credentials, MasterKey) -> AnyPublisher<(NodeStatus, SecondPasswordNode), MetadataInitialisationError>

func provideLoadNodes(
    fetch: @escaping FetchMetadataEntry
) -> LoadNodes {
    provideLoadNodes(
        loadMetadata: provideLoadRemoteMetadata(
            fetch: fetch
        )
    )
}

func provideLoadNodes(
    loadMetadata: @escaping LoadRemoteMetadata
) -> LoadNodes {
    { credentials, masterKey in
        loadNodes(
            credentials: credentials,
            masterKey: masterKey,
            loadMetadata: loadMetadata
        )
    }
}

private func loadNodes(
    credentials: Credentials,
    masterKey: MasterKey,
    loadMetadata: @escaping LoadRemoteMetadata
) -> AnyPublisher<(NodeStatus, SecondPasswordNode), MetadataInitialisationError> {

    func load(
        secondPasswordNode: SecondPasswordNode
    ) -> AnyPublisher<(NodeStatus, SecondPasswordNode), MetadataInitialisationError> {
        loadMetadata(secondPasswordNode.metadataNode)
            .mapError(MetadataInitialisationError.failedToLoadRemoteMetadataNode)
            .flatMap { remoteMetadataNodesString
                -> AnyPublisher<RemoteMetadataNodesResponse, MetadataInitialisationError> in
                remoteMetadataNodesString
                    .decodeJSON(
                        to: RemoteMetadataNodesResponse.self
                    )
                    .mapError(MetadataInitialisationError.failedToDecodeRemoteMetadataNode)
                    .publisher
                    .eraseToAnyPublisher()
            }
            .flatMap { response -> AnyPublisher<RemoteMetadataNodesResponse, MetadataInitialisationError> in
                // validate that the current loaded root note contains the correct entry.
                // if an erroneous xpriv exists then update by recreating one.
                deriveRemoteMetadataHdNodes(from: masterKey)
                    .publisher
                    .eraseToAnyPublisher()
                    .mapError { _ in MetadataInitialisationError.failedToLoadRemoteMetadataNode(.notYetCreated) }
                    .map(\.metadataNode)
                    .flatMap { privateKey -> AnyPublisher<RemoteMetadataNodesResponse, MetadataInitialisationError> in
                        let rootNeedsUpdating = rootNodeRequiresUpdating(
                            masterKey: privateKey,
                            fetchedRootMetadataValue: response.metadata
                        )
                        guard rootNeedsUpdating else {
                            return .just(response)
                        }
                        return .failure(.failedToLoadRemoteMetadataNode(.notYetCreated))
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { remoteMetadataNodesResponse
                -> AnyPublisher<NodeStatus, MetadataInitialisationError> in
                initNodes(
                    remoteMetadataNodesResponse: remoteMetadataNodesResponse
                )
                .mapError(MetadataInitialisationError.failedToDeriveRemoteMetadataNode)
                .publisher
                .map(NodeStatus.loaded)
                .eraseToAnyPublisher()
            }
            .map { nodeStatus -> (NodeStatus, SecondPasswordNode) in
                (nodeStatus, secondPasswordNode)
            }
            .eraseToAnyPublisher()
    }

    return deriveSecondPasswordNode(credentials: credentials)
        .mapError(MetadataInitialisationError.failedToDeriveSecondPasswordNode)
        .publisher
        .flatMap { secondPasswordNode
            -> AnyPublisher<(NodeStatus, SecondPasswordNode), MetadataInitialisationError> in
            load(secondPasswordNode: secondPasswordNode)
        }
        .eraseToAnyPublisher()
}

// MARK: - Patch Method

func rootNodeRequiresUpdating(
    masterKey: PrivateKey,
    fetchedRootMetadataValue: String?
) -> Bool {
    guard masterKey.xpriv == fetchedRootMetadataValue else {
        return true
    }
    return false
}
