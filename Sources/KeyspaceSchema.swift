//
//  KeyspaceSchema.swift
//  scale
//
//  Created by Adrian Herridge on 17/04/2017.
//
//

import Foundation
import SWSQLite

class KeyspaceSchema : DataObject, DataObjectProtocol {
    
    var keyspace: String?
    var version: String?
    var change: String?
    
    override func populateFromRecord(_ record: Record) {
        self.keyspace = record["keyspace"]?.asString()
        self.version = record["version"]?.asString()
        self.change = record["change"]?.asString()
    }
    
    override class func GetTables() -> [Action] {
        return [ Action(createTable: "KeyspaceSchema"),
                 Action(addColumn: "keyspace", type: .String, table: "KeyspaceSchema"),
                 Action(addColumn: "version", type: .String, table: "KeyspaceSchema"),
                 Action(addColumn: "change", type: .String, table: "KeyspaceSchema") ]
    }
    
    class func ToCollection(_ records: [Record]) -> [KeyspaceSchema] {
        var results: [KeyspaceSchema] = []
        for record in records {
            results.append(KeyspaceSchema(record))
        }
        return results
    }
    
}
