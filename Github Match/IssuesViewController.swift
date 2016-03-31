//
//  IssuesViewController.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/30/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import PromiseKit
import SVProgressHUD
import DZNEmptyDataSet

private let BasicCellID = "BasicCellIdentifier"

class IssuesViewController: UITableViewController {
    
    private var repo: Repo
    
    private var issues = [Issue]()
    
    init(repo: Repo) {
        self.repo = repo
        
        super.init(style: .Grouped)
        
        title = "Issues"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        SVProgressHUD.show()
        
        firstly {
            GitHub.getRepoIssues(repo)
        }.then { (issues) -> Void in
            self.issues = issues
            
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
        return issues.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if let _cell = tableView.dequeueReusableCellWithIdentifier(BasicCellID) {
            cell = _cell
        } else {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: BasicCellID)
        }
        
        let issue = issues[indexPath.row]
        
        let issueViewModel = IssueViewModel(issue: issue)
        
        cell.imageView?.image = issueViewModel.icon
        cell.textLabel?.attributedText = issueViewModel.title
        cell.detailTextLabel?.attributedText = issueViewModel.subtitle

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension IssuesViewController: DZNEmptyDataSetSource {
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Issues")
    }
}
