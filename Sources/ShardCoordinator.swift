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
                
                // barn door limit enforcement
                if shards.count >= 512 {
                    for key in Array(shards.keys) {
                        let sh = shards[key]
                        if sh?.peekReferenceCount() == 0 && sh?.type == .Partition {
                            // this shard is not in use anywhere
                            sh?.Close()
                            shards.removeValue(forKey: key)
                        }
                    }
                }
                
                print(shards.count)
                
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
    
    func DeleteShardsForKeyspace(_ keyspace: String) {
        
        var remaining = true
        var shardsToRemove: [String] = []
        
        while remaining {
            
            remaining = false
            
            lock.mutex {
                
                for key in self.shards.keys {
                    let shard = self.shards[key]!
                    if shard.keyspace == keyspace {
                        
                        if shard.peekReferenceCount() == 0 {
                            shard.Close()
                            _ = sys.write(shard.Delete())
                            shard.removefiles()
                            shardsToRemove.append(key)
                        } else {
                            remaining = true
                        }
                        
                    }
                }
                
                for key in shardsToRemove {
                    self.shards.removeValue(forKey: key)
                }
                
                if remaining == false {
                    // we are here, nothing is locked, nothing is remaining, go through the system database and delete all records and related files
                    var outstanding = true
                    while outstanding {
                        
                        // limit the query to 50 to stop huge keyspaces from blowing the stack
                        let results = sys.read(sql: "SELECT * FROM Shard WHERE keyspace = ? LIMIT 50", params: [keyspace]).results
                        for record in results {
                            let shard = Shard(record)
                            shard.removefiles()
                            _ = sys.write(shard.Delete())
                        }
                        if results.count == 0 {
                            outstanding = false
                        }
                        
                    }
                }
                
                shardsToRemove = []
                
            }
            
        }
        
    }
    
}
