//
//  SharedConstants.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/31/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

enum Image {
    case UImage(UIImage)
    case URL(NSURL)
}

extension UIView {
    
    func addSubviewIfNeeded(subview: UIView) {
        if subview.superview != self {
            addSubview(subview)
        }
    }
}