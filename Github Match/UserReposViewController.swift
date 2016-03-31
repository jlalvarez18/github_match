//
//  UserReposViewController.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/31/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import PromiseKit
import SVProgressHUD

class UserReposViewController: UITableViewController {
    
    private let user: User
    private var publicRepos = [Repo]()
    
    init(user: User) {
        self.user = user
        
        super.init(style: .Grouped)
        
        title = user.username
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(RepoCell.self, forCellReuseIdentifier: RepoCell.CellID)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        SVProgressHUD.show()
        
        firstly {
            GitHub.getPublicReposFor(user)
        }.then { (repos) -> Void in
            self.publicRepos = repos
            
            self.tableView.reloadData()
        }.always {
            SVProgressHUD.dismiss()
        }.error { (error) in
            print(error)
        }
    }

    // MARK: - Table view data source

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
        return "Public Repos"
    }
}
