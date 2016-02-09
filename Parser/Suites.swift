//
//  Suites.swift
//  Parser
//
//  Created by Rahul Malik on 2/9/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import Foundation

class Suites: ModelClass {
    
    var suite: [Suite]?
    
    func initWithData(dict: NSDictionary) {
        let parentNode = dict.valueForKey("Suites") as? NSDictionary
        self.suite = JsonParser().iterateJsonObject(parentNode?.valueForKey("Suite"), intoClass: Suite.self) as? [Suite]
    }
    
    convenience required init(dictionary dict: NSDictionary) {
        self.init()
        self.initWithData(dict)
    }
}

class Suite: ModelClass {
    var type: String?
    var stories: [String]?
    
    func initWithData(dict: NSDictionary) {
        self.type = dict.valueForKey("type") as? String
        self.stories = dict.valueForKey("Stories") as? [String]
    }
    
    convenience required init(dictionary dict: NSDictionary) {
        self.init()
        self.initWithData(dict)
    }
}