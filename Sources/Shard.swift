//
//  Shard.swift
//  scale
//
//  Created by Adrian Herridge on 12/01/2017.
//
//

import Foundation
import Dispatch
import SWSQLite

enum ShardType {
    case System
    case Partition
}

class Shard : DataObject, DataObjectProtocol {
    
    var type: ShardType!
    var keyspace: String?
    var partition: String?
    var replicas: Int?
    var hasBeenRefactored: Bool = false
    var lastTouched: Date = Date()
    var referenceCount: Int = 0
    var db: SWSQLite!
    var lock :Mutex!
    
    convenience init(shardType: ShardType, shardKeyspace: String, shardPartition: String) {
        
        self.init()
        
        lock = Mutex()
        self.keyspace = shardKeyspace
        self.type = shardType
        self.partition = shardPartition
        hasBeenRefactored = false
        
        FileShardDirectoryCreate()
        db = SWSQLite(path: FileShardPath(keyspace: self.keyspace!, partition: self.partition!))
        Open()
        
    }
    
    override func populateFromRecord(_ record: Record) {
        self.keyspace = record["keyspace"]?.asString()
        self.partition = record["partition"]?.asString()
        self.replicas = record["replicas"]?.asInt()
    }
    
    override public func ExcludeProperties() -> [String] {
        return ["db","lock","hasBeenRefactored","lastTouched","referenceCount","type"]
    }
    
    override public class func GetTables() -> [Action] {
        return [
            Action(createTable: "Shard"),
            Action(addColumn: "keyspace", type: .String, table: "Shard"),
            Action(addColumn: "partition", type: .String, table: "Shard"),
            Action(addColumn: "replicas", type: .Numeric, table: "Shard")
        ]
    }
    
    public func take() {
        lock.mutex {
            referenceCount += 1
            lastTouched = Date()
        }
    }
    
    public func putBack() {
        lock.mutex {
            referenceCount -= 1
        }
    }
    
    public func peekReferenceCount() -> Int {
        var rc: Int = 0
        lock.mutex {
            rc = referenceCount
        }
        return rc
    }
    
    public func peekLastTouched() -> Date? {
        var rc: Date? = nil
        lock.mutex {
            rc = lastTouched
        }
        return rc
    }
    
    private func Open() {
        
        if !hasBeenRefactored {
            
            lock.mutex {
                
                // create the default schema for the partition type
                switch self.type! {
                case .System:
                    db.execute(actions: Keyspace.GetTables())
                    db.execute(actions: Shard.GetTables())
                case .Partition:
                    db.execute(actions: _shard_.GetTables())
                    Register()
                }
                
                hasBeenRefactored = true
                
            }
        }
        
    }
    
    private func readRaw(sql: String, params: [Any]) -> [Record] {
        return db.query(sql: sql, params: params)
    }
    
    private func writeRaw(sql: String, params: [Any]) {
        db.execute(sql: sql, params: params)
    }
    
    public func read(sql: String, params: [Any]) -> [Record] {
        var retValue: [Record] = []
        lock.mutex {
            retValue = readRaw(sql: sql, params: params)
        }
        return retValue
    }
    
    public func write(_ action:SWSQLAction) {
        lock.mutex {
            db.execute(compiledAction: action)
        }
    }
    
    public func write(sql: String, params: [Any]) {
        lock.mutex {
            writeRaw(sql: sql, params: params)
        }
    }
    
    private func Close() {
        lock.mutex {
            db.close()
        }
    }
    
    private func Register() {
        
        // registers this shard with the node, and applies the current schema
        let sys = Shards.systemShard()
        let results = sys.read(sql: "SELECT * FROM Shard WHERE keyspace = ? AND partition = ?", params: [keyspace as Any, partition as Any])
        if results.count == 0 {
            // we need to create a new entry in the system shard
            let _ = Keyspace.CreateKeyspace(keyspace: keyspace!, replication: 1)
            let shard = Shard()
            shard.type = .Partition
            shard.keyspace = keyspace
            shard.partition = partition
            sys.write(shard.Commit())
        }
        
        // now Refactor the shard
        Refactor()
    }
    
    private func Refactor() {
        // queries the system shard to get the schema changes, first get the current version if there is one
        let sys = Shards.systemShard()
        var lastSchemaUpdate = timeuuid(offset: -1486415754) // create an id ~ 30 years in the past
        let results = db.query(sql: "SELECT * FROM _shard_ LIMIT 1;", params: [])
        if results.count == 0 {
            let shard = _shard_()
            shard.version = lastSchemaUpdate
            shard.keyspace = keyspace
            shard.partition = partition
            db.execute(compiledAction: shard.Commit())
        } else {
            
            // there is a record, go and get the version id
            let shard: _shard_ = _shard_(results[0])
            lastSchemaUpdate = shard.version!
            
            // now select all the schema updates for this keyspace beyond the version it is currently set to
            let upgrades = KeyspaceSchema.ToCollection(sys.read(sql: "SELECT * FROM KeyspaceSchema WHERE keyspace = ? AND version > ? ORDER BY version", params: [
                    keyspace as Any,
                    lastSchemaUpdate
                ]))
            
            if upgrades.count > 0 {
                
                var lastVersion = ""
                for upgrade in upgrades {
                    
                    lastVersion = upgrade.version!
                    let change = upgrade.change!
                    
                    db.execute(sql: change, params: [])
                    
                }
                
                db.execute(sql: "DELETE FROM _shard_", params: [])
                
                let shard = _shard_()
                shard.keyspace = keyspace
                shard.partition = partition
                shard.version = lastVersion
                db.execute(compiledAction: shard.Commit())
                
            }
            
        }
    }
    
}
