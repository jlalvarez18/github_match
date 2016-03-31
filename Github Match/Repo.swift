//
//  Repo.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/30/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

struct Repo {
    let id: Int
    let name: String
    let fullName: String
    let owner: User
    let description: String
    
    let stars: Int
    let forks: Int
    
    let language: String
    
    init(json: JSONDict) {
        id = json.intValueFor("id")
        name = json.stringValueFor("name")
        fullName = json.stringValueFor("full_name")
        owner = User(json: json.jsonDictValueFor("owner"))
        description = json.stringValueFor("description")
        
        stars = json.intValueFor("stargazers_count")
        forks = json.intValueFor("forks")
        
        language = json.stringFor("language") ?? "Unknown language"
    }
}

struct RepoViewModel {
    let icon: UIImage
    let title: NSAttributedString
    let subtitle: NSAttributedString
    
    private static let repoIcon = UIImage.imageWithIcon(icon: .Repo, iconColor: UIColor.darkGrayColor(), size: CGSize(width: 20, height: 20))
    private static let subtitleColor = UIColor(red: 0.251, green: 0.51, blue: 0.768, alpha: 1.0)
    
    init(repo: Repo) {
        icon = RepoViewModel.repoIcon
            
        title = NSAttributedString(string: repo.name, attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor()])
        
        let subtitleString = "\(repo.language) • \(repo.stars) stars • \(repo.forks) forks"
        
        let attrib = NSAttributedString(string: subtitleString, attributes: [NSForegroundColorAttributeName: RepoViewModel.subtitleColor])
        
        subtitle = attrib
    }
}
