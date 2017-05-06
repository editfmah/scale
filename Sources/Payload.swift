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
        
        if json["command"].exists() {
            self.command = json["command"].stringValue
        }
        
        if json["keyspace"].exists() {
            self.keyspace = json["keyspace"].stringValue
        }
        
        if json["replication"].exists() {
            self.replication = json["replication"].intValue
        }
        
        if json["update"].exists() {
            self.update = json["update"].stringValue
        }
        
        if json["change"].exists() {
            self.update = json["change"].stringValue
        }
        
        if json["template"].exists() {
            self.template = json["template"].stringValue
        }
        
        if json["partition"].exists() {
            self.partition = json["partition"].stringValue
        }
        
        if json["template"].exists() {
            self.template = json["template"].stringValue
        }
        
        if json["table"].exists() {
            self.table = json["table"].stringValue
        }
        
        if json["values"].exists() {
            if !json["values"].isEmpty {
                self.values = json["values"].dictionaryObject!
            }
        }
        
        if json["columns"].exists() {
            if !json["columns"].isEmpty {
                columns = []
                for f in json["columns"].arrayObject! {
                    let col = f as! String
                    columns.append(col)
                }
            }
        }
        
        if json["where"].exists() {
            self.whereStmt = json["where"].stringValue
        }
        
        if json["parameters"].exists() {
            if !json["parameters"].isEmpty {
                for p in json["parameters"].arrayObject! {
                    parameters.append(p)
                }
            }
        }
        
        if json["offset"].exists() {
            self.offset = json["offset"].intValue
        }
        
        if json["limit"].exists() {
            self.limit = json["limit"].intValue
        }
        
        if json["order"].exists() {
            self.order = json["order"].stringValue
        }
        
    }
    
}
