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
            request.setError("Keyspace with name '\(params.keyspace)' does not exist.")
            return
        }
        
        // validate this update against the current template/schemas
        let db = SWSQLite(path: ":memory:")
        let key = Keyspace.Get(params.keyspace)
        
        if key?.template != nil {
            let upgrades = KeyspaceSchema.ToCollection(sys.read(sql: "SELECT * FROM KeyspaceSchema WHERE keyspace = ? ORDER BY version", params: [
                key?.template! as Any]).results)
            for schema in upgrades {
                _ = db.execute(sql: schema.change!, params: [])
            }
        }
        
        let upgrades = KeyspaceSchema.ToCollection(sys.read(sql: "SELECT * FROM KeyspaceSchema WHERE keyspace = ? ORDER BY version", params: [
            params.keyspace]).results)
        for schema in upgrades {
            _ = db.execute(sql: schema.change!, params: [])
        }
        
        // now test the new change to make sure it is a valid change, before inserting it into the schema table
        let result = db.execute(sql: request.payload.update, params: [])
        if result.error != nil {
            request.setError("Error modifying keyspace '\(params.keyspace)' : \(result.error!)")
            return
        }
        
        
        // add this update into the KeyspaceSchema.
        
        let schema: KeyspaceSchema = KeyspaceSchema()
        schema.keyspace = request.payload.keyspace
        schema.version = timeuuid()
        schema.change = request.payload.update
        sys.write(schema.Commit())
        
        // now invalidate all open shards for this keyspace
        Shards.invalidateShardsInKeyspace(schema.keyspace!)
        
    }
    
}
