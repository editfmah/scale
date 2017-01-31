//
//  Globals.swift
//  scale
//
//  Created by Adrian Herridge on 31/01/2017.
//
//

import Foundation

public struct DefaultSchemas {
    let System: String = "CREATE TABLE IF NOT EXISTS system_keyspaces (keyspace_name TEXT PRIMARY KEY, keyspace_replication INTEGER, keyspace_size INTEGER); CREATE TABLE IF NOT EXISTS keyspace_schema (schema_id TEXT PRIMARY KEY, keyspace_name TEXT, dt NUMBER, change TEXT); CREATE TABLE IF NOT EXISTS shard (shardid TEXT PRIMARY KEY, keyspace_name TEXT, partition TEXT, replicas INTEGER); CREATE TABLE IF NOT EXISTS shard_location (locationid TEXT PRIMARY KEY, shardid TEXT, node TEXT, available INTEGER); CREATE TABLE IF NOT EXISTS nodes (nodeid TEXT PRIMARY KEY, location TEXT, group TEXT, available INTEGER, last_seen NUMBER, internal_address TEXT, internal_port INTEGER, external_address TEXT, external_port INTEGER, space_used INTEGER, space_free INTEGER);"
    let Partition: String = ""
}

public struct DefaultIdentifiers {
    let SystemShardKeyspace = "***system-shard-keyspace***"
    let SystemShardParition = "***system-shard-partition***"
}

public struct DefaultNodeDescriptions {
    let Schemas: DefaultSchemas = DefaultSchemas()
    let Identifiers: DefaultIdentifiers = DefaultIdentifiers()
}

let Node: DefaultNodeDescriptions = DefaultNodeDescriptions()
