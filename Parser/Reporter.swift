//
//  Reporter.swift
//  Parser
//
//  Created by Rahul Malik on 2/9/16.
//  Copyright © 2016 CitiusTech. All rights reserved.
//

import Foundation

public class Reporter {
    static let sharedInstance = Reporter()
    let file = "logs.txt"
    var text = ""
    var log: Bool = true
    let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    func logText (str: String) {
        self.text.appendContentsOf("\(str)\n")
        if log{
            print(str)
        }
    }
    func saveLogs(){
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent(file)
        do{
            try text.writeToURL(fileDestinationUrl, atomically: true, encoding: NSUTF8StringEncoding)
            print("fileDestinationUrl : \(fileDestinationUrl)")
        } catch let error as NSError {
            print("error writing to url \(fileDestinationUrl)")
            print(error.localizedDescription)
        }
    }
    func saveLogs(val: String){
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent("out.xml")
        do{
            try val.writeToURL(fileDestinationUrl, atomically: true, encoding: NSUTF8StringEncoding)
            print("fileDestinationUrl : \(fileDestinationUrl)")
        } catch let error as NSError {
            print("error writing to url \(fileDestinationUrl)")
            print(error.localizedDescription)
        }
    }
}
