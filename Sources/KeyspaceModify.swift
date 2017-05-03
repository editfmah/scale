//
//  KeyspaceModify.swift
//  scale
//
//  Created by Adrian Herridge on 17/04/2017.
//
//

import Foundation
import SWSQLite

class KeyspaceModify {
    
    init(_ request: Request, params: KeyspaceParams) {
        
        // write the update to the keyspace, then invalidate all the open shards so they refactor on next use

        // look to see if this keyspace already exists, if it does throw an error
        if !Keyspace.Exists(params.keyspace) {
            request.error = RequestError.Keyspace
            request.message = "Keyspace with name '\(params.keyspace)' does not exist."
            return
        }
        
        // TODO: validate this update against the current template/schemas
        
        // add this update into the KeyspaceSchema.
        
        let schema: KeyspaceSchema = KeyspaceSchema()
        schema.keyspace = request.payload.keyspace
        schema.version = timeuuid()
        schema.change = request.payload.update
        
        let sys = Shards.systemShard()
        sys.write(schema.Commit())
        
        
        
        // now invalidate all open shards for this keyspace
        Shards.invalidateShardsInKeyspace(schema.keyspace!)
        
    }
    
}
