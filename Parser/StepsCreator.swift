//
//  StepsCreator.swift
//  Parser
//
//  Created by Rahul Malik on 07/02/16.
//  Copyright © 2016 Rahul Malik. All rights reserved.
//

import Foundation
public typealias completionBlock = (String?) -> ()
public struct StepHandler {
    public typealias Handler = (RegexMatch) throws -> ()

  let expression: Regex
  let handler: Handler

  init(expression: Regex, handler: Handler) {
    self.expression = expression
    self.handler = handler
  }
}

enum StepError: ErrorType, CustomStringConvertible {
  case NoMatch(Step)
  case AmbiguousMatch(Step, [StepHandler])
  case NotTrue(String)

  var description: String {
    switch self {
    case .NotTrue(let str):
        return "\(str) : Expectation not true"
    case .NoMatch:
        return "No matches found"
    case .AmbiguousMatch(let handlers):
        let matches = handlers.1.map { "       - `\($0.expression)`" }.joinWithSeparator("\n")
        return "Too many matches found:\n\(matches)"
    }
  }
}


public class StepCreator {
    
    struct Key {
        static let suitesFile = Config.suitesFile.componentsSeparatedByString(".")[0]
        static let suitesExtention = Config.suitesFile.componentsSeparatedByString(".")[1]
    }
    
    let operationQueue: NSOperationQueue = NSOperationQueue()
    
    private func operationInit(){
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = "BDD-queue"
    }
    
    static let sharedInstance: StepCreator = StepCreator()
    var givens: [StepHandler] = []
    var whens: [StepHandler] = []
    var thens: [StepHandler] = []
    var ands: [StepHandler] = []
    
    init(){
        operationInit()
    }
    
    public func given(expression: String, closure: StepHandler.Handler) {
        let regex = try! Regex(expression: expression)
        let handler = StepHandler(expression: regex, handler: closure)
        givens.append(handler)
    }
    
    public func then(expression: String, closure: StepHandler.Handler) {
        let regex = try! Regex(expression: expression)
        let handler = StepHandler(expression: regex, handler: closure)
        thens.append(handler)
    }
    
    public func when(expression: String, closure: StepHandler.Handler) {
        let regex = try! Regex(expression: expression)
        let handler = StepHandler(expression: regex, handler: closure)
        whens.append(handler)
    }
    
    public func and(expression: String, closure: StepHandler.Handler) {
        let regex = try! Regex(expression: expression)
        let handler = StepHandler(expression: regex, handler: closure)
        ands.append(handler)
    }
    
    func runStep(step: Step) -> Bool {
        var failure: ErrorType? = nil
        var execVal: (StepHandler, RegexMatch)? = nil
        switch step {
        case .Given(let given):
            do {
                execVal = try findStep(step, name: given)
            } catch {
                failure = error
            }
        case .When(let when):
            do {
                execVal = try findStep(step, name: when)
            } catch {
                failure = error
            }
        case .Then(let then):
            do {
                execVal = try findStep(step, name: then)
            } catch {
                failure = error
            }
        case .And(let and):
            do {
                execVal = try findStep(step, name: and)
            } catch {
                failure = error
            }
        }
        if let execVal = execVal {
            let (handler,match) = execVal
            do{
                try handler.handler(match)
            }catch{
                failure = error
            }
        }
        
//        if let execVal = execVal {
//            let (handler,match) = execVal
//            var operation: ConcurrentOperation?
//            var currentOperationCompletion:()->()? = { (operation!.completion)($0) }
//            operation = ConcurrentOperation(block: { () -> Void in
//                do{
//                    try handler.handler(match){
//                        currentOperationCompletion()
//                        completion()
//                    }
//                } catch{
//                    failure = error
//                }
//            })
//            currentOperationCompletion = { (operation!.completion)($0) }
//            self.operationQueue.addOperation(operation!)
//        }else{
//            completion()
//        }
        return failure == nil
    }
    
    func findStep(step: Step, name: String) throws -> (StepHandler, RegexMatch) {
        var array: [StepHandler] = []
        switch step{
        case .Given( _):
            array = givens
        case .When( _):
            array = whens
        case .Then( _):
            array = thens
        case .And( _):
            array = ands
        }
        
        let matched = array.filter { $0.expression.matches(name) != nil }
        if matched.count > 1 {
            throw StepError.AmbiguousMatch(step, matched)
        } else if let result = matched.first {
            let match = result.expression.matches(name)!
            return (result, match)
        }
        throw StepError.NoMatch(step)
    }
    
    public func getMyFeatures(filePath: [Path]) -> [Feature]{
        let features = try! FeatureFileParser.sharedInstance.parse(filePath)
        return features
    }
    
