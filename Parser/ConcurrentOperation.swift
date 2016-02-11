//
//  ConcurrentOperation.swift
//  HealthConnect
//
//  Created by Rahul Malik on 19/12/15.
//  Copyright © 2015 citiustech. All rights reserved.
//

import Foundation

class ConcurrentOperation: NSBlockOperation {
    lazy var completion:()->() = {
        self.completeOperation()
    }
    func completeOperation() {
        state = .Finished
    }
    enum State: String {
        case Ready, Executing, Finished
        
        private var keyPath: String {
            return "is" + rawValue
        }
    }
    
    var state = State.Ready {
        willSet {
            willChangeValueForKey(newValue.keyPath)
            willChangeValueForKey(state.keyPath)
        }
        didSet {
            didChangeValueForKey(oldValue.keyPath)
            didChangeValueForKey(state.keyPath)
        }
    }
}

extension ConcurrentOperation {
    //: NSOperation Overrides
    override var ready: Bool {
        return super.ready && state == .Ready
    }
    
    override var executing: Bool {
        return state == .Executing
    }
    
    override var finished: Bool {
        return state == .Finished
    }
    
    override var asynchronous: Bool {
        return false
    }
    
    override func start() {
        if cancelled {
            state = .Finished
            return
        }
        
        main()
        state = .Executing
    }
    
    override func cancel() {
        state = .Finished
    }
}
