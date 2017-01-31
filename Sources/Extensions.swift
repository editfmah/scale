//
//  Extensions.swift
//  scale
//
//  Created by Adrian Herridge on 30/01/2017.
//
//

import Foundation
import SwiftKuery
import SwiftKuerySQLite

public extension SQLiteConnection {
    
    internal func execute(_ raw: [SQLAction], onCompletion: @escaping (() -> ())) {
        
        for stmt in raw {
            execute(stmt.builtStatement, onCompletion: { (QueryResult) in
                
            })
        }
        
        onCompletion()
        
    }
    
}
