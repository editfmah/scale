//
//  ShardObject.swift
//  scale
//
//  Created by Adrian Herridge on 06/03/2017.
//
//

import Foundation
import SWSQLite

class _shard_: DataObject {
    
    var version: String?
    var keyspace: String?
    var partition: String?
    
    override public class func GetTables() -> [Action] {
        return [
            
            Action(createTable: "_shard_"),
            Action(addColumn: "version", type: .String, table: "_shard_"),
            Action(addColumn: "keyspace", type: .String, table: "_shard_"),
            Action(addColumn: "partition", type: .String, table: "_shard_"),
            
        ]
    }
    
}
