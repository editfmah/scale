
import Foundation
import PerfectHTTPServer
import SwiftyJSON
import SWSQLite

let version = 0.02

// get the path of the executable as all files are defined from here
let executablePath = FileManager.default.currentDirectoryPath
let settingsFilePath = executablePath + "/settings.json"
let dataPath = executablePath + "/shards/"

// load the settings file and create a global r/o object
let nodeSettings = Settings(path: settingsFilePath)

print("Scale v\(version) Started on TCP port \(nodeSettings.queryPort)")

// create the "system" shard/database
let Shards = ShardCoordinator()

// global system shard object
let sys = Shards.systemShard()

var confData = [
    "servers": [
        [
            "name":"localhost",
            "port":nodeSettings.queryPort,
            "routes":[
                ["method":"get", "uri":"/**", "handler": defaultGet],
                ["method":"post", "uri":"/**", "handler": defaultPost],
            ],
            "filters":[
                [
                    "type":"response",
                    "priority":"high",
                    "name":PerfectHTTPServer.HTTPFilter.contentCompression,
                    ]
            ]
        ]
    ]
]

do {
    // Launch the servers based on the configuration data.
    try HTTPServer.launch(configurationData: confData)
} catch {
    print("error: unable to start rest service.\n")
}


