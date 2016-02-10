//
//  Example.swift
//  Parser
//
//  Created by Rahul Malik on 2/9/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import Foundation

public struct Example {
    public var dictionaryArray: Dictionary<String,[String]>
    public var line: Int
    public var count: Int
    public var currentStep: Int
    public var steps: [Step]
    init(dictionaryArray: Dictionary<String,[String]>,line: Int,steps: [Step] = [], currentStep: Int = 0) {
        self.dictionaryArray = dictionaryArray
        self.count = 0
        self.line = line
        self.steps = steps
        self.currentStep = currentStep
    }
    mutating func setDictionaryArray(dictionaryArray: Dictionary<String,[String]>){
        self.dictionaryArray = dictionaryArray
        for (_,strAr) in dictionaryArray.enumerate(){
            self.count = strAr.1.count
            break
        }
    }
}
