//
//  DateFormatterTests.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class DateFormatterTests: XCTestCase {
    
    func testJustNowStringRepresentation() {
        let date = Date()
        let value = DateFormatter.timeAgoString(from: date)
        XCTAssertEqual("Just now", value)
    }
    
    func testYesterdayStringRepresentation() {
        var components = DateComponents()
        components.day = -1
        
        // Sending empty string in purpose as the 'Yesterday' must be returned
        assertAnyStringRepresentation(contains: "", using: components)
    }
    
    func testSecondsAgoStringRepresentation() {
        var components = DateComponents()
        components.second = -30
        assertAnyStringRepresentation(contains: "seconds ago", using: components)
    }
    
    func testMinutesAgoStringRepresentation() {
        var components = DateComponents()
        components.minute = -30
        assertAnyStringRepresentation(contains: "minutes ago", using: components)
    }
    
    func testOneHourAgoStringRepresentation() {
        var components = DateComponents()
        components.hour = -1
        assertAnyStringRepresentation(contains: "hour ago", using: components)
    }
    
    func testHoursAgoStringRepresentation() {
        assertTestingOfHoursAgoStringRepresentation(subracting: 3)
        assertTestingOfHoursAgoStringRepresentation(subracting: 7)
        assertTestingOfHoursAgoStringRepresentation(subracting: 12)
        assertTestingOfHoursAgoStringRepresentation(subracting: 20)
    }
    
    private func assertTestingOfHoursAgoStringRepresentation(subracting hours: Int) {
        var components = DateComponents()
        components.hour = -hours // taking large number in purpose - more likely the project fails locally during daywork
        assertAnyStringRepresentation(contains: "hours ago", using: components)
    }
    
    // Concentrated testing funnel for all sorts of date subtracting scenarios
    private func assertAnyStringRepresentation(contains substring: String,
                                               using components: DateComponents) {
        let calendar = Calendar(identifier: .gregorian)
        // First try to convert the date, this should work by design
        guard let timeAgo = calendar.date(byAdding: components, to: Date()) else {
            XCTFail("time conversion using Calendar has failed")
            return
        }
        guard let value = DateFormatter.timeAgoString(from: timeAgo) else {
            XCTFail("Expected a time stamp")
            return
        }
        
        // We must ask if the tested date is today because the tested code assumes current date and doesn't get any input
        if calendar.isDateInToday(timeAgo) {
            XCTAssertTrue(value.contains(substring))
        } else {
            XCTAssertEqual("Yesterday", value)
        }
    }
}
