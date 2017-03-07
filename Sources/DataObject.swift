//
//  BaseDataObject.swift
//  scale
//
//  Created by Adrian Herridge on 17/02/2017.
//
//

import Foundation
import SWSQLite

class DataObject : NSObject {
    
    dynamic var _id_: String
    dynamic var _timestamp_: String
    
    override init() {
        self._id_ = uuid()
        self._timestamp_ = timeuuid()
    }
    
    init(_ values: Record) {
        
        self._id_ = uuid()
        self._timestamp_ = timeuuid()
        
        super.init()
        
        // now sping through the ivars, looking for field matches from the record object
        for field in values.keys {
            let value = values[field]
            print("\(field)")
            self.setValue(value?.asAny(), forKey: field)
        }
        
    }
    
    func unwrap(_ any:Any) -> Any {
        
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .optional {
            return any
        }
        
        if mi.children.count == 0 { return NSNull() }
        let (_, some) = mi.children.first!
        return some
        
    }
    
    public func Commit() -> SWSQLAction {
        
        var fields: [String: Any] = [:]
        
        self._timestamp_ = timeuuid()
        
        // now up the chain back to base for _id_ & _timestamp_
        for child in (Mirror(reflecting: self).superclassMirror?.children)! {
            if let title = child.label {
                fields[title] = unwrap(child.value)
            }
        }
        
        // now inspect the class and get all the properties that need persisting
        for child in Mirror(reflecting: self).children {
            if let title = child.label {
                fields[title] = unwrap(child.value)
            }
        }
        
        // now remove the excluded properties
        for key in self.ExcludeProperties() {
            fields.removeValue(forKey: key)
        }
        
        let placeholders = Array(repeating: "?", count: fields.count)
        let statement = "INSERT OR REPLACE INTO \(Mirror(reflecting: self).subjectType) (\(fields.keys.joined(separator: ","))) VALUES (\(placeholders.joined(separator: ",")));"
        
        var parameters: [Any] = []
        for field in fields.keys {
            if fields[field] != nil {
                parameters.append(fields[field]!)
            }
        }
        
        return SWSQLAction(stmt: statement, params: parameters, operation: .Insert)
    }
    
    public func Delete(object: Any) -> SWSQLAction {
        
        let statement = "DELETE FROM \(Mirror(reflecting: self).subjectType) WHERE _id_ = ?;"
        
        var parameters: [Any] = []
        
        let id = object_getIvar(object, Ivar("_id_"))
        if id != nil {
            parameters.append(id!)
        }
        
        
        return SWSQLAction(stmt: statement, params: parameters, operation: .Delete)
    }
    
    public func ExcludeProperties() -> [String] {
        return []
    }
    
    public class func GetTables() -> [Action] {
        return []
    }
    
}
