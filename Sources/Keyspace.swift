//
//  Keyspace.swift
//  scale
//
//  Created by Adrian Herridge on 17/02/2017.
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

class Keyspace : DataObject {
    
    // object vars
    var name: String?
    var replication: NSNumber?
    var size: NSNumber?
    
    convenience init(_name: String, _replication: Int, _size: Int) {
        self.init()
        self.name = _name
        self.replication = NSNumber(value: _replication)
        self.size = NSNumber(value: _size)
    }
    
    override class func GetTables() -> [Action] {
        var actions = [
            Action(createTable: "Keyspace"),
            Action(addColumn: "name", type: .String, table: "Keyspace"),
            Action(addColumn: "replication", type: .Numeric, table: "Keyspace"),
            Action(addColumn: "size", type: .Numeric, table: "Keyspace")
        ]
        
        actions.append(contentsOf: KeyspaceSchema.GetTables())
        
        return actions
    }
    
    // data manipulation and creation functions
    class func CreateKeyspace(keyspace: String, replication: Int) -> String {
        let sys = Shards.systemShard()
        var sysKeyspaces: [Keyspace] = []
        for record in sys.read(sql: "SELECT * FROM Keyspace WHERE name = ? LIMIT 1", params: [keyspace]) {
            let k = Keyspace(record)
            sysKeyspaces.append(k)
        }
        var keyspaceId: String? = nil
        if sysKeyspaces.count == 0 {
            let newKeyspace = Keyspace()
            keyspaceId = newKeyspace._id_
            newKeyspace.name = keyspace
            newKeyspace.replication = NSNumber(value: replication)
            newKeyspace.size = 0
            sys.write(newKeyspace.Commit())
        } else {
            
            let record = sysKeyspaces[0]
            keyspaceId = record._id_
        
            let rep = record.replication
            if rep?.intValue != replication {
                record.replication = NSNumber(value: replication)
                sys.write(record.Commit())
            }
        }
        return keyspaceId!
    }
    
}
