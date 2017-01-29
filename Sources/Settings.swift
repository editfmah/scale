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
    
    var nodeId: String?
    var peerName: String?
    var peerURL: String?
    var queryPort: Int?
    
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
        peerURL = values["peer_url"].stringValue
        queryPort = values["query_port"].intValue
    }
    
    
}
