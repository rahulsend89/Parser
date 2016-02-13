//
//  BDDTest.swift
//  Parser
//
//  Created by Rahul Malik on 2/12/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import Foundation

import Foundation
import ObjectiveC

import XCTest

@testable import Parser

public class BDDTest: XCTestCase {

    var runFeature:String?
    
    func testRunNativeTests() {
        guard self.dynamicType != BDDTest.self else { return }
        guard let runFeature = runFeature else{
            XCTFail("runFeature not mention")
            return
        }
        let feature: [Feature] =  getMyFeatures(runFeature)!
        for testFeature in feature{
            performFeature(testFeature)
        }
    }
    
    func performFeature(feature: Feature) {
        // Create a test case to contain our tests
        let testClassName = "\(feature.name.camelCaseify)Tests"
        let testCaseClassOptional: AnyClass? = objc_allocateClassPair(XCTestCase.self, testClassName, 0)
        guard let testCaseClass = testCaseClassOptional else { XCTFail("Could not create test case class"); return }
        
        // Return the correct number of tests
        let countBlock : @convention(block) (AnyObject) -> UInt = { _ in
            return UInt(feature.scenarios.count)
        }
        let imp = imp_implementationWithBlock(unsafeBitCast(countBlock, AnyObject.self))
        let sel = sel_registerName(strdup("testCaseCount"))
        var success = class_addMethod(testCaseClass, sel, imp, strdup("I@:"))
        XCTAssertTrue(success)
        
        // Return a name
        let nameBlock : @convention(block) (AnyObject) -> String = { _ in
            return feature.name.camelCaseify
        }
        let nameImp = imp_implementationWithBlock(unsafeBitCast(nameBlock, AnyObject.self))
        let nameSel = sel_registerName(strdup("name"))
        success = class_addMethod(testCaseClass, nameSel, nameImp, strdup("@@:"))
        XCTAssertTrue(success)
        
        // Return a test run class - make it the same as the current run
        let runBlock : @convention(block) (AnyObject) -> AnyObject! = { _ in
            return self.testRun!.dynamicType
        }
        let runImp = imp_implementationWithBlock(unsafeBitCast(runBlock, AnyObject.self))
        let runSel = sel_registerName(strdup("testRunClass"))
        success = class_addMethod(testCaseClass, runSel, runImp, strdup("#@:"))
        XCTAssertTrue(success)
        
        // For each scenario, make an invocation that runs through the steps
        let typeString = strdup("v@:")
        feature.scenarios.forEach { scenario in
            print(scenario.name)
            // Create the block representing the test to be run
            let block : @convention(block) (XCTestCase)->() = { innerSelf in
                scenario.steps.forEach{ StepCreator.sharedInstance.runStep($0){$0}}
            }
            
            // Create the Method and selector
            let imp = imp_implementationWithBlock(unsafeBitCast(block, AnyObject.self))
            let strSelName: String = "test_\(scenario.name.camelCaseify)"
            let selName = strdup(strSelName)
            let sel = sel_registerName(selName)
            
            // Add this selector to ourselves
            let success = class_addMethod(testCaseClass, sel, imp, typeString)
            XCTAssertTrue(success, "Failed to add class method \(sel)")
        }
        
        // The test class is constructed, register it
        objc_registerClassPair(testCaseClass)
        
        // Add the test to our test suite
        testCaseClass.testInvocations().sort { (a,b) in NSStringFromSelector(a.selector) > NSStringFromSelector(b.selector) }.forEach { invocation in
            let testCase = (testCaseClass as! XCTestCase.Type).init(invocation: invocation)
            testCase.runTest()
            print("\(testCase)___")
        }
        
    }
}
