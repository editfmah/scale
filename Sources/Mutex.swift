//
//  Mutex.swift
//  scale
//
//  Created by Adrian Herridge on 06/02/2017.
//
//

import Foundation

class Mutex {
    
    private var lock: DispatchQueue
    private var locked: Bool = false
    private var thread: Thread? = nil;
    
    init() {
        lock = DispatchQueue(label:UUID().uuidString)
    }
    
    func mutex(_ closure: ()->()) {
        if !locked {
            locked = true
            thread = Thread.current
            lock.sync {
                closure()
            }
            thread = nil
            locked = false
        } else {
            if thread == Thread.current {
                closure()
            } else {
                // the lock has been requested on another thread, so we can queue this up on the sync
                lock.sync {
                    closure()
                }
            }
        }
    }
    
}
