//
//  RequestHandler.swift
//  scale
//
//  Created by Adrian Herridge on 29/10/2017.
//

import Foundation
import PerfectHTTP
import SwiftyJSON

func defaultGet(data: [String:Any]) throws -> RequestHandler {
    return {
        request, response in
        
        response.setHeader(.contentType, value: "application/json")
        do { try response.setBody(json: ["product" : "ScaleDB v\(version)", "server_time" : "\(Date())"])} catch {}
        response.completed()
        
    }
}

func defaultPost(data: [String:Any]) throws -> RequestHandler {
    return {
        request, response in
        
        let body = request.postBodyString ?? ""
        let json = JSON(data: body.data(using: .utf8, allowLossyConversion: false)!)
        
        // Setting the response content type explicitly to application/json
        response.setHeader(.contentType, value: "application/json")
        
        // see if this is an array or a dictionary
        if json.type == .array {
            
            let requests = json.array
            var responses : [JSON] = []
            
            if requests != nil && (requests?.count)! > 0 {
                for jsonRequest in requests! {
                    
                    // create a request object
                    
                    let reqObj = Request(jsonRequest)
                    let handler = RequestCoordinator()
                    handler.HandleRequest(reqObj)
                    responses.append(reqObj.response)
                    
                }
            }
            
            let responseArray = JSON(responses)
            response.appendBody(string: responseArray.rawString() ?? "")
            response.completed()
            
        } else if json.type == .dictionary {
            
            // create a request object
            let reqObj = Request(json)
            let handler = RequestCoordinator()
            handler.HandleRequest(reqObj)
            response.appendBody(string: reqObj.response.rawString() ?? "")
            response.completed()
            
        }
        
        
        
    }
}
