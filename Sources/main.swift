
import Foundation
import Kitura
import KituraNet
import SwiftyJSON
import SWSQLite

let version = 0.01

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

// create a router
let router = Router()

// setup a default response for anyone hitting the port
router.route("/").get("/") {
    (request: RouterRequest, response: RouterResponse, next) in
    
        response.send("SharkScale Database Engine v\(version)\n")
        response.send("Node: \(nodeSettings.nodeId)\n")
        response.send("Name: \(nodeSettings.peerName)\n")
        response.send("Server time: \(Date())")
        next()

}

router.route("/").post {
    (request: RouterRequest,  response: RouterResponse, next) in
    
    let body = try request.readString() ?? ""
    let json = JSON(data: body.data(using: .utf8, allowLossyConversion: false)!)
    
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
        response.send(json: responseArray)
        
    } else if json.type == .dictionary {
        
        // create a request object
        let reqObj = Request(json)
        let handler = RequestCoordinator()
        handler.HandleRequest(reqObj)
        response.send(json: reqObj.response)
        
    }
    
   
    
    next()
    
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: nodeSettings.queryPort, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
