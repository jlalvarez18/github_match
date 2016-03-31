//
//  RepoDetailsViewController.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/30/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import PromiseKit
import SVProgressHUD

private let BasicCellID = "BasicCellIdentifier"

class RepoDetailsViewController: UITableViewController {

    private var repo: Repo
    
    init(repo: Repo) {
        self.repo = repo
        
        super.init(style: .Grouped)
        
        title = repo.fullName
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: BasicCellID)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        SVProgressHUD.show()
        
        firstly {
            GitHub.getRepoDetails(repo)
        }.then { (repo) -> Void in
            self.repo = repo
            
            self.tableView.reloadData()
        }.always { 
            SVProgressHUD.dismiss()
        }.error { (error) in
            print(error)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BasicCellID, forIndexPath: indexPath)
        cell.accessoryType = .DisclosureIndicator
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "View Readme"
        case 1:
            cell.textLabel?.text = "View Issues"
        default:
            return UITableViewCell()
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let controller = ReadMeViewController(repo: repo)
            navigationController?.pushViewController(controller, animated: true)
        case 1:
            let controller = IssuesViewController(repo: repo)
            
            navigationController?.pushViewController(controller, animated: true)
        default:
            break
        }
        
    }

}
