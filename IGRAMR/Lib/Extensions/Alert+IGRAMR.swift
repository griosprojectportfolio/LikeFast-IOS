//
//  Alert+IGRAMR.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 21/10/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    // MARK: - UIAlertController Class Methods
    
    class func alertOnError(error:NSError, handler:((UIAlertAction!) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message:error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:handler))
        return alert
    }
    
    class func alertOnErrorWithMessage(message:String, handler:((UIAlertAction!) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:handler))
        return alert
    }
    
    class func alertWithTitleAndMessage(title:String, message:String, handler:((UIAlertAction!) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:handler))
        return alert
    }
    
    class func alertWithMessage(message:String, handler:((UIAlertAction!) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Alert", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:handler))
        return alert
    }
    
    class func confirmAlertWithOkAndCancel(message:String, handler:((UIAlertAction!) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Confirm", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:handler))
        alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.Cancel, handler:handler))
        return alert
    }
    
    class func confirmAlertWithTwoButtonTitles(title:String,message:String,btnTitle1:String,btnTitle2:String,handler:((UIAlertAction!) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: btnTitle1, style: UIAlertActionStyle.Default, handler:handler))
        alert.addAction(UIAlertAction(title: btnTitle2, style: UIAlertActionStyle.Cancel, handler:handler))
        return alert
    }
    
    // MARK: - How to use Alert+Qist Extension
    /*
    Type : 1
    let alert = UIAlertController.alertOnErrorWithMessage("Hello", handler: { (objAlertAction : UIAlertAction! ) -> Void in
    })
    self.presentViewController(alert, animated: true, completion: nil)
    
    Type : 2
    let alert = UIAlertController.alertWithMessage("Hello", handler: { (objAlertAction : UIAlertAction! ) -> Void in
    
    switch objAlertAction.style {
    case .Default :
    println("Default Button")
    case .Destructive :
    println("Destructive Button")
    case .Cancel :
    println("Cancel Button")
    }
    })
    self.presentViewController(alert, animated: true, completion: nil)
    */
    
}