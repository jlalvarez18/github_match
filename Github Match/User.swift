//
//  User.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/30/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation

struct User {
    let username: String
    let userId: Int
    let avatarURL: NSURL?
    
    init(json: JSONDict) {
        username = json.stringValueFor("login")
        userId = json.intValueFor("id")
        avatarURL = json.urlFor("avatar_url")
    }
}