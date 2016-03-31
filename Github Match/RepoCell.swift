//
//  RepoCell.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/31/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class RepoCell: UITableViewCell {
    
    static let CellID = "RepoCellID"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .DisclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWith(repoViewModel: RepoViewModel) {
        imageView?.image = repoViewModel.icon
        textLabel?.attributedText = repoViewModel.title
        detailTextLabel?.attributedText = repoViewModel.subtitle
    }
}