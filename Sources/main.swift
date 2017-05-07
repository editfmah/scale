
import Foundation
import Kitura
import KituraNet
import SwiftyJSON
import SWSQLite

let version = 0.00

// get the path of the executable as all files are defined from here
let executablePath = FileManager.default.currentDirectoryPath
let settingsFilePath = executablePath + "/settings.json"
let dataPath = executablePath + "/shards/"

// load the settings file and create a global r/o object
let nodeSettings = Settings(path: settingsFilePath)

print("Scale v\(version) Started on TCP port \(nodeSettings.queryPort!)")

// create the "system" shard/database
let Shards = ShardCoordinator()

//let keyspace = uuid()
//
//makeRequest(CreateKeyspace(keyspace))
//print("generating 10000 partitions in preparation")
//
//var partitions: [String] = []
//for i in 1...10000 {
//    let t = uuid().replacingOccurrences(of: "-", with: "")
//    partitions.append(t)
//}
//
//makeRequest(CreateTables(keyspace: keyspace))
//
//var primaryKeys: [String] = []
//print("generating 50000 primary keys in preparation")
//
//for i in 1...50000 {
//    let t = uuid().replacingOccurrences(of: "-", with: "")
//    primaryKeys.append(t)
//}
//
//print("starting write test, 1M random records into random partitions, 32 threads, insert and update")
//
//var startTime = Int(Date().timeIntervalSince1970)
//var totalWrites = 0
//var lastTime = Int(Date().timeIntervalSince1970)
//var totalMin = 0
//var totalMax = 0
//var lastMin = 0
//var lastMax = 0
//var lastError = 0
//var totalError = 0
//var totalTime = 0
//var outstanding = 1000000
//var lastOutstanding = 1000000
//
//for i in 1...32 {
//    
//    DispatchQueue.global(qos: .background).async {
//        while outstanding > 0 {
//            autoreleasepool {
//            let partition = partitions[Int(arc4random_uniform(10000))]
//            let pk = primaryKeys[Int(arc4random_uniform(50000))]
//            let start = Int(Date().timeIntervalSince1970)
//            if !makeRequest(CreateWrite(keyspace: keyspace, partition: partition, primary: pk)) {
//                let stop = Int(Date().timeIntervalSince1970) - start
//                if stop < lastMin {
//                    lastMin = stop
//                }
//                if stop > lastMax {
//                    lastMax = stop
//                }
//                totalTime = totalTime + stop
//                outstanding-=1
//            } else {
//                lastError += 1
//                outstanding -= 1
//            }
//        }
//        }
//    }
//    
//}
//
//print("\nScaleDB Write Performance Test: 1,000,000 records, 32 Threads")
//print("-------------------------------------------------------------")
//print("Writes         | Max (ms)   | Min (ms)   | Ave (ms)  | Errors")
//print("-------------------------------------------------------------")
//
//
//while outstanding > 0 {
//    
//    autoreleasepool {
//    if outstanding <= (lastOutstanding-1000) {
//        
//        print("\(fill(1000000-outstanding, size: 15))| \(fill(lastMax, size: 11))| \(fill(lastMin, size: 11))| \(fill((totalTime / (1000000-outstanding)), size: 10))| \(lastError)")
//        
//        if lastMax > totalMax {
//            totalMax = lastMax
//        }
//        
//        if lastMin < totalMin {
//            totalMin = lastMin
//        }
//        
//        totalError += lastError
//        
//        lastMin = 0
//        lastMax = 0
//        lastError = 0
//        totalTime = 0
//        lastOutstanding = outstanding
//    }
//    }
//    sleep(100)
//    
//}


// create a router
let router = Router()

// setup a default response for anyone hitting the port
router.route("/").get("/") {
    (request: RouterRequest, response: RouterResponse, next) in
    
        response.send("SharkScale Database Engine v\(version)\n")
        response.send("Node: \(nodeSettings.nodeId!)\n")
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
Kitura.addHTTPServer(onPort: nodeSettings.queryPort!, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
