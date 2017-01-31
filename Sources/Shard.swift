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
            shardDB.connect(onCompletion: { (error) in
                lock.sync {
                    
                    // create the default schema for the partition type
                    switch self.type {
                    case .System:
                            shardDB.execute(Node.Schemas.System, onCompletion: { (result) in })
                    default:
                        isOpen = true
                    }
                    
                    
                    isOpen = true;
                }
            })
        }
        
    }
    
    
    
}
