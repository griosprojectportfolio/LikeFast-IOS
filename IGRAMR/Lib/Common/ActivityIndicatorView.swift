//
//  ActivityIndicatorView.swift
//  DemoAppSwift
//
//  Created by GrepRuby1 on 04/09/15.
//  Copyright (c) 2015 GrepRuby. All rights reserved.
//

import Foundation
import UIKit

class ActivityIndicatorView: UIView {
    
    var loadingIndicator: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)   //[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        self.applyDefaults()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func applyDefaults(){
        
        loadingIndicator = UIActivityIndicatorView(frame: CGRectMake(50, 0, 40, 40)) as UIActivityIndicatorView
        loadingIndicator.center = self.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        loadingIndicator.startAnimating()
        self.addSubview(loadingIndicator)
    }
    
    func startActivityIndicator(viewController : UIViewController){
        viewController.view.addSubview(self)
    }
    
    func stopActivityIndicator(viewController : UIViewController){
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
        self.removeFromSuperview()
    }
}