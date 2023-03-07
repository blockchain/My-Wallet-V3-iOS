// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

#if os(iOS)
final class SpacingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testGridSixIPhoneX() {
        let grid = Grid(containerWidth: 375, columns: 6)
        XCTAssertEqual(grid.gutter, 8)
        XCTAssertEqual(grid.padding, 24)
        XCTAssertEqual(grid.columnWidth, 47.833333333333336)
    }

    func testGridSixIPhone6() {
        let grid = Grid(containerWidth: 320, columns: 6)
        XCTAssertEqual(grid.gutter, 8)
        XCTAssertEqual(grid.padding, 16)
        XCTAssertEqual(grid.columnWidth, 41.333333333333336)
    }

    func testGridFourIPhoneX() {
        let grid = Grid(containerWidth: 375, columns: 4)
        XCTAssertEqual(grid.gutter, 16)
        XCTAssertEqual(grid.padding, 24)
        XCTAssertEqual(grid.columnWidth, 69.75)
    }

    func testGridFourIPhone6() {
        let grid = Grid(containerWidth: 320, columns: 4)
        XCTAssertEqual(grid.gutter, 16)
        XCTAssertEqual(grid.padding, 16)
        XCTAssertEqual(grid.columnWidth, 60.0)
    }

    func testGridTwoIPhoneX() {
        let grid = Grid(containerWidth: 375, columns: 2)
        XCTAssertEqual(grid.gutter, 16)
        XCTAssertEqual(grid.padding, 24)
        XCTAssertEqual(grid.columnWidth, 155.5)
    }

    func testGridTwoIPhone6() {
        let grid = Grid(containerWidth: 320, columns: 2)
        XCTAssertEqual(grid.gutter, 16)
        XCTAssertEqual(grid.padding, 16)
        XCTAssertEqual(grid.columnWidth, 136.0)
    }

    func testGrids() {
        let view = Spacing_Previews.gridPreviews
            .fixedSize()
            .background(Color.gray.opacity(0.1))

        assertSnapshot(matching: view, as: .image)
    }

    func testPadding() {
        let view = Spacing_Previews.paddingPreviews
            .fixedSize()
            .background(Color.gray.opacity(0.1))

        assertSnapshot(matching: view, as: .image)
    }

    func testBorderRadii() {
        let view = Spacing_Previews.borderRadiiPreviews
            .fixedSize()
            .background(Color.gray.opacity(0.1))

        assertSnapshot(matching: view, as: .image)
    }
}
#endif
