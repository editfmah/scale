//
//  Shard.swift
//  scale
//
//  Created by Adrian Herridge on 12/01/2017.
//
//

import Foundation
import SwiftKuery
import SwiftKuerySQLite
import Dispatch

enum ShardType {
    case System
    case Partition
}

class Shard {
    
    var type: ShardType
    var keyspace: String
    var partition: String
    var isOpen: Bool
    var hasBeenRefactored: Bool
    let shardDB: SQLiteConnection
    private let lock: DispatchQueue
    
    init(type: ShardType, keyspace: String, partition: String) {
        
        self.keyspace = keyspace
        self.type = type
        self.partition = partition
        isOpen = false
        hasBeenRefactored = false
        lock = DispatchQueue(label:"\(keyspace)-\(partition)-lock-queue")
        
        FileShardDirectoryCreate()
        shardDB = SQLiteConnection(filename: FileShardPath(keyspace: self.keyspace, partition: self.partition))
        
        Open()
        
    }
    
    private func Open() {
        
        if !isOpen {
            
            var isNew = true
            if FileManager.default.fileExists(atPath: FileShardPath(keyspace: self.keyspace, partition: self.partition)) {
                isNew = false;
            }
            
            shardDB.connect(onCompletion: { (error) in
                lock.sync {
                    
                    // create the default schema for the partition type
                    switch self.type {
                    case .System:
                        shardDB.execute(Node.Schemas.System, onCompletion: {})
                    case .Partition:
                        if isNew {
                            Register()
                        }
                        else {
                            Refactor()
                        }
                    default:
                        isOpen = true
                    }
                    
                    isOpen = true
                }
            })
        }
        
    }
    
    private func Close() {
        
        if isOpen {
           
            lock.sync {
                shardDB.closeConnection()
                isOpen = false
            }
            
        }
        
    }
    
    private func Register() {
        
        // registers this shard with the node, and applies the current schema
        
        
        // now Refactor the shard
        Refactor()
    }
    
    private func Refactor() {
        // queries the system shard to get and schema changes
        
    }
    
    
}
