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
    var runFeature: String?
    var featureCount: Int = 0
    func testRunNativeTests() {
        guard self.dynamicType != BDDTest.self else { return }
        guard let runFeature = runFeature else{
            XCTFail("runFeature not mention")
            return
        }
        let feature: [Feature] =  getMyFeatures(runFeature)!
        featureCount = feature.count-1
        for testFeature in feature{
            performFeature(testFeature)
        }
    }
    
    func performFeature(feature: Feature) {
        let testClassName = "\(feature.name.camelCaseify)Tests"
        let testCaseClassOptional: AnyClass? = objc_allocateClassPair(XCTestCase.self, testClassName, 0)
        guard let testCaseClass = testCaseClassOptional else {
            XCTFail("Could not create test case class"); return
        }
        Reporter.logText("Feature : \(feature.name)")
        let countBlock : @convention(block) (AnyObject) -> UInt = { _ in
            return UInt(feature.scenarios.count)
        }
        let imp = imp_implementationWithBlock(unsafeBitCast(countBlock, AnyObject.self))
        let sel = sel_registerName(strdup("testCaseCount"))
        var success = class_addMethod(testCaseClass, sel, imp, strdup("I@:"))
        XCTAssertTrue(success)
        
        let nameBlock : @convention(block) (AnyObject) -> String = { _ in
            return feature.name.camelCaseify
        }
        let nameImp = imp_implementationWithBlock(unsafeBitCast(nameBlock, AnyObject.self))
        let nameSel = sel_registerName(strdup("name"))
        success = class_addMethod(testCaseClass, nameSel, nameImp, strdup("@@:"))
        XCTAssertTrue(success)
        
        let runBlock : @convention(block) (AnyObject) -> AnyObject! = { _ in
            return self.testRun!.dynamicType
        }
        let runImp = imp_implementationWithBlock(unsafeBitCast(runBlock, AnyObject.self))
        let runSel = sel_registerName(strdup("testRunClass"))
        success = class_addMethod(testCaseClass, runSel, runImp, strdup("#@:"))
        XCTAssertTrue(success)
        
        
        let typeString = strdup("v@:")
        
        var scenarios = 0
        var failures = 0
        var allSteps = 0
        var scenariosVal = feature.scenarios
        let length = scenariosVal.count
        let endAutoCount = scenariosVal.filter { (scenario) -> Bool in
            if scenario.meta == .Automated{
                return true
            }else{
                return false
            }
            }.count
        
        let completion: ()->() = {
            let outFeatureFile = Feature(name: feature.name, scenarios: scenariosVal, filePath: feature.filePath, actualScenarios: feature.actualScenarios)
            Reporter.logXml(outFeatureFile.description)
            Reporter.logText("\n\(scenarios - failures) scenarios passed, \(failures) scenarios failed.")
            if self.featureCount == 0{
                Reporter.saveLogs()
                Reporter.saveXml()
            }
            self.featureCount--
        }
        
        for (var currentLength = 0; currentLength < length; ++currentLength) {
            var scenario = scenariosVal[currentLength]
            let current = currentLength
            if scenario.meta == .Automated{
                let block : @convention(block) (XCTestCase)->() = { innerSelf in
                    Reporter.logText("Scenario : \(scenario.name)")
                    ++scenarios
                    allSteps += scenario.steps.count
                    for (index, step) in scenario.steps.enumerate() {
                        Reporter.logText("Step : \(step)")
                        let expectation =  AssertionMain.gatherFailingExpectations(){
                            allSteps--
                            let stepRunVal = StepCreator.sharedInstance.runStep(step)
                            print("StepCreator.sharedInstance.runStep(step) : \(stepRunVal)")
                            if !stepRunVal{
                                tryexpect(false, message: "Step Not Defined : \(step)")
                            }
                        }
                        if expectation.count > 0{
                            ++failures
                            Reporter.logText("Step Fails : \(step)")
                            scenario.stepsOut.removeAtIndex(index)
                            scenario.stepsOut.insert(.unsuccessful, atIndex: index)
                            scenariosVal.removeAtIndex(current)
                            scenariosVal.insert(scenario, atIndex: current)
                        }
                        if allSteps == 0 && scenarios == endAutoCount{
                            completion()
                        }
                    }
                }
                let imp = imp_implementationWithBlock(unsafeBitCast(block, AnyObject.self))
                let strSelName: String = "test_\(scenario.name.camelCaseify)"
                let selName = strdup(strSelName)
                let sel = sel_registerName(selName)
                
                let success = class_addMethod(testCaseClass, sel, imp, typeString)
                XCTAssertTrue(success, "Failed to add class method \(sel)")
            }
        }
        
        
        objc_registerClassPair(testCaseClass)
        
        testCaseClass.testInvocations().sort { (a,b) in NSStringFromSelector(a.selector) > NSStringFromSelector(b.selector) }.forEach { invocation in
            let testCase = (testCaseClass as! XCTestCase.Type).init(invocation: invocation)
            testCase.runTest()
            }
        }
    }