//
//  Reporter.swift
//  Parser
//
//  Created by Rahul Malik on 2/9/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import Foundation

public class Reporter {
    
    struct Key {
        static let fileText = "logs.txt"
        static let fileXml = "out.xml"
    }
    
    static let sharedInstance = Reporter()
    var text = ""
    var xml = ""
    var log: Bool = true
    let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    func logText (str: String) {
        self.text.appendContentsOf("\(str)\n")
        if log{
            print(str)
        }
    }
    func logXml (str: String) {
        self.xml.appendContentsOf("\(str)\n")
    }
    func saveLogs(){
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent(Key.fileText)
        do{
            try text.writeToURL(fileDestinationUrl, atomically: true, encoding: NSUTF8StringEncoding)
            print("fileDestinationUrl : \(fileDestinationUrl)")
        } catch let error as NSError {
            print("error writing to url \(fileDestinationUrl)")
            print(error.localizedDescription)
        }
    }
    func saveXml(){
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent(Key.fileXml)
        do{
            try self.xml.writeToURL(fileDestinationUrl, atomically: true, encoding: NSUTF8StringEncoding)
            print("fileDestinationUrl : \(fileDestinationUrl)")
        } catch let error as NSError {
            print("error writing to url \(fileDestinationUrl)")
            print(error.localizedDescription)
        }
    }
}
