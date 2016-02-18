//
//  ParserBDD.swift
//  Parser
//
//  Created by Rahul Malik on 2/12/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import Foundation
import XCTest
@testable import Parser

func execute_after(delayInSeconds: NSTimeInterval, block: dispatch_block_t) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( delayInSeconds * Double(NSEC_PER_SEC)))
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

class ParserBDD: BDDTest {
    override func setUp() {
        self.runFeature = "example"
        super.setUp()
        var array: [Int] = []
        
        Given("^I have an empty array$") { match in
            array = []
            XCTAssert(array.count == 0)
        }
        
        Given("^I have an array with the numbers (\\d+) though (\\d+)$") { match in
            let start = match.groups[1]
            let end = match.groups[2]
            
            array = Array(Int(start)! ..< Int(end)!)
            XCTAssert(array.count > 0)
        }
        
        When("^I add (\\d+) to the array$") { match in
            let number = Int(match.groups[1])!
            array.append(number)
        }
        
        When("^I filter the array for even numbers$") { match in
            array = array.filter { $0 % 2 == 0 }
        }
        
        Then("^I should have (\\d+) items in the array$") { match in
            let count = Int(match.groups[1])!
            tryexpect(array.count == count, message: match.groups[0])
        }
        
        And("^this is undefined statement for test$") { match in
            var test = false
            let appExpectation = self.expectationWithDescription("LoginTest")
            execute_after(0.1){
                test = true
                appExpectation.fulfill()
            }
            self.waitForExpectationsWithTimeout(40, handler: nil)
            tryexpect(test, message: match.groups[0])
        }
    }
}