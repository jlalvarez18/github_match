//
//  Issue.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/30/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import DateTools

struct Issue {
    enum State: String {
        case Open = "open"
        case Closed = "closed"
    }
    
    let id: Int
    let number: Int
    let title: String
    let state: State
    
    let creator: User
    let assignee: User?
    
    let body: String?
    
    let createdAt: NSDate
    
    let isPullRequest: Bool
    
    init(json: JSONDict) {
        id = json.intValueFor("id")
        number = json.intValueFor("number")
        title = json.stringValueFor("title")
        state = State(rawValue: json.stringValueFor("state"))!
        
        creator = User(json: json.jsonDictValueFor("user"))
        
        if let assigneeDict = json.jsonDictFor("assignee") {
            assignee = User(json: assigneeDict)
        } else {
            assignee = nil
        }
        
        body = json.stringFor("body")
        
        createdAt = json.dateFromStringForKey("created_at", format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ", localeIdentifier: "en_US_POSIX")!
        
        if let _ = json.jsonDictFor("pull_request") {
            isPullRequest = true
        } else {
            isPullRequest = false
        }
    }
}

struct IssueViewModel {
    let icon: UIImage
    let title: NSAttributedString
    let subtitle: NSAttributedString
    
    init(issue: Issue) {
        let iconSize = CGSize(width: 20, height: 20)
        
        let green = UIColor(red: 0.425, green: 0.775, blue: 0.262, alpha: 1.0)
        let red = UIColor(red: 0.741, green: 0.168, blue: 0.004, alpha: 1.0)
        
        if issue.isPullRequest {
            icon = UIImage.imageWithIcon(icon: .GitPullRequest, iconColor: green, size: iconSize)
        } else {
            switch issue.state {
            case .Open:
                icon = UIImage.imageWithIcon(icon: .IssueOpened, iconColor: green, size: iconSize)
            case .Closed:
                icon = UIImage.imageWithIcon(icon: .IssueClosed, iconColor: red, size: iconSize)
            }
        }
        
        let titleAttr = [
            NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        ]
        
        title = NSAttributedString(string: issue.title, attributes: titleAttr)
        
        let relativeDateString = issue.createdAt.timeAgoSinceNow()
        let subtitleString = "#\(issue.number) opened \(relativeDateString) by \(issue.creator.username)"
        
        let subAtt = [
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        ]
        subtitle = NSAttributedString(string: subtitleString, attributes: subAtt)
    }
}
