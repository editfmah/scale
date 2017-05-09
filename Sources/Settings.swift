//
//  Settings.swift
//  scale
//
//  Created by Adrian Herridge on 30/12/2016.
//
//

import Foundation
import SwiftyJSON

class Settings {
    
    private var settingsFilePath: String
    private var values: JSON
    
    var nodeId: String = UUID().uuidString.lowercased()
    var peerName: String = "scaledb.node.000"
    var peers: [String] = []
    var queryPort: Int = 8080
    var dataPath: String = ""
    
    var roleData: Bool = true
    var roleBackstop: Bool = false
    var roleQueryCoordinator: Bool = false
    
    var maxShardsOpen: Int = 512
    var cacheQueries: Bool = true
    
    var compactDatabases: Bool = true
    var compactDatabaseFrequency: Int = 1500
    var reindexDatabases: Bool = true
    var reindexDatabaseFrequency: Int = 1500
    
    init(path: String) {
        
        settingsFilePath = path
        values = JSON(nilLiteral: ())
        reloadSettings()
        populateProperties()
        
    }
    
    private func reloadSettings() {
        do {
            let fileData =  try Data(contentsOf: URL(fileURLWithPath: settingsFilePath))
            values = JSON(data: fileData)
        } catch {
            values.dictionaryObject = ["node_id" : UUID.init().uuidString.lowercased()]
            values["peer_name"] = JSON(NSNull())
            values["peer_url"] = JSON(NSNull())
            values["query_port"] = JSON(8080)
            writeSettings()
        }
    }
    
    private func writeSettings() {
        let str = values.description
        do {
            try str.write(toFile: settingsFilePath, atomically: true, encoding: .utf8)
        } catch {
            
        }
    }
    
    private func populateProperties() {
        nodeId = values["node_id"].stringValue
        peerName = values["peer_name"].stringValue
        queryPort = values["query_port"].intValue
    }
    
    
}
