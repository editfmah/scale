//
//  QueryHandler.swift
//  scale
//
//  Created by Adrian Herridge on 12/01/2017.
//
//

import Foundation

class ShardHandler {
    
    init(_ request: Request) {
        
        switch request.type {
        case .Read:
            _ = ShardRead(request)
        case .Write:
            _ = ShardWrite(request)
        case .Delete:
            _ = ShardDelete(request)
        default:
            request.setError("Unknown command for Keyspace request")
        }
        
    }
    
}
