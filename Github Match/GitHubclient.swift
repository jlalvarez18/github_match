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
    
    class func getTrendingThisWeek() -> (request: Request, promise: Promise<[Repo]>) {
        let result = performJSONDictRequest(GitHubRouter.TrendingThisWeek)
        
        let promise = result.1.then({ (dict) -> [Repo] in
            let items = dict.jsonDictArrayValueFor("items")
            let repos = items.map { Repo(json: $0) }
            
            return repos
        })
        
        return (result.0, promise)
    }
    
    class func getPublicReposFor(user: User) -> (request: Request, promise: Promise<[Repo]>) {
        let result = performJSONArrayRequest(GitHubRouter.PublicRepos(user: user))
        
        let promise = result.1.then({ (objects) -> [Repo] in
             let repos = objects.map { Repo(json: $0) }
            
            return repos
        })
        
        return (result.0, promise)
    }
    
    class func getRepoDetails(repo: Repo) -> (request: Request, promise: Promise<Repo>) {
        let result = performJSONDictRequest(GitHubRouter.RepoDetails(repo: repo))
        
        let promise = result.1.then({ (dict) -> Repo in
            let repo = Repo(json: dict)
            
            return repo
        })
        
        return (result.0, promise)
    }
    
    class func getRepoReadme(repo: Repo) -> (request: Request, promise: Promise<ReadMe>) {
        let result = performJSONDictRequest(GitHubRouter.RepoReadme(repo: repo))
        
        let promise = result.1.then({ (dict) -> ReadMe in
            let readme = ReadMe(json: dict)
            
            return readme
        })
        
        return (result.0, promise)
    }
    
    class func getRepoIssues(repo: Repo) -> (request: Request, promise: Promise<[Issue]>) {
        let result = performJSONArrayRequest(GitHubRouter.RepoIssues(repo: repo))
        
        let promise = result.1.then({ (objects) -> [Issue] in
            let issues = objects.map { Issue(json: $0) }
            
            return issues
        })
        
        return (result.0, promise)
    }
    
    class func searchForUsers(query: String) -> (request: Request, promise: Promise<[User]>) {
        let result = performJSONDictRequest(GitHubRouter.UserSearch(query: query))
        
        let promise = result.1.then { (dict) -> [User] in
            let items = dict.jsonDictArrayValueFor("items")
            let users = items.map { User(json: $0) }
            
            return users
        }
        
        return (result.0, promise)
    }
    
    class func searchForRepos(query: String) -> (request: Request, promise: Promise<[Repo]>) {
        let result = performJSONDictRequest(GitHubRouter.RepoSearch(query: query))
        
        let promise = result.1.then { (dict) -> [Repo] in
            let items = dict.jsonDictArrayValueFor("items")
            let repos = items.map { Repo(json: $0) }
            
            return repos
        }
        
        return (result.0, promise)
    }
}

private extension GitHub {
    
    class func performJSONDictRequest(endpoint: GitHubRouter) -> (Request, Promise<JSONDict>) {
        let result = performRequest(endpoint)
        
        let promise = result.1.then { (object) -> JSONDict in
            guard let json = object as? JSONDict else {
                throw Error.JSONParseError
            }
            
            return json
        }
        
        return (result.0, promise)
    }
    
    class func performJSONArrayRequest(endpoint: GitHubRouter) -> (Request, Promise<JSONArray>) {
        let result = performRequest(endpoint)
        
        let promise = result.1.then { (object) -> JSONArray in
            guard let json = object as? JSONArray else {
                throw Error.JSONParseError
            }
            
            return json
        }
        
        return (result.0, promise)
    }
    
    class func performRequest(endpoint: GitHubRouter) -> (Request, Promise<AnyObject>) {
        let request = Alamofire.request(endpoint)
        
        let promise = Promise<AnyObject>(resolvers: { (fulfill, reject) in
            request.validate().responseJSON { (response) in
                switch response.result {
                case .Success(let object):
                    fulfill(object)
                case .Failure(let error):
                    reject(error)
                }
            }
        })
        
        return (request, promise)
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
