//
//  UIColor+IGRAMR.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 08/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    // MARK: - UIColor from hex color code
    convenience init(hexColorCode: String)
    {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if hexColorCode.hasPrefix("#")
        {
            let index   = hexColorCode.startIndex.advancedBy(1)
            let hex     = hexColorCode.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            
            if scanner.scanHexLongLong(&hexValue)
            {
                if hex.characters.count == 6
                {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                }
                else if hex.characters.count == 8
                {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                }
                else
                {
                    print("invalid hex code string, length should be 7 or 9", terminator: "")
                }
            }
            else
            {
                print("scan hex error")
            }
        }
        else{
            print("invalid hex code string, missing '#' as prefix", terminator: "")
        }
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    // MARK: - UIColor from hex color code and alpha
    convenience init(hexColorCode: String , alpha : CGFloat)
    {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = alpha
        
        if hexColorCode.hasPrefix("#")
        {
            let index   = hexColorCode.startIndex.advancedBy(1)
            let hex     = hexColorCode.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            
            if scanner.scanHexLongLong(&hexValue)
            {
                if hex.characters.count == 6
                {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                }
                else if hex.characters.count == 8
                {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                }
                else
                {
                    print("invalid hex code string, length should be 7 or 9", terminator: "")
                }
            }
            else
            {
                print("scan hex error")
            }
        }
        else{
            print("invalid hex code string, missing '#' as prefix", terminator: "")
        }
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    // MARK: - UIColor from RGB value
    class func colorWithRGB(rgbValue : UInt, alpha : CGFloat = 1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255
        let blue = CGFloat(rgbValue & 0xFF) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK: - Custom Methods for app
    class func appBackgroundColor() -> UIColor{
        return UIColor(hexColorCode: "#3b5882")
    }
    
    class func appSignInButtonBgColor() -> UIColor{
        return UIColor(hexColorCode: "#628c00")
    }
    
    class func appSignUpButtonBgColor() -> UIColor{
        return UIColor(hexColorCode: "#f5894e")
    }
    
    // MARK: - CollectionView Cell Color
    
    class func collectionViewCellBorderColor() -> UIColor{
        return UIColor(hexColorCode: "#f0f0f0")
    }
    
}
