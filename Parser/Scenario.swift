//
//  Scenario.swift
//  Parser
//
//  Created by Rahul Malik on 2/9/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import Foundation

public struct Scenario {
    public let name: String
    public var steps: [Step]{
        didSet{
            self.stepsOut = []
            for _ in self.steps{
                self.stepsOut.append(.successful)
            }
        }
    }
    public var stepsOut: [OutCome]
    public var examples: Example?
    public var meta: Meta
    
    public let file: Path
    public let line: Int
    
    init(name: String, steps: [Step], file: Path, line: Int, examples: Example? = nil, meta: String = "@pending") {
        self.name = name
        self.steps = steps
        self.stepsOut = []
        for _ in steps{
            self.stepsOut.append(.successful)
        }
        self.file = file
        self.line = line
        self.examples = examples
        self.meta = Meta(value: meta)
    }
    mutating func setMeta(meta: String){
        self.meta = Meta(value: meta)
    }
    mutating func setExample(example: Example){
        self.examples = example
    }
}