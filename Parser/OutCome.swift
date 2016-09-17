//
//  OutCome.swift
//  Parser
//
//  Created by Rahul Malik on 2/9/16.
//  Copyright © 2016 Rahul Malik. All rights reserved.
//

import Foundation

public enum OutCome: CustomStringConvertible {
    case unsuccessful
    case successful
    public var description: String {
        switch self {
        case .successful:
            return "successful"
        case .unsuccessful:
            return "failed"
        }
    }
}
