//
//  KeyspaceQuery.swift
//  scale
//
//  Created by Adrian Herridge on 17/04/2017.
//
//

import Foundation

class ShardRead {
    
    init(_ request: Request) {
        
        let payload = request.payload()
        let shard = Shards.getShard(keyspace: payload.keyspace, partition: payload.partition)
        
        // now we build the query
        let stmt = "SELECT \(payload.columns.joined(separator: ",")) FROM \(payload.table) WHERE \(payload.whereStmt) ORDER BY \(payload.order) LIMIT \(payload.limit) OFFSET \(payload.offset)"
        
        let results = shard.read(sql: stmt, params: payload.parameters)
        if results.error != nil {
            // an error occoured with the query, send this back to the client
            request.setError("Error in query request: \(results.error!)")
            request.setResults([])
        } else {
            request.setResults(results.results)
        }
        
        Shards.returnShard(shard: shard)
        
    }
    
}
