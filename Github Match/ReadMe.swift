//
//  ReadMe.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/30/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation
import TSMarkdownParser

struct ReadMe {
    let type: String
    let encoding: String
    let size: Int
    let name: String
    let path: String
    let content: String
    let sha: String
    
    init(json: JSONDict) {
        type = json.stringValueFor("type")
        encoding = json.stringValueFor("encoding")
        size = json.intValueFor("size")
        name = json.stringValueFor("name")
        path = json.stringValueFor("path")
        content = json.stringValueFor("content")
        sha = json.stringValueFor("sha")
    }
    
    var attributedValue: NSAttributedString? {
        guard let decodedContent = NSData(base64EncodedString: content, options: .IgnoreUnknownCharacters) else {
            return nil
        }
        
        guard let decodedString = String(data: decodedContent, encoding: NSUTF8StringEncoding) else {
            return nil
        }
        
        let attributedString = TSMarkdownParser.standardParser().attributedStringFromMarkdown(decodedString)
        
        return attributedString
    }
}