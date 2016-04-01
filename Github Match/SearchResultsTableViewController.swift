//
//  SearchResultsTableViewController.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/31/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

enum SearchScope: String {
    case Users
    case Repos
}

protocol SearchResultsDelegate: class {
    func didSelectUser(user: User)
    func didSelectRepo(repo: Repo)
}

class SearchResultsTableViewController: UITableViewController {

    weak var delegate: SearchResultsDelegate?
    
    init(delegate: SearchResultsDelegate) {
        self.delegate = delegate
        
        super.init(style: .Plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    private var searchRequest: Request?
    private var searchItems = [SearchItem]()
    
    private static let iconSize = CGSize(width: 30, height: 30)
    
    private let imageFilter = AspectScaledToFillSizeCircleFilter(size: iconSize)
    
    private func performSearch(text: String?, scope: SearchScope) {
        if let req = searchRequest {
            req.cancel()
            searchRequest = nil
        }
        
        guard let text = text where !text.isEmpty else {
            searchItems = []
            tableView.reloadData()
            
            return
        }
        
        switch scope {
        case .Users:
            let result = GitHub.searchForUsers(text)
            
            searchRequest = result.request
            
            result.promise.then({ (users) -> Void in
                defer {
                    self.searchRequest = nil
                }
                
                self.searchItems = users.map { SearchItem(user: $0, scope: scope) }
                
                self.tableView.reloadData()
            })
        case .Repos:
            let result = GitHub.searchForRepos(text)
            
            searchRequest = result.request
            
            result.promise.then({ (repos) -> Void in
                defer {
                    self.searchRequest = nil
                }
                
                self.searchItems = repos.map { SearchItem(repo: $0, scope: scope) }
                
                self.tableView.reloadData()
            })
        }
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "reuseIdentifier"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) ?? UITableViewCell(style: .Subtitle, reuseIdentifier: cellID)
        cell.accessoryType = .DisclosureIndicator
        
        let item = searchItems[indexPath.row]
        
        let itemViewModel = SearchItemViewModel(item: item)
        
        cell.textLabel?.attributedText = itemViewModel.title
        cell.detailTextLabel?.attributedText = itemViewModel.subtitle
        
        switch itemViewModel.image {
        case .UImage(let image):
            cell.imageView?.image = image
        case .URL(let url):
            cell.imageView?.af_setImageWithURL(
                url,
                placeholderImage: SearchItem.personIcon,
                filter: imageFilter,
                imageTransition: UIImageView.ImageTransition.CrossDissolve(0.3),
                completion: { (response) in
                    cell.setNeedsDisplay()
                }
            )
        }

        return cell
    }

    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.imageView?.af_cancelImageRequest()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = searchItems[indexPath.row]
        
        switch item.scope {
        case .Users:
            let user = item.itemContext as! User
            
            delegate?.didSelectUser(user)
        case .Repos:
            let repo = item.itemContext as! Repo
            
            delegate?.didSelectRepo(repo)
        }
    }
}

extension SearchResultsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let scope = searchBarScope(searchController.searchBar) else {
            return
        }
        
        let searchString = searchController.searchBar.text
        
        performSearch(searchString, scope: scope)
    }
}

extension SearchResultsTableViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let scope = searchBarScope(searchBar) else {
            return
        }
        
        performSearch(searchBar.text, scope: scope)
    }
}

private extension SearchResultsTableViewController {
    
    func searchBarScope(searchBar: UISearchBar) -> SearchScope? {
        let index = searchBar.selectedScopeButtonIndex
        
        guard let scopeTitle = searchBar.scopeButtonTitles?[index] else {
            return nil
        }
        
        return SearchScope(rawValue: scopeTitle)
    }
}

private struct SearchItem {
    let title: String
    let subtitle: String?
    let image: Image
    let scope: SearchScope
    
    let itemContext: Any
    
    static let repoIcon = UIImage.imageWithIcon(icon: .Repo, iconColor: UIColor.darkGrayColor(), size: CGSize(width: 30, height: 30))
    static let personIcon = UIImage.imageWithIcon(icon: .Person, iconColor: UIColor.darkGrayColor(), size: CGSize(width: 30, height: 30))
    
    init(user: User, scope: SearchScope) {
        itemContext = user
        
        self.scope = scope
        
        title = user.username
        subtitle = nil
        
        if let url = user.avatarURL {
            image = Image.URL(url)
        } else {
            image = Image.UImage(SearchItem.personIcon)
        }
    }
    
    init(repo: Repo, scope: SearchScope) {
        itemContext = repo
        
        self.scope = scope
        
        title = repo.name
        subtitle = repo.fullName
        image = Image.UImage(SearchItem.repoIcon)
    }
}

private struct SearchItemViewModel {
    let title: NSAttributedString
    let subtitle: NSAttributedString?
    let image: Image
    
    init(item: SearchItem) {
        image = item.image
        
        title = NSAttributedString(string: item.title, attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor()])
        
        if let sub = item.subtitle {
            subtitle = NSAttributedString(string: sub, attributes: [NSForegroundColorAttributeName: UIColor(red: 0.251, green: 0.51, blue: 0.768, alpha: 1.0)])
        } else {
            subtitle = nil
        }
    }
}
