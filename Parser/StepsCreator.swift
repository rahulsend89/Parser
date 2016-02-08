//
//  StepsCreator.swift
//  Parser
//
//  Created by Rahul Malik on 07/02/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import Foundation

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

public class StepCreator  {
    static let sharedInstance = StepCreator()
    var givens: [StepHandler] = []
    var whens: [StepHandler] = []
    var thens: [StepHandler] = []
    var ands: [StepHandler] = []
    
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
        
        switch step {
        case .Given(let given):
            do {
                let (handler, match) = try findStep(step, name: given)
                try handler.handler(match)
            } catch {
                failure = error
            }
        case .When(let when):
            do {
                let (handler, match) = try findStep(step, name: when)
                try handler.handler(match)
            } catch {
                failure = error
            }
        case .Then(let then):
            do {
                let (handler, match) = try findStep(step, name: then)
                try handler.handler(match)
            } catch {
                failure = error
            }
        case .And(let and):
            do {
                let (handler, match) = try findStep(step, name: and)
                try handler.handler(match)
            } catch {
                failure = error
            }
        }
        
        //print("step : \(step) failure: \(failure)")
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
}
public func testWithFile(fileName: String){
    var scenarios = 0
    var failures = 0
    let filePath = Path(fileName)
    let features = try! Feature.parse([filePath])
    for feature in features {
        print("Feature : \(feature.name)")
        for scenario in feature.scenarios {
            print("Fcenario : \(scenario.name)")
            ++scenarios
            for step in scenario.steps {
                print("Step : \(step)")
                if !StepCreator.sharedInstance.runStep(step) {
                    print("Step Fails : \(step)")
                    ++failures
                    break
                }
            }
        }
    }
    print("\n\(scenarios - failures) scenarios passed, \(failures) scenarios failed.")
    if failures > 0 {
        //exit(1)
    }
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
public func expect(val: Bool)throws{
    if !val{
        throw StepError.NotTrue("")
    }
}
