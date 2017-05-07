//
//  Mutex.swift
//  scale
//
//  Created by Adrian Herridge on 06/02/2017.
//
//

import Foundation
import Dispatch
import SWSQLite

class Mutex {
    
    private var thread: Thread? = nil;
    private var lock: DispatchQueue
    
    init() {
        lock = DispatchQueue(label: uuid())
    }
    
    func mutex(_ closure: ()->()) {
        if thread != Thread.current {
            lock.sync {
                thread = Thread.current
                closure()
                thread = nil
            }
        } else {
            closure()
        }
    }
    
}
