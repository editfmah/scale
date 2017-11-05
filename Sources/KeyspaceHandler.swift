//
//  KeyspaceHandler.swift
//  scale
//
//  Created by Adrian Herridge on 12/01/2017.
//
//

import Foundation

enum KeyspaceCommands {
    case Create
    case Modify
    case Drop
    case Query
}

struct KeyspaceParams {
    var keyspace: String = ""
}

class KeyspaceHandler {
    
    // values for the request
    var params:KeyspaceParams
    
    class func keyspaceParamsFromRequest(_ request: Request) -> KeyspaceParams {
        var p = KeyspaceParams()
        p.keyspace = request.payload().keyspace
        return p
    }
    
    init(_ request: Request) {
        
        params = KeyspaceHandler.keyspaceParamsFromRequest(request)
        
        switch request.payload().command {
        case "create":
        _ = KeyspaceCreate(request, params: params)
        case "query":
        _ = KeyspaceQuery(request, params: params)
        case "update":
        _ = KeyspaceModify(request, params: params)
        case "drop":
        _ = KeyspaceDrop(request, params: params)
        default:
            request.setError("Unknown command for Keyspace request")
        }
        
    }
    
}
