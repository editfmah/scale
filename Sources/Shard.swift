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
    var template: String?
    var replicas: Int?
    var lastTouched: Date = Date()
    var referenceCount: Int = 0
    var db: SWSQLite!
    var lock :Mutex!
    var dirty: Bool = true
    
    convenience init(shardType: ShardType, shardKeyspace: String, shardPartition: String, shardTemplate: String?) {
        
        self.init()
        
        lock = Mutex()
        self.keyspace = shardKeyspace
        self.type = shardType
        self.partition = shardPartition
        self.template = shardTemplate
        FileShardDirectoryCreate()
        db = SWSQLite(path: FileShardPath(keyspace: self.keyspace!, partition: self.partition!))
        Open()
        
    }
    
    override func populateFromRecord(_ record: Record) {
        self.keyspace = record["keyspace"]?.asString()
        self.partition = record["partition"]?.asString()
        self.template = record["template"]?.asString()
        self.replicas = record["replicas"]?.asInt()
    }
    
    override public func ExcludeProperties() -> [String] {
        return ["db","lock","hasBeenRefactored","lastTouched","referenceCount","type","dirty"]
    }
    
    override public class func GetTables() -> [Action] {
        return [
            Action(createTable: "Shard"),
            Action(addColumn: "keyspace", type: .String, table: "Shard"),
            Action(addColumn: "partition", type: .String, table: "Shard"),
            Action(addColumn: "template", type: .String, table: "Shard"),
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
        
        if dirty {
            
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
                
                dirty = false
                
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
            if Keyspace.Exists(keyspace!) {
                let shard = Shard()
                shard.type = .Partition
                shard.keyspace = keyspace
                shard.partition = partition
                sys.write(shard.Commit())
            } else {
                assertionFailure("shard created without the corresponding keyspace")
            }
        }
        
        // now Refactor the shard
        Refactor()
    }
    
    private func Refactor() {
        
        // queries the system shard to get the schema changes, first get the current version if there is one
        
        let sys = Shards.systemShard()
        
        var template_lastSchemaUpdate = timeuuid(offset: -1486415754) // create an id ~ 30 years in the past
        var keyspace_lastSchemaUpdate = timeuuid(offset: -1486415754) // create an id ~ 30 years in the past
        
        var shard = _shard_()
        let results = db.query(sql: "SELECT * FROM _shard_ LIMIT 1;", params: [])
        if results.count == 0 {
            
            shard.template_version = template_lastSchemaUpdate
            shard.keyspace_version = keyspace_lastSchemaUpdate
            shard.keyspace = keyspace
            shard.partition = partition
            db.execute(compiledAction: shard.Commit())
            
        } else {
            
            // there is a record, go and get the version id
            shard = _shard_(results[0])
            template_lastSchemaUpdate = shard.template_version!
            keyspace_lastSchemaUpdate = shard.keyspace_version!
            
        }
        
        // now select all the schema updates for this keyspace beyond the version it is currently set to
        
        var upgrades = KeyspaceSchema.ToCollection(sys.read(sql: "SELECT * FROM KeyspaceSchema WHERE keyspace = ? AND version > ? ORDER BY version", params: [
            template as Any,
            template_lastSchemaUpdate
            ]))
        
        if upgrades.count > 0 {
            
            var lastVersion = ""
            for upgrade in upgrades {
                
                lastVersion = upgrade.version!
                let change = upgrade.change!
                
                db.execute(sql: change, params: [])
                
            }
            
            shard.template_version = lastVersion
            
        }
        
        upgrades = KeyspaceSchema.ToCollection(sys.read(sql: "SELECT * FROM KeyspaceSchema WHERE keyspace = ? AND version > ? ORDER BY version", params: [
            keyspace! as Any,
            keyspace_lastSchemaUpdate
            ]))
        
        if upgrades.count > 0 {
            
            var lastVersion = ""
            for upgrade in upgrades {
                
                lastVersion = upgrade.version!
                let change = upgrade.change!
                
                db.execute(sql: change, params: [])
                
            }
            
            shard.keyspace_version = lastVersion
            
        }
        
        db.execute(compiledAction: shard.Commit())
        
    }
    
}
