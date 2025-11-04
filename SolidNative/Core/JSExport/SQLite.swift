//
//  SQLite.swift
//  SolidNative
//
//  Created by LZY on 2024/5/14.
//

import Foundation
import JavaScriptCore
import SQLite

@objc protocol SQLiteJSExport: JSExport {
    static func connect(_ path: String) -> SQLiteJSExport?
    
    func execute(_ sql: String, _ params: [Any]) -> [[String:Any]]
    func execute(_ sql: String) -> [[String:Any]]
}

class SQLiteJS: NSObject, SQLiteJSExport {
    let db: Connection!
    init(path: String) {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = paths[0].appendingPathComponent(path)
        do {
            db = try Connection(filePath.absoluteString)
        } catch let exp {
            db = nil
            print(exp.localizedDescription)
        }
    }
    
    class func connect(_ path: String) -> (any SQLiteJSExport)? {
        let res = SQLiteJS(path: path)
        if res.db == nil {
            return nil
        }
        return res
    }
    
    public func execute(_ sql: String, _ params: [Any]) -> [[String : Any]] {
        var res: [[String:Any]] = []
        do {
            var bds: [Binding?] = []
            for ele in params {
                let val: Any? = (ele as? String) ?? (ele as? Double) ?? (ele as? Int) ?? (ele as? [String]) ?? (ele as? [Double]) ?? (ele as? [Int])
                bds.append(val as? Binding)
            }
            let r = try db.prepare(sql, bds)
            
            for rr in r.enumerated() {
                var tmp = [String: Any]()
                for (idx, c) in r.columnNames.enumerated() {
                    tmp[c] = rr.element[idx]
                }
                res.append(tmp)
            }
            
            if res.count == 0 && db.changes != 0 {
                print(db.changes)
            }
        } catch let exp {
            print(exp.localizedDescription)
        }
        return res
    }
    
    
    func execute(_ sql: String) -> [[String : Any]] {
        self.execute(sql, [])
    }
    
    deinit {
        print("sqlite deinit")
    }
}
