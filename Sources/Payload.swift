//
//  Payload.swift
//  scale
//
//  Created by Adrian Herridge on 29/04/2017.
//
//

import Foundation
import SwiftyJSON

class Payload {
    
    var raw: JSON
    var command: String = ""
    var keyspace: String = ""
    var partition: String = ""
    var table: String = ""
    var update: String = ""
    var template: String = ""
    var replication: Int = 0
    var values: [String:Any] = [:]
    
    var columns: [String] = ["*"]
    var whereStmt: String = "1=1"
    var parameters: [Any] = []
    var offset: Int = 0
    var limit: Int = 999999
    var order: String = "ROWID"
    
    init(_ json: JSON) {
        
        self.raw = json
        let data = json.dictionaryObject
        
        self.command = data!["command"] as? String ?? ""
        self.keyspace = data!["keyspace"] as? String ?? ""
        self.replication = data!["replication"] as? Int ?? 0
        
        if data!["update"] != nil {
            self.update = data!["update"] as? String ?? ""
        } else if data!["change"] != nil {
            self.update = data!["change"] as? String ?? ""
        }
        
        self.template = data!["template"] as? String ?? ""
        self.partition = data!["partition"] as? String ?? ""
        self.table = data!["table"] as? String ?? ""
        self.values = data!["values"] as? [String:Any] ?? [:]
        self.whereStmt = data!["where"] as? String ?? "1=1"
        self.order = data!["order"] as? String ?? "ROWID"
        self.offset = data!["offset"] as? Int ?? 0
        self.limit = data!["limit"] as? Int ?? 999999
        
        if data!["columns"] != nil {
            columns = []
            for f in data!["columns"] as! [String] {
                columns.append(f)
            }
        }
        
        if data!["parameters"] != nil {
            for p in data!["parameters"] as! [Any] {
                parameters.append(p)
            }
        }
        
    }
    
}
