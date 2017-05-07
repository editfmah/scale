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
        
        let keyspace = request.payload.keyspace
        let partition = request.payload.partition
        let table = request.payload.table
        let shard = Shards.getShard(keyspace: keyspace, partition: partition)
        let columns = request.payload.columns
        let whereStmt = request.payload.whereStmt
        let parameters = request.payload.parameters
        let offset = request.payload.offset
        let orderby = request.payload.order
        let limit = request.payload.limit
        
        // now we build the query
        let stmt = "SELECT \(columns.joined(separator: ",")) FROM \(table) WHERE \(whereStmt) ORDER BY \(orderby) LIMIT \(limit) OFFSET \(offset)"
        
        let results = shard.read(sql: stmt, params: parameters)
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
