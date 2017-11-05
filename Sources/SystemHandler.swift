//
//  SystemHandler.swift
//  scale
//
//  Created by Adrian Herridge on 08/05/2017.
//
//

import Foundation

class SystemHandler {
    
    init(_ request: Request) {
        
        switch request.payload().command {
        case "echo":
            _ = SystemEcho(request)
        default:
            request.setError("Unknown command for Keyspace request")
        }
        
    }
    
}
