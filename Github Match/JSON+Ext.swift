//
//  JSON+Ext.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/30/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation

// NSDictionar is WAY faster than Swift Dictionaries for the time being
typealias JSONDict = NSDictionary
typealias JSONArray = [JSONDict]

extension NSDictionary {
    
    // MARK: String
    
    func stringFor(key: Key) -> String? {
        return self[key] as? String
    }
    
    func stringValueFor(key: Key) -> String {
        return stringFor(key) ?? ""
    }
    
    // MARK: Bool
    
    func boolFor(key: Key) -> Bool? {
        if let value = self[key] as? Bool {
            return value
        }
        
        if let value = intFor(key) {
            switch value {
            case 0:
                return false
            case 1:
                return true
            default:
                break
            }
        }
        
        if let value = stringFor(key) {
            let canonicalValue = value.lowercaseString
            
            switch canonicalValue {
            case "true", "yes", "1":
                return true
            case "false", "no", "0":
                return false
            default:
                break
            }
        }
        
        return nil
    }
    
    func boolValueFor(key: Key) -> Bool {
        return boolFor(key) ?? false
    }
    
    // MARK: Int
    
    func intFor(key: Key) -> Int? {
        return self[key] as? Int
    }
    
    func intValueFor(key: Key) -> Int {
        return intFor(key) ?? 0
    }
    
    // MARK: Float
    
    func floatFor(key: Key) -> Float? {
        return self[key] as? Float
    }
    
    func floatValueFor(key: Key) -> Float {
        return floatFor(key) ?? 0.0
    }
    
    // MARK: Double
    
    func doubleFor(key: Key) -> Double? {
        return self[key] as? Double
    }
    
    func doubleValueFor(key: Key) -> Double {
        return doubleFor(key) ?? 0.0
    }
    
    // MARK: NSURL
    
    func urlFor(key: Key) -> NSURL? {
        guard let value = stringFor(key) where !value.isEmpty else {
            return nil
        }
        
        return NSURL(string: value)
    }
    
    // MARK: Array
    
    func arrayFor<T>(key: Key) -> [T]? {
        return self[key] as? [T]
    }
    
    func arrayValueFor<T>(key: Key) -> [T] {
        return arrayFor(key) ?? [T]()
    }
    
    // MARK: JSON Array
    
    func jsonDictArrayFor(key: Key) -> [JSONDict]? {
        return self[key] as? [JSONDict]
    }
    
    func jsonDictArrayValueFor(key: Key) -> [JSONDict] {
        return jsonDictArrayFor(key) ?? [JSONDict]()
    }
    
    // MARK: JSON Dictionary
    
    func jsonDictFor(key: Key) -> JSONDict? {
        return self[key] as? JSONDict
    }
    
    func jsonDictValueFor(key: Key) -> JSONDict {
        return jsonDictFor(key) ?? JSONDict()
    }
    
    // MARK: Date
    
    func dateFromStringForKey(key: Key, format: String, localeIdentifier: String) -> NSDate? {
        guard let dateString = stringFor(key) else {
            return nil
        }
        
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        
        let dateformatter = dateFormatterWith(format, locale: locale)
        
        return dateformatter.dateFromString(dateString)
    }
    
    private func dateFormatterWith(format: String, locale: NSLocale = NSLocale.autoupdatingCurrentLocale()) -> NSDateFormatter {
        let threadDict = NSThread.currentThread().threadDictionary
        
        let formatterKey = "JSON-Dateformatter-\(format)"
        
        let formatter: NSDateFormatter
        
        if let _formatter = threadDict[formatterKey] as? NSDateFormatter {
            formatter = _formatter
        } else {
            formatter = NSDateFormatter()
            
            threadDict[formatterKey] = formatter
        }
        
        formatter.dateFormat = format
        formatter.locale = locale
        
        return formatter
    }
}
