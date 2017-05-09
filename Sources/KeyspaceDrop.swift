//
//  KeyspaceDrop.swift
//  scale
//
//  Created by Adrian Herridge on 17/04/2017.
//
//

import Foundation
import SWSQLite

class KeyspaceDrop {
    
    init(_ request: Request, params: KeyspaceParams) {
        
        // look to see if this keyspace already exists, if it does throw an error
        if !Keyspace.Exists(params.keyspace) {
            request.setError("Keyspace with name '\(params.keyspace)' does not exist. Unable to drop.")
            return
        }
        
        let key = Keyspace.Get(params.keyspace)
        _ = sys.write((key?.Delete())!)
        
        let schemaChanges = KeyspaceSchema.ToCollection(sys.read(sql: "SELECT * FROM KeyspaceSchema WHERE keyspace = ?", params: [params.keyspace]).results)
        
        for ks in schemaChanges {
            _ = sys.write(ks.Delete())
        }
        
        // now lock all the shards, and delete everything associated with this keyspace
        Shards.DeleteShardsForKeyspace(params.keyspace)
        
    }
    
}
