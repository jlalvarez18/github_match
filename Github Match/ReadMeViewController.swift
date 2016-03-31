//
//  ReadMeViewController.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/30/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import SnapKit
import PromiseKit
import SVProgressHUD
import SafariServices

class ReadMeViewController: UIViewController {

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.editable = false
        textView.delegate = self
        
        return textView
    }()
    
    private let repo: Repo
    
    init(repo: Repo) {
        self.repo = repo
        
        super.init(nibName: nil, bundle: nil)
        
        title = "ReadMe"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(textView)
        
        textView.snp_updateConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        SVProgressHUD.show()
        
        firstly {
            GitHub.getRepoReadme(repo)
        }.then { (readme) -> Void in
            if let attributedText = readme.attributedValue {
                self.textView.attributedText = attributedText
            } else {
                self.textView.text = "No ReadMe Found"
            }
        }.always { 
            SVProgressHUD.dismiss()
        }.error { (error) in
            print(error)
            
            self.textView.text = "No ReadMe Found"
        }
    }
}

extension ReadMeViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        let controller = SFSafariViewController(URL: URL)

        presentViewController(controller, animated: true, completion: nil)
//        navigationController?.pushViewController(controller, animated: true)
        
        return false
    }
}
