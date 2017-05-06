//
//  Keyspace.swift
//  scale
//
//  Created by Adrian Herridge on 17/02/2017.
//
//

import Foundation
import SWSQLite

class Keyspace : DataObject {
    
    // object vars
    var name: String?
    var replication: Int?
    var size: Int?
    var template: String?
    
    convenience init(_name: String, _replication: Int, _size: Int, _template: String?) {
        self.init()
        self.name = _name
        self.replication = _replication
        self.size = _size
    }
    
    override func populateFromRecord(_ record: Record) {
        self.name = record["name"]?.asString()
        self.template = record["template"]?.asString()
        self.replication = record["replication"]?.asInt()
        self.size = record["size"]?.asInt()
    }
    
    override class func GetTables() -> [Action] {
        var actions = [
            Action(createTable: "Keyspace"),
            Action(addColumn: "name", type: .String, table: "Keyspace"),
            Action(addColumn: "replication", type: .Int, table: "Keyspace"),
            Action(addColumn: "size", type: .Int, table: "Keyspace"),
            Action(addColumn: "template", type: .String, table: "Keyspace")
        ]
        
        actions.append(contentsOf: KeyspaceSchema.GetTables())
        
        return actions
    }
    
    // data manipulation and creation functions
    class func Create(_ keyspace: String, replication: Int, template: String?) -> String {
        let sys = Shards.systemShard()
        var sysKeyspaces: [Keyspace] = []
        for record in sys.read(sql: "SELECT * FROM Keyspace WHERE name = ? LIMIT 1", params: [keyspace]).results {
            let k = Keyspace(record)
            sysKeyspaces.append(k)
        }
        var keyspaceId: String? = nil
        if sysKeyspaces.count == 0 {
            let newKeyspace = Keyspace()
            keyspaceId = newKeyspace._id_
            newKeyspace.name = keyspace
            newKeyspace.replication = replication
            newKeyspace.size = 0
            newKeyspace.template = template
            _ = sys.write(newKeyspace.Commit())
        } else {
            
            let record = sysKeyspaces[0]
            keyspaceId = record._id_
            let rep = record.replication
            if rep != replication {
                record.replication = replication
                _ = sys.write(record.Commit())
            }
            
        }
        return keyspaceId!
    }
    
    class func Exists(_ keyspace: String) -> Bool {
        let sys = Shards.systemShard()
        let count = sys.read(sql: "SELECT NULL FROM Keyspace WHERE name = ?", params: [keyspace])
        if count.results.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    class func Get(_ keyspace: String) -> Keyspace? {
        let sys = Shards.systemShard()
        let k = sys.read(sql: "SELECT * FROM Keyspace WHERE name = ?", params: [keyspace])
        if k.results.count > 0 {
            for record in k.results {
                let key = Keyspace(record)
                return key
            }
        }
        return nil
    }
    
}
