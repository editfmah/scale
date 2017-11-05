//
//  ShardDelete.swift
//  scale
//
//  Created by Adrian Herridge on 09/05/2017.
//
//

import Foundation

class ShardDelete {
    
    init(_ request: Request) {
        
        let payload = request.payload()
        let shard = Shards.getShard(keyspace: payload.keyspace, partition: payload.partition)
        
        // now we build the query
        let stmt = "DELETE FROM \(payload.table) WHERE \(payload.whereStmt) ORDER BY \(payload.order) LIMIT \(payload.limit) OFFSET \(payload.offset)"
        
        let results = shard.write(sql: stmt, params: payload.parameters)
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
