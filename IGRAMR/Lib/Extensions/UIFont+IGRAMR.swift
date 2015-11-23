//
//  UIFont+IGRAMR.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 08/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    // MARK: - System Fonts methods
    class func defaultFontOfSize(size: CGFloat) -> UIFont {
        return systemFontOfSize(size)
    }
    
    // MARK: - Custom Font methods
    class func normalFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: size)!
    }
    
    class func italicFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Italic", size: size)!
    }
    
    class func boldFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: size)!
    }
    
    class func mediumFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: size)!
    }
    
    class func lightFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: size)!
    }
    
    class func thinFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Thin", size: size)!
    }
    
    class func ultraLightFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-UltraLight", size: size)!
    }
    
}
