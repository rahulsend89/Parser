//
//  Meta.swift
//  Parser
//
//  Created by Rahul Malik on 2/9/16.
//  Copyright © 2016 Rahul Malik. All rights reserved.
//

import Foundation

public enum Meta{
    case Automated
    case Pending
    case Manual
    case Unknown
    
    init(var value: String){
        value = value.substringFromIndex(value.startIndex.advancedBy(1))
        if value == "automated" {
            self = .Automated
        } else if value == "pending" {
            self = .Pending
        } else if value == "manual" {
            self = .Manual
        } else{
            self = .Unknown
        }
    }
}