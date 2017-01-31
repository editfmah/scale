//
//  SystemKeyspace.swift
//  scale
//
//  Created by Adrian Herridge on 31/01/2017.
//
//

import Foundation
import SwiftKuery

class TableKeyspace: Table {
    let tableName = "Keyspace"
    let _id_ = Column("_Id_")
    let _timestamp_ = Column("_timestamp_")
    let name = Column("name")
    let replication = Column("replication")
    let size = Column("size")
}

class TableKeyspaceSchema: Table {
    let tableName = "KeyspaceSchema"
    let _id_ = Column("_Id_")
    let _timestamp_ = Column("_timestamp_")
    let keyspace_id = Column("keyspace_id")
    let change = Column("change")
}

class TableShard: Table {
    let tableName = "Shard"
    let _id_ = Column("_Id_")
    let _timestamp_ = Column("_timestamp_")
    let keyspace_id = Column("keyspace_id")
    let keyspace_name = Column("keyspace_name")
    let partition = Column("partition")
    let replicas = Column("replicas")
}

class TableShardLocation: Table {
    let tableName = "ShardLocation"
    let _id_ = Column("_Id_")
    let _timestamp_ = Column("_timestamp_")
    let shard_id = Column("shard_id")
    let node = Column("node")
    let available = Column("available")
}

class TableNode: Table {
    let tableName = "Node"
    let _id_ = Column("_Id_")
    let _timestamp_ = Column("_timestamp_")
    let location_id = Column("location_id")
    let group = Column("group")
    let available = Column("available")
    let last_seen = Column("last_seen")
    let internal_address = Column("internal_address")
    let internal_port = Column("internal_port")
    let external_address = Column("external_address")
    let external_port = Column("external_port")
    let space_used = Column("space_used")
    let space_free = Column("space_free")
}
