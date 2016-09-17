//
//  Feature.swift
//  Parser
//
//  Created by Rahul Malik on 2/9/16.
//  Copyright © 2016 Rahul Malik. All rights reserved.
//

import Foundation

public struct Feature: CustomStringConvertible {
    public let name: String
    public let filePath: String
    public let scenarios: [Scenario]
    public var actualScenarios: [Scenario]
    
    init(name: String, scenarios: [Scenario], filePath: String, actualScenarios: [Scenario] = []) {
        self.name = name
        self.scenarios = scenarios
        self.filePath = filePath
        self.actualScenarios = actualScenarios
    }
    private func appendExample(str: String,index: Int,scenariosIndex: Int) -> String{
        var returnExampleString = str
        let logicalScenarioPointer = scenariosIndex + index
        let scenario = self.scenarios[logicalScenarioPointer]
        if let examples = scenario.examples{
            returnExampleString.appendContentsOf("<example keyword=\"Examples:\">{")
            for (index,val) in examples.dictionaryArray.enumerate(){
                let addLimiter = (index != examples.dictionaryArray.count-1) ? ", " : ""
                returnExampleString.appendContentsOf("\(val.0)=\(val.1[examples.currentStep])\(addLimiter)")
                
            }
            returnExampleString.appendContentsOf("}</example>\n")
            for (indexVal,step) in examples.steps.enumerate(){
                let outCome = scenario.stepsOut[indexVal]
                if outCome == .unsuccessful{
                    returnExampleString.appendContentsOf("<step outcome=\"\(outCome)\" keyword=\"FAILED\">\(step.description)<failure>false</failure></step>\n")
                }else{
                    returnExampleString.appendContentsOf("<step outcome=\"\(outCome)\">\(step.description)</step>\n")
                }
            }
        }
        return returnExampleString
    }
    private func appendExamples(str: String) -> String{
        var returnExampleString = str
        var currentScenario = 0
        for scenario in self.actualScenarios{
            if scenario.examples != nil{
                returnExampleString.appendContentsOf("<examples keyword=\"Examples:\">\n")
                if let examples = scenario.examples{
                    for (_,step) in examples.steps.enumerate(){
                        returnExampleString.appendContentsOf("<step>\(step.description.htmlEncode)</step>\n")
                    }
                    returnExampleString.appendContentsOf("<names>\n")
                    for (_,valueAr) in examples.dictionaryArray.enumerate(){
                        returnExampleString.appendContentsOf("<name>\(valueAr.0)</name>\n")
                    }
                    returnExampleString.appendContentsOf("</names>\n")
                    
                    returnExampleString.appendContentsOf("<parameters>\n")
                    for (var i=0; i < examples.count;i++){
                        returnExampleString.appendContentsOf("<values>\n")
                        for (_,valueAr) in examples.dictionaryArray.enumerate(){
                            returnExampleString.appendContentsOf("<value>\(valueAr.1[i])</value>\n")
                        }
                        returnExampleString.appendContentsOf("</values>\n")
                    }
                    returnExampleString.appendContentsOf("</parameters>\n")
                    for (var i=0; i < examples.count;i++){
                        returnExampleString = appendExample(returnExampleString,index: i,scenariosIndex: currentScenario)
                    }
                }
                returnExampleString.appendContentsOf("</examples>")
            }
            currentScenario++
        }
        
        return returnExampleString
    }
    public var description: String {
        var text = "<story path=\"features\\\(filePath)\" title=\"\(name)\">\n"
        for scenario in scenarios where scenario.examples == nil{
            text.appendContentsOf("<scenario keyword=\"Scenario:\" title=\"\(scenario.name)\">\n")
            let metaString = "\(scenario.meta)".lowercaseString
            text.appendContentsOf("<meta>\n<property keyword=\"@\" name=\"\(metaString)\" value=\"\"/>\n</meta>\n")
            for (index,step) in scenario.steps.enumerate(){
                let outCome = scenario.stepsOut[index]
                if outCome == .unsuccessful{
                    text.appendContentsOf("<step outcome=\"\(outCome)\" keyword=\"FAILED\">\(step.description)<failure>false</failure></step>\n")
                }else{
                    text.appendContentsOf("<step outcome=\"\(outCome)\">\(step.description)</step>\n")
                }
            }
            text.appendContentsOf("</scenario>\n")
        }
        text = appendExamples(text)
        text.appendContentsOf("</story>\n")
        return text
    }
}

extension String{
    var htmlEncode: String {
        guard (self != "") else { return self }
        var newStr = self
        let entities = [
            "&quot;"    : "\"",
            "&amp;"     : "&",
            "&apos;"    : "'",
            "&lt;"      : "<",
            "&gt;"      : ">",
        ]
        for (name,value) in entities {
            newStr = newStr.stringByReplacingOccurrencesOfString(value, withString: name)
        }
        return newStr
    }
    
    var camelCaseify: String {
        get {
            let separators = NSCharacterSet(charactersInString: " -")
            if self.rangeOfCharacterFromSet(separators) == nil {
                return self.uppercaseFirstLetterString
            }
            return self.lowercaseString.componentsSeparatedByCharactersInSet(separators).filter {
                // Empty sections aren't interesting
                $0.characters.count > 0
                }.map {
                    // Uppercase each word
                    $0.uppercaseFirstLetterString
                }.joinWithSeparator("_")
        }
    }
    
    var uppercaseFirstLetterString: String {
        get {
            let s = self as NSString
            guard s.length>0 else {
                return self
            }
            return s.substringToIndex(1).uppercaseString.stringByAppendingString(s.substringFromIndex(1))
        }
    }
    
    var humanReadableString: String {
        get {
            // This is probably easier in NSStringland
            let s = self as NSString
            
            // The output string can start with the first letter
            var o = s.substringToIndex(1)
            
            // For each other letter, if it's the same as it's uppercase counterpart, insert a space before it
            for (var i = 1; i < s.length; ++i) {
                let l = s.substringWithRange(NSMakeRange(i, 1))
                let u = l.uppercaseString
                
                if (u == l) {
                    o += " "
                }
                
                o += l
            }
            
            return o
        }
    }

}