    public func testWithFile(filePath: [Path], completion: completionBlock){
        
        //Reporter.sharedInstance.log = false
        
        var scenarios = 0
        var failures = 0
        var allSteps = 0
        let features = try! FeatureFileParser.sharedInstance.parse(filePath)
        for feature in features{
            scenarios = 0
            failures = 0
            allSteps = 0
            var scenariosVal = feature.scenarios
            
            let completionSub: completionBlock = { _ in
                let outFeatureFile = Feature(name: feature.name, scenarios: scenariosVal, filePath: feature.filePath, actualScenarios: feature.actualScenarios)
                Reporter.logXml(outFeatureFile.description)
                Reporter.logText("\n\(scenarios - failures) scenarios passed, \(failures) scenarios failed.")
                Reporter.saveLogs()
                Reporter.saveXml()
                completion(nil)
            }
            
            Reporter.logText("Feature : \(feature.name)")
            for (var i = 0; i < scenariosVal.count; i++) {
                var scenario = scenariosVal[i]
                if scenario.meta == .Automated{
                    Reporter.logText("Scenario : \(scenario.name)")
                    ++scenarios
                    allSteps += scenario.steps.count
                    for (index, step) in scenario.steps.enumerate() {
                        Reporter.logText("Step : \(step)")
                        var outVal: Bool = false
                        outVal = StepCreator.sharedInstance.runStep(step)
                        if !outVal{
                            scenario.stepsOut.removeAtIndex(index)
                            scenario.stepsOut.insert(.unsuccessful, atIndex: index)
                            scenariosVal.removeAtIndex(i)
                            scenariosVal.insert(scenario, atIndex: i)
                            
                            Reporter.logText("Step Fails : \(step)")
                            ++failures
                        }
                        if allSteps == 0{
                            completionSub(nil)
                        }                        
                    }
                }
            }
            
        }
    }
}
public func startMyTest(completion: completionBlock? = nil){
    func getDataFromFile(myurl: String)->NSData{
        let path = NSBundle.mainBundle().pathForResource(myurl, ofType: StepCreator.Key.suitesExtention)!
        let data = try! NSData(contentsOfFile:path,
            options: NSDataReadingOptions.DataReadingUncached)
        return data
    }
    let jsonParser = JsonParser()
    let suites: Suites? = jsonParser.parseJson(jsonParser.parseToJSON(getDataFromFile(StepCreator.Key.suitesFile)), inToClass: Suites.self, keypath: "") as? Suites
    guard let _suites = suites else{
        return
    }
    if let suite = _suites.suite where suite.count > 0{
        for (_, _suite) in suite.enumerate(){
            if let stories = _suite.stories, let type = _suite.type where type == Config.runFeature{
                var filePath: [Path] = []
                for allStories in stories{
                    filePath.append(Path(allStories))
                }
                StepCreator.sharedInstance.testWithFile(filePath){_ in
                    if let completion = completion{
                        completion(nil)
                    }
                }
            }
        }
    }
}

public func getMyFeatures(runFeature: String) -> [Feature]?{
    func getDataFromFile(myurl: String)->NSData{
        let path = NSBundle.mainBundle().pathForResource(myurl, ofType: StepCreator.Key.suitesExtention)!
        let data = try! NSData(contentsOfFile:path,
            options: NSDataReadingOptions.DataReadingUncached)
        return data
    }
    let jsonParser = JsonParser()
    let suites: Suites? = jsonParser.parseJson(jsonParser.parseToJSON(getDataFromFile(StepCreator.Key.suitesFile)), inToClass: Suites.self, keypath: "") as? Suites
    guard let _suites = suites else{
        return nil
    }
    if let suite = _suites.suite where suite.count > 0{
        for (_, _suite) in suite.enumerate(){
            if let stories = _suite.stories, let type = _suite.type where type == runFeature{
                var filePath: [Path] = []
                for allStories in stories{
                    filePath.append(Path(allStories))
                }
                return StepCreator.sharedInstance.getMyFeatures(filePath)
            }
        }
    }
    return nil
}

public func Given(expression: String, closure: StepHandler.Handler) {
  StepCreator.sharedInstance.given(expression, closure: closure)
}

public func When(expression: String, closure: StepHandler.Handler) {
  StepCreator.sharedInstance.when(expression, closure: closure)
}

public func Then(expression: String, closure: StepHandler.Handler) {
  StepCreator.sharedInstance.then(expression, closure: closure)
}

public func And(expression: String, closure: StepHandler.Handler) {
  StepCreator.sharedInstance.and(expression, closure: closure)
}
