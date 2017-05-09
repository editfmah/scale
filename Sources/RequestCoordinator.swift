//
//  RequestCoordinator.swift
//  scale
//
//  Created by Adrian Herridge on 15/01/2017.
//
//

import Foundation

class RequestCoordinator {
    
    func HandleRequest(_ request: Request) {
        
        switch request.type {
        case .Keyspace:
            _ = KeyspaceHandler(request)
        case .Read:
            _ = ShardHandler(request)
        case .Write:
            _ = ShardHandler(request)
        case .System:
            _ = SystemHandler(request)
        case .Delete:
            _ = ShardHandler(request)
        default:
            request.setError("An unknown request type was received.")
        }
        
    }
    
}
