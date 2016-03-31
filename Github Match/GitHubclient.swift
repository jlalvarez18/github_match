//
//  GitHubclient.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/30/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class GitHub {
    
    enum Error: ErrorType {
        case JSONParseError
    }
    
    class func getTrendingThisWeek() -> Promise<[Repo]> {
        return Promise<[Repo]>(resolvers: { (fulfill, reject) in
            Alamofire.request(GitHubRouter.TrendingThisWeek)
                .validate()
                .responseJSON { (response) in
                    switch response.result {
                    case .Success(let object):
                        guard let jsonArray = object as? JSONDict else {
                            reject(Error.JSONParseError)
                            return
                        }
                        
                        let items = jsonArray.jsonDictArrayValueFor("items")
                        let repos = items.map { Repo(json: $0) }
                        
                        fulfill(repos)
                    case .Failure(let error):
                        reject(error)
                    }
            }
        })
    }
    
    class func getPublicReposFor(user: User) -> Promise<[Repo]> {
        return Promise<[Repo]>(resolvers: { (fulfill, reject) in
            Alamofire.request(GitHubRouter.PublicRepos(user: user))
                .validate()
                .responseJSON { (response) in
                    switch response.result {
                    case .Success(let object):
                        guard let jsonArray = object as? JSONArray else {
                            reject(Error.JSONParseError)
                            return
                        }
                        
                        let repos = jsonArray.map { Repo(json: $0) }
                        
                        fulfill(repos)
                    case .Failure(let error):
                        reject(error)
                    }
            }
        })
    }
    
    class func getRepoDetails(repo: Repo) -> Promise<Repo> {
        return Promise<Repo>(resolvers: { (fulfill, reject) in
            Alamofire.request(GitHubRouter.RepoDetails(repo: repo))
                .validate()
                .responseJSON { (response) in
                    switch response.result {
                    case .Success(let object):
                        guard let json = object as? JSONDict else {
                            reject(Error.JSONParseError)
                            return
                        }
                        
                        let repo = Repo(json: json)

                        fulfill(repo)
                    case .Failure(let error):
                        reject(error)
                    }
            }
        })
    }
    
    class func searchForUsers(query: String, completion: ([User]?, NSError?) -> Void) -> Request {
        return Alamofire.request(GitHubRouter.UserSearch(query: query))
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .Success(let object):
                    guard let json = object as? JSONDict else {
                        return
                    }
                    
                    let items = json.jsonDictArrayValueFor("items")
                    let users = items.map { User(json: $0) }
                    
                    completion(users, nil)
                case .Failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    class func searchForRepos(query: String, completion: ([Repo]?, NSError?) -> Void) -> Request {
        return Alamofire.request(GitHubRouter.RepoSearch(query: query))
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .Success(let object):
                    guard let json = object as? JSONDict else {
                        return
                    }
                    
                    let items = json.jsonDictArrayValueFor("items")
                    let repos = items.map { Repo(json: $0) }
                    
                    completion(repos, nil)
                case .Failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    class func getRepoReadme(repo: Repo) -> Promise<ReadMe> {
        return Promise<ReadMe>(resolvers: { (fulfill, reject) in
            Alamofire.request(GitHubRouter.RepoReadme(repo: repo))
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Success(let object):
                    guard let json = object as? JSONDict else {
                        reject(Error.JSONParseError)
                        return
                    }
                    
                    let readme = ReadMe(json: json)
                    
                    fulfill(readme)
                case .Failure(let error):
                    reject(error)
                }
            })
        })
    }
    
    class func getRepoIssues(repo: Repo) -> Promise<[Issue]> {
        return Promise<[Issue]>(resolvers: { (fulfill, reject) in
            Alamofire.request(GitHubRouter.RepoIssues(repo: repo))
                .validate()
                .responseJSON { (response) in
                    switch response.result {
                    case .Success(let object):
                        guard let jsonArray = object as? JSONArray else {
                            reject(Error.JSONParseError)
                            return
                        }
                        
                        let issues = jsonArray.map { Issue(json: $0) }
                        
                        fulfill(issues)
                    case .Failure(let error):
                        reject(error)
                    }
            }
        })
    }
}

enum GitHubRouter: URLRequestConvertible {
    static let baseURL = NSURL(string: "https://api.github.com")!
    
    case TrendingThisWeek
    case PublicRepos(user: User)
    case UserSearch(query: String)
    case RepoSearch(query: String)
    case RepoDetails(repo: Repo)
    case RepoReadme(repo: Repo)
    case RepoIssues(repo: Repo)
    
    var method: Alamofire.Method {
        return .GET
    }
    
    var path: String {
        switch self {
        case .TrendingThisWeek:
            return "search/repositories"
        case .PublicRepos(let user):
            return "users/\(user.username)/repos"
        case .UserSearch:
            return "search/users"
        case .RepoSearch:
            return "search/repositories"
        case .RepoDetails(let repo):
            return "repos/\(repo.fullName)"
        case .RepoReadme(let repo):
            return "repos/\(repo.fullName)/readme"
        case .RepoIssues(let repo):
            return "repos/\(repo.fullName)/issues"
        }
    }
    
    var params: [String: AnyObject]? {
        switch self {
        case .TrendingThisWeek:
            let date = NSDate().dateBySubtractingWeeks(1)
            let dateString = date.formattedDateWithFormat("YYYY-MM-dd")
            
            return ["q": "created:>\(dateString)", "order": "desc", "sort": "stars"]
        case .UserSearch(let query):
            return ["q": query]
        case .RepoSearch(let query):
            return ["q": query]
        default:
            return nil
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let url = GitHubRouter.baseURL.URLByAppendingPathComponent(path)
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        
        if let params = params {
            return Alamofire.ParameterEncoding.URLEncodedInURL.encode(request, parameters: params).0
        }
        
        return request
    }
}
