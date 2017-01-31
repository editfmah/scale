//
//  Globals.swift
//  scale
//
//  Created by Adrian Herridge on 31/01/2017.
//
//

import Foundation

public struct DefaultSchemas {
    
    let System: [SQLAction] = [
    
        SQLAction(createTable: "Keyspace"),
        SQLAction(addColumn: "name", type: .String, table: "Keyspace"),
        SQLAction(addColumn: "replication", type: .Integer, table: "Keyspace"),
        SQLAction(addColumn: "size", type: .Integer, table: "Keyspace"),
        
        SQLAction(createTable: "KeyspaceSchema"),
        SQLAction(addColumn: "keyspace_id", type: .String, table: "KeyspaceSchema"),
        SQLAction(addColumn: "change", type: .String, table: "KeyspaceSchema"),
        
        SQLAction(createTable: "Shard"),
        SQLAction(addColumn: "keyspace_id", type: .String, table: "Shard"),
        SQLAction(addColumn: "keyspace_name", type: .String, table: "Shard"),
        SQLAction(addColumn: "partition", type: .String, table: "Shard"),
        SQLAction(addColumn: "replicas", type: .Integer, table: "Shard"),
        
        SQLAction(createTable: "ShardLocation"),
        SQLAction(addColumn: "shard_id", type: .String, table: "ShardLocation"),
        SQLAction(addColumn: "node", type: .String, table: "ShardLocation"),
        SQLAction(addColumn: "available", type: .Integer, table: "ShardLocation"),
        
        SQLAction(createTable: "Node"),
        SQLAction(addColumn: "location_id", type: .String, table: "Node"),
        SQLAction(addColumn: "group", type: .String, table: "Node"),
        SQLAction(addColumn: "available", type: .Integer, table: "Node"),
        SQLAction(addColumn: "last_seen", type: .Integer, table: "Node"),
        SQLAction(addColumn: "internal_address", type: .String, table: "Node"),
        SQLAction(addColumn: "internal_port", type: .Integer, table: "Node"),
        SQLAction(addColumn: "external_address", type: .String, table: "Node"),
        SQLAction(addColumn: "external_port", type: .Integer, table: "Node"),
        SQLAction(addColumn: "space_used", type: .Integer, table: "Node"),
        SQLAction(addColumn: "space_free", type: .Integer, table: "Node")
        
    ]
    
    let Partition: String = ""
    
}

public struct DefaultIdentifiers {
    let SystemShardKeyspace = "***system-shard-keyspace***"
    let SystemShardParition = "***system-shard-partition***"
}

public struct DefaultNodeDescriptions {
    let Schemas: DefaultSchemas = DefaultSchemas()
    let Identifiers: DefaultIdentifiers = DefaultIdentifiers()
}

let Node: DefaultNodeDescriptions = DefaultNodeDescriptions()
