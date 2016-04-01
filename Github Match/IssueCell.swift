//
//  IssueCell.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/31/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import SnapKit

class IssueCell: UITableViewCell {
    
    static let CellID = "IssueCellID"
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .ScaleAspectFill
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        preservesSuperviewLayoutMargins = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        separatorInset = UIEdgeInsets(top: 0, left: CGRectGetMinX(titleLabel.frame), bottom: 0, right: 0)
    }
    
    override func updateConstraints() {
        contentView.addSubviewIfNeeded(iconView)
        contentView.addSubviewIfNeeded(titleLabel)
        contentView.addSubviewIfNeeded(subtitleLabel)
        
        iconView.snp_updateConstraints { (make) in
            make.size.equalTo(20)
            make.leading.equalTo(contentView).inset(10)
            make.top.equalTo(contentView).inset(10)
        }
        
        titleLabel.snp_updateConstraints { (make) in
            make.top.equalTo(contentView).inset(10)
            make.leading.equalTo(iconView.snp_trailing).offset(9)
            make.trailing.equalTo(contentView).inset(10)
        }
        
        subtitleLabel.snp_updateConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalTo(contentView).inset(10)
        }
        
        super.updateConstraints()
    }
    
    func setupWith(issueViewModel: IssueViewModel) {
        iconView.image = issueViewModel.icon
        titleLabel.attributedText = issueViewModel.title
        subtitleLabel.attributedText = issueViewModel.subtitle
        
        setNeedsUpdateConstraints()
    }
}
