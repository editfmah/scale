//
//  Request.swift
//  scale
//
//  Created by Adrian Herridge on 09/04/2017.
//
//

import Foundation
import SwiftyJSON
import SWSQLite

enum RequestType {
    case Unset
    case Auth
    case Keyspace
    case Read
    case Write
    case Sync
    case System
    case Delete
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
    var response: JSON = JSON(dictionaryLiteral: ("error",NSNull()), ("message", NSNull()), ("type" , NSNull()), ("payload", NSNull()),("requestId", NSNull()))
    
    // packet contents
    var user: String = ""
    var password: String = ""
    var token: String = ""
    var type: RequestType = .Unset
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
        } else if self.request["type"].stringValue == "system" {
            type = .System
        } else if self.request["type"].stringValue == "delete" {
            type = .Delete
        }
        
        if self.request["payload"].exists() {
            self.payload = Payload(self.request["payload"])
        }
        
        self.response["requestId"] = JSON(uuid())
        if self.request["requestId"].exists() {
            self.response["requestId"] = self.request["requestId"]
        }
        
    }
    
    func setError(_ error: String) {
        self.response["error"] = JSON(error)
    }
    
    func setMessage(_ message: String) {
        self.response["message"] = JSON(message)
    }
    
    func setResults(_ results: [Record]) {
        
        var arr: [JSON] = []
        for r in results {
            var dic: [String:JSON] = [:]
            for key in r.keys {
                
                if r[key]?.getType() == .String {
                    dic[key] = JSON(r[key]!.asString()!)
                } else if r[key]?.getType() == .Double {
                    dic[key] = JSON(r[key]!.asDouble()!)
                } else if r[key]?.getType() == .Int {
                    dic[key] = JSON(r[key]!.asInt()!)
                } else {
                    dic[key] = JSON(NSNull())
                }
            }
            arr.append(JSON(dic))
        }
        
        self.response["results"] = JSON(arr)
        
    }
    
}
