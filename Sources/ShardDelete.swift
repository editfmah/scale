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
        
        let keyspace = request.payload.keyspace
        let partition = request.payload.partition
        let table = request.payload.table
        let shard = Shards.getShard(keyspace: keyspace, partition: partition)
        let whereStmt = request.payload.whereStmt
        let parameters = request.payload.parameters
        let offset = request.payload.offset
        let orderby = request.payload.order
        let limit = request.payload.limit
        
        // now we build the query
        let stmt = "DELETE FROM \(table) WHERE \(whereStmt) ORDER BY \(orderby) LIMIT \(limit) OFFSET \(offset)"
        
        let results = shard.write(sql: stmt, params: parameters)
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
