//
//  KeyspaceCreate.swift
//  scale
//
//  Created by Adrian Herridge on 17/04/2017.
//
//

import Foundation

class KeyspaceCreate {
    
    init(_ request: Request, params: KeyspaceParams) {
        
        var replication = request.payload.replication
        if replication < 1 {
            replication = 1
        }
        
        let template = request.payload.template
        
        // look to see if this keyspace already exists, if it does throw an error
        if Keyspace.Exists(params.keyspace) {
            request.setError("Keyspace with name '\(params.keyspace)' already exists in system database.  Drop the keyspace if you wish to re-create it.")
            return
        }
        
        // create this keyspace
        let id = Keyspace.Create(params.keyspace, replication: replication, template: template)
        request.setMessage("Keyspace '\(params.keyspace)' created with uuid \(id).")
        
    }
    
}
