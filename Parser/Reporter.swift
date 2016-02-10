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
        static let fileText = Config.textFile
        static let fileXml = Config.xmlFile
    }
    
    static let sharedInstance = Reporter()
    var text = ""
    var xml = ""
    var log: Bool = true
    let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    class func logText (str: String) {
        Reporter.sharedInstance.text.appendContentsOf("\(str)\n")
        if Reporter.sharedInstance.log{
            print(str)
        }
    }
    class func logXml (str: String) {
        Reporter.sharedInstance.xml.appendContentsOf("\(str)\n")
    }
    
    class func saveLogs(){
        let fileDestinationUrl = Reporter.sharedInstance.documentDirectoryURL.URLByAppendingPathComponent(Key.fileText)
        do{
            try Reporter.sharedInstance.text.writeToURL(fileDestinationUrl, atomically: true, encoding: NSUTF8StringEncoding)
            print("fileDestinationUrl : \(fileDestinationUrl)")
        } catch let error as NSError {
            print("error writing to url \(fileDestinationUrl)")
            print(error.localizedDescription)
        }
    }
    class func saveXml(){
        let fileDestinationUrl = Reporter.sharedInstance.documentDirectoryURL.URLByAppendingPathComponent(Key.fileXml)
        do{
            try Reporter.sharedInstance.xml.writeToURL(fileDestinationUrl, atomically: true, encoding: NSUTF8StringEncoding)
            print("fileDestinationUrl : \(fileDestinationUrl)")
        } catch let error as NSError {
            print("error writing to url \(fileDestinationUrl)")
            print(error.localizedDescription)
        }
    }
}
