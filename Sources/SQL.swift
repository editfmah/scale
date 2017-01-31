//
//  SQL.swift
//  scale
//
//  Created by Adrian Herridge on 31/01/2017.
//
//

import Foundation

enum SQLColumnType {
    case String
    case Number
    case Integer
    case Blob
}

enum SQLActionType {
    case CreateTable
    case AddColumn
}

class SQL {
    
    class func generate(actions: [SQLAction]) -> [String] {
        
        var stmts: [String] = []
        for action in actions {
            
            stmts.append(action.builtStatement)
            
        }
        
        return stmts
        
    }
    
}

class SQLAction {
    
    var builtStatement: String
    var actionType: SQLActionType
    
    init(createTable: String) {
        actionType = .CreateTable
        builtStatement = "CREATE TABLE IF NOT EXISTS \(createTable) (_Id_ TEXT PRIMARY KEY, _timestamp_ TEXT); "
    }
    
    init(addColumn: String, type: SQLColumnType, table: String) {
        
        self.actionType = .AddColumn
        
        switch type {
        case .String:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) TEXT;"
        case .Number:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) NUMERIC;"
        case .Integer:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) INTEGER;"
        default:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) BLOB;"
        }
        
    }
    
}
