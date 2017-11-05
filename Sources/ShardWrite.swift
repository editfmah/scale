//
//  File.swift
//  scale
//
//  Created by Adrian Herridge on 30/04/2017.
//
//

import Foundation

let lock = Mutex()
var pkCache: [String:String] = [:]

class ShardWrite {
    
    init(_ request: Request) {
    
        let payload = request.payload()
        let shard = Shards.getShard(keyspace: payload.keyspace, partition: payload.partition)
        let table = payload.table
        let values = payload.values
        let keyspacetable = "\(payload.keyspace)-\(table)"
        
        // now build the write query, after determining if the record is an update to an existing one or not.
        
        // first off, find the name of the primary key for this table
        let fpk: String? = pkCache[keyspacetable]
        var pk = ""
        
        if fpk != nil {
            
            pk = fpk!
            
        } else {
            
            let table_struct = shard.read(sql: "PRAGMA table_info(\(table))", params: [])
            for s in table_struct.results {
                if s["pk"]?.asInt() == 1 {
                    pk = (s["name"]?.asString())!
                    pkCache[keyspacetable] = pk
                    break
                }
            }
            
        }
        
        if values.keys.contains(pk) {
            
            // we have a pk value, so we can continue forward with the write
            
            if shard.read(sql: "SELECT NULL FROM \(table) WHERE \(pk) = ?", params: [values[pk]!]).results.count > 0 {
                
                var fields: [String] = []
                for f in values.keys {
                    fields.append(" \(f) = ? ")
                }
                
                let statement = "UPDATE \(table) SET \(fields.joined(separator: ",")) WHERE \(pk) = ?"
                
                var parameters: [Any] = []
                for field in values.keys {
                    if values[field] != nil {
                        parameters.append(values[field]!)
                    }
                }
                parameters.append(values[pk]!)
                
                let result = shard.write(sql: statement, params: parameters);
                if result.error != nil {
                    request.setError(result.error!)
                }
                
            } else {
                // it's an insert of a new record
                let placeholders = Array(repeating: "?", count: values.keys.count)
                let fields = values.keys
                let statement = "INSERT OR REPLACE INTO \(table) (\(fields.joined(separator: ","))) VALUES (\(placeholders.joined(separator: ",")));"
                
                var parameters: [Any] = []
                for field in fields {
                    if values[field] != nil {
                        parameters.append(values[field]!)
                    }
                }
                
                let result = shard.write(sql: statement, params: parameters);
                if result.error != nil {
                    request.setError(result.error!)
                }
                
            }
            
            
            
        } else {
            request.setError("write failed, no primary key value was specified. '\(pk)' needs to be specified for a successful write.")
        }
        
        Shards.returnShard(shard: shard)
        
    }
    
}
