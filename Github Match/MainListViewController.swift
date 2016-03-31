//
//  MainListViewController.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/30/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import PromiseKit
import SVProgressHUD

class MainListViewController: UITableViewController {
    
    private var publicRepos = [Repo]()
    
    private lazy var searchResultsController: SearchResultsTableViewController = {
        return SearchResultsTableViewController(delegate: self)
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: self.searchResultsController)
        controller.searchResultsUpdater = self.searchResultsController
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.delegate = self.searchResultsController
        controller.searchBar.scopeButtonTitles = [SearchScope.Users.rawValue, SearchScope.Repos.rawValue]
        controller.searchBar.autocapitalizationType = .None
        
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(RepoCell.self, forCellReuseIdentifier: RepoCell.CellID)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if publicRepos.isEmpty {
            SVProgressHUD.show()
        }
        
        firstly {
            GitHub.getTrendingThisWeek()
        }.then { (repos) -> Void in
            self.publicRepos = repos
            
            self.tableView.reloadData()
        }.always { 
            SVProgressHUD.dismiss()
        }.error { (error) in
            print(error)
        }
    }
    
    @IBAction func showSearch(sender: UIBarButtonItem) {
        presentViewController(searchController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return publicRepos.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(RepoCell.CellID, forIndexPath: indexPath) as! RepoCell

        let repo = publicRepos[indexPath.row]
        let repoViewModel = RepoViewModel(repo: repo)
        
        cell.setupWith(repoViewModel)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let repo = publicRepos[indexPath.row]
        
        let controller = RepoDetailsViewController(repo: repo)
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Trending This Week"
    }
}

extension MainListViewController: SearchResultsDelegate {
    
    func didSelectUser(user: User) {
        searchController.active = false
        
        let controller = UserReposViewController(user: user)
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didSelectRepo(repo: Repo) {
        searchController.active = false
        
        let controller = RepoDetailsViewController(repo: repo)
        
        navigationController?.pushViewController(controller, animated: true)
    }
}
