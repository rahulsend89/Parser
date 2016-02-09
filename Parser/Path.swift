//
//  Path.swift
//  Parser
//
//  Created by Rahul Malik on 2/9/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import Foundation

public struct Path {
    struct Key {
        static let defaultDir: String = Config.defaultDir
    }
    public let fileName: String
    public let extention: String
    public let content: String?
    
    init(_ fileName: String){
        if !fileName.isEmpty{
            let fileNameAr = fileName.componentsSeparatedByString(".")
            self.fileName = fileNameAr[0]
            self.extention = fileNameAr[1]
            if let path = NSBundle.mainBundle().pathForResource(self.fileName, ofType: self.extention, inDirectory: Path.Key.defaultDir){
                let data = try! String(contentsOfFile:path, encoding: NSUTF8StringEncoding)
                self.content = data
            }else{
                self.content = nil
            }
        }else{
            self.fileName = ""
            self.extention = ""
            self.content = nil
        }
    }
}