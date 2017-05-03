//
//  ShardObject.swift
//  scale
//
//  Created by Adrian Herridge on 06/03/2017.
//
//

import Foundation
import SWSQLite

class _shard_: DataObject, DataObjectProtocol {
    
    var keyspace_version: String?
    var template_version: String?
    var keyspace: String?
    var partition: String?
    
    override func populateFromRecord(_ record: Record) {
        self.keyspace = record["keyspace"]?.asString()
        self.keyspace_version = record["keyspace_version"]?.asString()
        self.template_version = record["template_version"]?.asString()
        self.partition = record["partition"]?.asString()
    }
    
    override public class func GetTables() -> [Action] {
        return [
            
            Action(createTable: "_shard_"),
            Action(addColumn: "keyspace_version", type: .String, table: "_shard_"),
            Action(addColumn: "template_version", type: .String, table: "_shard_"),
            Action(addColumn: "keyspace", type: .String, table: "_shard_"),
            Action(addColumn: "partition", type: .String, table: "_shard_"),
            
        ]
    }
    
}
