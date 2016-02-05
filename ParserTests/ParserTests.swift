//
//  ParserTests.swift
//  ParserTests
//
//  Created by Rahul Malik on 2/4/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import XCTest
@testable import Parser

class ParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let filePath = Path("example.feature")
        let features = try! Feature.parse([filePath])
        XCTAssert(features.count == 1)
        XCTAssert(features[0].name == "An array")
        XCTAssert(features[0].scenarios.count == 2)
        let scenarios = features[0].scenarios
        XCTAssert(scenarios[0].name == "Appending to an array")
        XCTAssert(scenarios[0].line == 3)
        XCTAssert(scenarios[0].line == 3)
        XCTAssert(scenarios[0].steps[0] == .Given("I have an empty array"))
        XCTAssert(scenarios[0].steps[1] == .When("I add 1 to the array"))
        XCTAssert(scenarios[0].steps[2] == .Then("I should have 1 item in the array"))
        XCTAssert(scenarios[0].steps[3] == .And("this is undefined statement for test"))
        XCTAssert(scenarios[0].steps.count == 4)
        XCTAssert(scenarios[1].name == "Filtering an array")
        XCTAssert(scenarios[1].line == 9)
        XCTAssert(scenarios[1].steps.count == 3)
        XCTAssert(scenarios[1].examples!.count == 2)
        XCTAssert(scenarios[1].examples!.dictionaryArray["value1"]! == ["1","10"])
        XCTAssert(scenarios[1].examples!.dictionaryArray["value5"]! == ["5", "15"])
        XCTAssert(scenarios[1].examples!.dictionaryArray["value2"]! == ["2", "12"])
    }
}
