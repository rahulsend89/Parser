//
//  Step.swift
//  Parser
//
//  Created by Rahul Malik on 2/9/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import Foundation

public enum Step {
    case Given(String)
    case When(String)
    case Then(String)
    case And(String)
}

extension Step: Equatable, CustomStringConvertible{
    var value: String{
        switch self {
        case .Given(let v1):
            return v1
        case .When(let v1):
            return v1
        case .Then(let v1):
            return v1
        case .And(let v1):
            return v1
        }
    }
    mutating func setValue(str: String){
        switch self {
        case .Given( _):
            self = .Given(str)
        case .When( _):
            self = When(str)
        case .Then( _):
            self = Then(str)
        case .And( _):
            self = And(str)
        }
    }
    func isEqual(st: Step)->Bool {
        switch self {
        case .Given(let v1):
            switch st {
            case .Given(let v2): return v1 == v2
            default: return false
            }
        case .When(let v1):
            switch st {
            case .When(let v2): return v1 == v2
            default: return false
            }
        case .Then(let v1):
            switch st {
            case .Then(let v2): return v1 == v2
            default: return false
            }
        case .And(let v1):
            switch st {
            case .And(let v2): return v1 == v2
            default: return false
            }
        }
    }
    public var description: String {
        switch self {
        case .Given(let given):
            return "Given \(given)"
        case .When(let when):
            return "When \(when)"
        case .Then(let then):
            return "Then \(then)"
        case .And(let and):
            return "And \(and)"
        }
    }
}
public func ==(lhs: Step, rhs: Step) -> Bool {
    return lhs.isEqual(rhs)
}