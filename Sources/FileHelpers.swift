//
//  FileHelpers.swift
//  scale
//
//  Created by Adrian Herridge on 30/01/2017.
//
//

import Foundation
import CryptoSwift

func FileShardDirectory() -> String {
    return dataPath
}

func FileShardPath(keyspace: String, partition: String) -> String {
    
    // hash the keyspace & partition together to create a unique shard identifier
    let hash = "\(keyspace)-\(partition)".sha256()
    return "\(dataPath)\(hash).shard"
    
}

func FileShardDirectoryExists() -> Bool {
    return FileManager.default.fileExists(atPath: FileShardDirectory())
}

func FileShardDirectoryCreate() {
    if !FileShardDirectoryExists() {
        do {
            try FileManager.default.createDirectory(atPath: FileShardDirectory(), withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
    }
}
