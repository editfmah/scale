//
//  File.swift
//  scale
//
//  Created by Adrian Herridge on 30/04/2017.
//
//

import Foundation

class ShardWrite {
    
    init(_ request: Request) {
    
        let keyspace = request.payload.keyspace
        let partition = request.payload.partition
        let table = request.payload.table
        let values = request.payload.values
        
        let shard = Shards.getShard(keyspace: keyspace, partition: partition)
        
        // now build the write query
        
        let placeholders = Array(repeating: "?", count: values.keys.count)
        let fields = values.keys
        let statement = "INSERT OR REPLACE INTO \(table) (\(fields.joined(separator: ","))) VALUES (\(placeholders.joined(separator: ",")));"
        
        var parameters: [Any] = []
        for field in fields {
            if values[field] != nil {
                parameters.append(values[field]!)
            }
        }
        
        shard.write(sql: statement, params: parameters);
        
    }
    
}
