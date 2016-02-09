//
//  Feature.swift
//  Parser
//
//  Created by Rahul Malik on 2/9/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import Foundation

public struct Feature: CustomStringConvertible {
    public let name: String
    public let filePath: String
    public let scenarios: [Scenario]
    
    init(name: String, scenarios: [Scenario], filePath: String) {
        self.name = name
        self.scenarios = scenarios
        self.filePath = filePath
    }
    
    public var description: String {
        var text = "<story path=\"features\\\(filePath)\" title=\"\(name)\">\n"
        for scenario in scenarios{
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
        text.appendContentsOf("</story>\n")
        return text
    }
}
