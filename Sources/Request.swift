//
//  Request.swift
//  scale
//
//  Created by Adrian Herridge on 09/04/2017.
//
//

import Foundation
import SwiftyJSON

enum RequestType {
    case Unset
    case Auth
    case Keyspace
    case Read
    case Write
    case Sync
}

enum RequestError: String {
    case Auth = "Authentication Error"
    case Keyspace = "Keyspace Error"
    case QueryError = "Query Error"
    case UnknownType = "Unknown request type"
}

class Request {
    
    // request/response data
    private var request: JSON = JSON(nilLiteral: ())
    var response: JSON = JSON(dictionaryLiteral: ("error",NSNull()), ("message", NSNull()), ("type" , NSNull()), ("payload", NSNull()))
    
    // packet contents
    var user: String = ""
    var password: String = ""
    var token: String = ""
    var error: RequestError? = nil
    var type: RequestType = .Unset
    var message: String? = nil
    var payload: Payload = Payload(JSON(nilLiteral: ()))
    
    init(_ json: JSON) {
        
        self.request = json
        
        if self.request["type"].stringValue == "keyspace" {
            type = .Keyspace
        } else if self.request["type"].stringValue == "client_write" {
            type = .Write
        } else if self.request["type"].stringValue == "client_read" {
            type = .Read
        } else if self.request["type"].stringValue == "read" {
            type = .Read
        } else if self.request["type"].stringValue == "write" {
            type = .Write
        }
        
        if self.request["payload"].exists() {
            self.payload = Payload(self.request["payload"])
        }
        
    }
    
}
