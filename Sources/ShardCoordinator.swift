//
//  ShardCoordinator.swift
//  scale
//
//  Created by Adrian Herridge on 12/01/2017.
//
//

import Foundation

class ShardCoordinator {
    
    private let lock: Mutex
    private var shards: [String:Shard] = [:]
    
    init() {
        lock = Mutex()
    }
    
    func systemShard() -> Shard {
        var shard: Shard? = nil
        let key = makeKey(keyspace: Node.Identifiers.SystemShardKeyspace, partition: Node.Identifiers.SystemShardParition)
        lock.mutex {
            if shards[key] != nil {
                shard = shards[key]
            } else {
                shard = Shard(shardType: .System, shardKeyspace: Node.Identifiers.SystemShardKeyspace, shardPartition: Node.Identifiers.SystemShardParition, shardTemplate: nil)
                shards[key] = shard
            }
        }
        return shard!
    }
    
    func getShard(keyspace: String, partition: String) -> Shard {
        var shard: Shard? = nil
        let key = makeKey(keyspace: keyspace, partition: partition)
        lock.mutex {
            if shards[key] != nil {
                
                shard = shards[key]
                shard?.take()
                
            } else {
                
                // shard has not been registered yet, create it, add it to the co-ordinator
                
                let keyspaceRecord = Keyspace.Get(keyspace)
                
                shard = Shard(shardType: .Partition, shardKeyspace: keyspace, shardPartition: partition, shardTemplate: keyspaceRecord?.template)
                shard?.take()
                shards[key] = shard
                
            }
        }
        return shard!
    }
    
    func invalidateShardsInKeyspace(_ keyspace: String) {
        lock.mutex {
            for shard in self.shards.values {
                if shard.keyspace == keyspace || shard.template == keyspace {
                    shard.dirty = true
                }
            }
        }
    }
    
    func returnShard(shard: Shard) {
        lock.mutex {
            shard.putBack()
        }
    }
    
    func makeKey(keyspace: String, partition: String) -> String {
        return "\(keyspace)-\(partition)"
    }
    
}
