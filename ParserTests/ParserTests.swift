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
    
    func execute_after(delayInSeconds: NSTimeInterval, block: dispatch_block_t) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
    }
    
    func testTunner(){
        var array: [Int] = []
        
        Given("^I have an empty array$") { match, completion in
            array = []
            completion()
        }
        
        Given("^I have an array with the (\\w+) (\\d+) though (\\d+)$") { match, completion in
            let start = match.groups[2]
            let end = match.groups[3]
            
            array = Array(Int(start)! ..< Int(end)!)
            
            self.execute_after(2){
                completion()
            }
        }
        
        When("^I add (\\d+) to the array$") { match, completion in
            let number = Int(match.groups[1])!
            array.append(number)
            completion()
        }
        
        When("^I filter the array for even numbers$") { match, completion in
            array = array.filter { $0 % 2 == 0 }
            completion()
        }
        
        Then("^I should have (\\d+) items? in the array$") { match, completion in
            let count = Int(match.groups[1])!
            try expect(array.count == count)
            completion()
        }
        
        And("^this is undefined statement for test$") { match, completion in
            try expect(true)
            completion()
        }
        
        let appExpectation = expectationWithDescription("LoginTest")
        startMyTest(){
            appExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(40, handler: nil)
    }
    
    func testExample() {
        let filePath = Path("example.feature")
        let features = try! FeatureFileParser().parse([filePath])
        XCTAssert(features.count == 1)
        XCTAssert(features[0].name == "An array")
        let scenarios = features[0].scenarios
        XCTAssert(scenarios.count == 3)
        XCTAssert(scenarios[0].name == "Appending to an array")
        XCTAssert(scenarios[0].meta == .Automated)
        XCTAssert(scenarios[0].line == 3)
        XCTAssert(scenarios[0].steps[0] == .Given("I have an empty array"))
        XCTAssert(scenarios[0].steps[1] == .When("I add 1 to the array"))
        XCTAssert(scenarios[0].steps[2] == .Then("I should have 1 item in the array"))
        XCTAssert(scenarios[0].steps[3] == .And("this is undefined statement for test"))
        XCTAssert(scenarios[0].steps.count == 4)
        XCTAssert(scenarios[1].name == "Filtering an array")
        XCTAssert(scenarios[1].steps.count == 3)
        XCTAssert(scenarios[1].steps[0] == .Given("I have an array with the numbers 1 though 5"))
        XCTAssert(scenarios[1].steps[1] == .When("I filter the array for even numbers"))
        XCTAssert(scenarios[1].steps[2] == .Then("I should have 2 items in the array"))
        XCTAssert(scenarios[2].name == "Filtering an array")
        XCTAssert(scenarios[2].steps.count == 3)
        XCTAssert(scenarios[2].steps[0] == .Given("I have an array with the numbers 10 though 15"))
        XCTAssert(scenarios[2].steps[1] == .When("I filter the array for even numbers"))
        XCTAssert(scenarios[2].steps[2] == .Then("I should have 3 items in the array"))
        
//        XCTAssert(scenarios[1].examples!.count == 2)
//        XCTAssert(scenarios[1].examples!.dictionaryArray["value1"]! == ["1","10"])
//        XCTAssert(scenarios[1].examples!.dictionaryArray["value5"]! == ["5", "15"])
//        XCTAssert(scenarios[1].examples!.dictionaryArray["value2"]! == ["2", "12"])
    }
}
