//
//  stress.swift
//  stress
//
//  Created by Adrian Herridge on 06/05/2017.
//
//

import Foundation
import SWSQLite
import Kitura
import SwiftyJSON

func PerformTest(keyspace: String, threads: Int, records: Int) {
    
}

func CreateKeyspace(_ name:String) -> [String:Any] {
    return ["type" : "keyspace",
     "payload" : [
        "command" : "create",
        "keyspace" : "\(name)",
        "replication" : 1
        ]]
}

func CreateTables(keyspace: String) -> [String:Any] {
    return ["type" : "keyspace",
            "payload" : [
                "command" : "update",
                "keyspace" : "\(keyspace)",
                "update" : "CREATE TABLE testtable (primary TEXT PRIMARY KEY, seconday INTEGER, tertiary TEXT);"
        ]]
}

func CreateWrite(keyspace: String, partition: String, primary: String) -> [String:Any] {
    return ["type" : "write",
            "payload" : [
                "command" : "update",
                "keyspace" : "\(keyspace)",
                "partition" : "\(partition)",
                "table" : "testtable",
                "values" : [
                    "primary" : "\(primary)",
                    "secondary" : uuid(),
                    "tertiary" : uuid()
                ]
        ]]
}

func fill(_ value:Int, size: Int) -> String {
    let s = "\(value)                      "
    return s.substring(to: s.index(s.startIndex, offsetBy: size))
}

func makeRequest(_ payload: [String:Any]) -> Bool {
    
    // create a request object
    let json = JSON(payload)
    let reqObj = Request(json)
    let handler = RequestCoordinator()
    handler.HandleRequest(reqObj)
    
    return true
    
}
