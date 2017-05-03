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
        
    }
    
}
