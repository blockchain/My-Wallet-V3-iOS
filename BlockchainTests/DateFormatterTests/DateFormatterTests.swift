//
//  DateFormatterTests.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class DateFormatterTests: XCTestCase {
    
    func testJustNowTimeStamp() {
        let date = Date()
        let value = DateFormatter.timeAgoString(from: date)
        XCTAssertEqual("Just now", value)
    }
    
    func testYesterdayTimeStamp() {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.day = -1
        let yesterday = calendar.date(byAdding: components, to: Date())
        let value = DateFormatter.timeAgoString(from: yesterday)
        XCTAssertEqual("Yesterday", value)
    }
    
    func testSecondsAgoTimeStamp() {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.second = -30
        let yesterday = calendar.date(byAdding: components, to: Date())
        guard let value = DateFormatter.timeAgoString(from: yesterday) else {
            XCTAssert(false, "Expected a time stamp")
            return
        }
        XCTAssertTrue(value.contains("seconds ago"))
    }
    
    func testMinutesAgoTimeStamp() {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.minute = -30
        let yesterday = calendar.date(byAdding: components, to: Date())
        guard let value = DateFormatter.timeAgoString(from: yesterday) else {
            XCTAssert(false, "Expected a time stamp")
            return
        }
        XCTAssertTrue(value.contains("minutes ago"))
    }
    
    func testHoursAgoTimeStamp() {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.hour = -4
        let yesterday = calendar.date(byAdding: components, to: Date())
        guard let value = DateFormatter.timeAgoString(from: yesterday) else {
            XCTAssert(false, "Expected a time stamp")
            return
        }
        XCTAssertTrue(value.contains("hours ago"))
    }
    
    func testOneHourAgoTimeStamp() {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.hour = -1
        let yesterday = calendar.date(byAdding: components, to: Date())
        guard let value = DateFormatter.timeAgoString(from: yesterday) else {
            XCTAssert(false, "Expected a time stamp")
            return
        }
        XCTAssertTrue(value.contains("hour ago"))
    }
    
}
