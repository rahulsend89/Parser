//
//  AssertionDispatcher.swift
//  Parser
//
//  Created by Rahul Malik on 13/02/16.
//  Copyright © 2016 Rahul Malik. All rights reserved.
//

import Foundation
import XCTest

protocol AssertionProto {
    func assert(assertion: Bool, message: String, location: AssertionMain.codeLocation)
}
public func tryexpect(val: Bool, filename: StaticString = #file, lineNo: UInt = #line, message: String) {
    AssertionMain.expect(val, filename: filename, lineNo: lineNo, message: message)
}

class AssertionMain {
    struct AssertionRecord: CustomStringConvertible {
        let success: Bool
        let message: String
        let location: AssertionMain.codeLocation
        var description: String {
            return "AssertionRecord { success=\(success), message='\(message)', location=\(location) }"
        }
    }
    
    class AssertionRecorder: AssertionProto {
        var assertions = [AssertionRecord]()
        init() {}
        func assert(assertion: Bool, message: String, location: AssertionMain.codeLocation) {
            assertions.append(
                AssertionRecord(
                    success: assertion,
                    message: message,
                    location: location))
        }
    }
    
    class func withAssertionHandler(tempAssertionHandler: AssertionProto, closure: () throws -> Void) {
        let oldRecorder = Assertion.sharedInstance
        let capturer = ExceptionCapture() { _ in
            Assertion.sharedInstance = oldRecorder
        }
        Assertion.sharedInstance = tempAssertionHandler
        capturer.tryBlock {
            try! closure()
        }
    }
    
    class func gatherExpectations(closure: () -> Void) -> [AssertionRecord] {
        let previousRecorder = Assertion.sharedInstance
        let recorder = AssertionRecorder()
        let handlers: [AssertionProto]
        handlers = [recorder, previousRecorder]
        let dispatcher = Dispatcher(handlers: handlers)
        withAssertionHandler(dispatcher, closure: closure)
        return recorder.assertions
    }
    
    class func gatherFailingExpectations(closure: () -> Void) -> [AssertionRecord] {
        let assertions = gatherExpectations(closure)
        return assertions.filter { assertion in
            !assertion.success
        }
    }
    
    class Dispatcher: AssertionProto {
        let handlers: [AssertionProto]
        init(handlers: [AssertionProto]) {
            self.handlers = handlers
        }
        func assert(assertion: Bool, message: String, location: codeLocation) {
            for handler in handlers {
                handler.assert(assertion, message: message, location: location)
            }
        }
    }
    
    
    class codeLocation: NSObject {
        let file: StaticString
        let line: UInt
        override init() {
            file = "Unknown File"
            line = 0
        }
        init(file: StaticString, line: UInt) {
            self.file = file
            self.line = line
        }
        override var description: String {
            return "\(file):\(line)"
        }
    }
    
    class ExceptionCapture {
        var handler: ((ErrorType) -> ())?
        var error: ErrorType?
        var description: String {
            return "\(self.error)"
        }
        init(_ handler: ((ErrorType) -> ())?) {
            self.handler = handler
        }
        func tryBlock(@noescape unsafeBlock: () throws -> () ) {
            do {
                try unsafeBlock()
            } catch let exception {
                if let handler = self.handler {
                    handler(exception)
                }
            }
        }
    }
    
    class Assertion: AssertionProto {
        static var sharedInstance: AssertionProto = Assertion()
        func assert(assertion: Bool, message: String, location: codeLocation) {
            if !assertion {
                XCTFail("\(message)\n", file: location.file, line: location.line)
            }
        }
    }
    class func expect(val: Bool, filename: StaticString = #file, lineNo: UInt = #line, message: String) {
        Assertion.sharedInstance.assert(val, message: "_\(message)", location: codeLocation(file: filename, line: lineNo))
    }
}
