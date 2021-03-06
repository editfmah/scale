//
//  Globals.swift
//  scale
//
//  Created by Adrian Herridge on 31/01/2017.
//
//

import Foundation
import SWSQLite

public struct DefaultSchemas {
    
    let System: [Action] = [
        
        Action(createTable: "ShardLocation"),
        Action(addColumn: "shardId", type: .String, table: "ShardLocation"),
        Action(addColumn: "node", type: .String, table: "ShardLocation"),
        Action(addColumn: "available", type: .Int, table: "ShardLocation"),
        
        Action(createTable: "Node"),
        Action(addColumn: "locationId", type: .String, table: "Node"),
        Action(addColumn: "nodegroup", type: .String, table: "Node"),
        Action(addColumn: "available", type: .Int, table: "Node"),
        Action(addColumn: "last_seen", type: .Int, table: "Node"),
        Action(addColumn: "internalAddress", type: .String, table: "Node"),
        Action(addColumn: "internalPort", type: .Int, table: "Node"),
        Action(addColumn: "externalAddress", type: .String, table: "Node"),
        Action(addColumn: "externalPort", type: .Int, table: "Node"),
        Action(addColumn: "spaceUsed", type: .Int, table: "Node"),
        Action(addColumn: "spaceFree", type: .Int, table: "Node"),
        
    ]
    
}

public struct DefaultIdentifiers {
    let SystemShardKeyspace = "***system-shard-keyspace***"
    let SystemShardParition = "***system-shard-partition***"
}

public struct DefaultNodeDescriptions {
    let Identifiers: DefaultIdentifiers = DefaultIdentifiers()
}

let Node: DefaultNodeDescriptions = DefaultNodeDescriptions()

