//
//  Octicon+Ext.swift
//  Github Match
//
//  Created by Juan Alvarez on 3/30/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import OcticonsIOS

extension UIImage {
    
    class func imageWithIcon(
        icon icon: OCTIcon,
             backgroundColor: UIColor = UIColor.clearColor(),
             iconColor: UIColor = UIColor.whiteColor(),
             size: CGSize) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let textId = NSString.octicon_iconDescriptionForEnum(icon)
        let textContent = NSString.octicon_iconStringForIconIdentifier(textId)
        
        let fontSize = size.width
        let font = UIFont(name: kOcticonsFamilyName, size: fontSize)!
        
        let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .Center
        
        let attributes: [String: AnyObject] = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: iconColor,
            NSBackgroundColorAttributeName: backgroundColor,
            NSParagraphStyleAttributeName: style
        ]
        
        var textRect = CGRectZero
        textRect.size = size
        
        let origin = CGPoint(x: size.width * 0.05, y: size.height * 0.025)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let path = UIBezierPath(rect: textRect)
        backgroundColor.setFill()
        path.fill()
        
        (textContent as NSString).drawAtPoint(origin, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}