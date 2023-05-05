import Combine
import ComposableArchitecture
import FeatureNFTDomain
import Foundation
import UIKit

public struct AssetListViewEnvironment {

    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let assetProviderService: AssetProviderServiceAPI
    public let pasteboard: UIPasteboard

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        pasteboard: UIPasteboard = .general,
        assetProviderService: AssetProviderServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.pasteboard = pasteboard
        self.assetProviderService = assetProviderService
    }
}
