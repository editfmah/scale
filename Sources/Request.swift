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
    private var request: JSON
    var response: JSON = JSON(dictionaryLiteral: ("error",NSNull()), ("message", NSNull()), ("type" , NSNull()), ("payload", NSNull()),("requestId", NSNull()))
    
    // packet contents
    private var pUser: String?
    private var pPassword: String?
    private var pToken: String?
    private var pType: RequestType = .Unset
    private var pPayload: Payload?
    
    init(_ json: JSON) {
        
        self.request = json
        
        if self.request["requestId"].exists() {
            self.response["requestId"] = self.request["requestId"]
        } else {
            self.response["requestId"] = JSON(uuid())
        }
        
    }
    
    func type() -> RequestType {
        if pType == .Unset {
            let type = self.request["type"].stringValue
            if type  == "keyspace" {
                pType = .Keyspace
            } else if type  == "client_write" {
                pType = .Write
            } else if type  == "client_read" {
                pType = .Read
            } else if type  == "read" {
                pType = .Read
            } else if type  == "write" {
                pType = .Write
            } else if type  == "system" {
                pType = .System
            } else if type  == "delete" {
                pType = .Delete
            }
        }
        return pType
    }
    
    func payload() -> Payload {
        if pPayload == nil {
            pPayload = Payload(self.request["payload"])
            if pPayload == nil {
                pPayload = Payload(JSON.null)
            }
        }
        return pPayload!
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
