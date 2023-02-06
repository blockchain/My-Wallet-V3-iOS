// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

#if os(iOS)
final class TagTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testTags() {
        let view = HStack { TagView_Previews.previews.fixedSize() }

        assertSnapshot(matching: view, as: .image)
    }
}
#endif
