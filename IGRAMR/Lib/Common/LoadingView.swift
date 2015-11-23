//
//  LoadingView.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 05/11/15.
//  Copyright © 2015 GrepRuby3. All rights reserved.
//

import Foundation

public class LoadingView {
    
    let objWindow:UIWindow = UIApplication.sharedApplication().delegate!.window!!
    let overlayView = UIView()
    let grayBackgroundView = UIView()
    let activityIndicator = UIActivityIndicatorView()
    let lblLoading = UILabel()
    
    class var shared: LoadingView {
        struct Static {
            static let instance: LoadingView = LoadingView()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIView , lblText: String ) {
        
        grayBackgroundView.frame = view.bounds
        grayBackgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        overlayView.frame = CGRectMake(0, 0, 100, 100)
        overlayView.center = view.center
        overlayView.backgroundColor = UIColor.whiteColor()
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 12
        
        activityIndicator.frame = CGRectMake(0, 0, 50, 50)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.appBackgroundColor()
        activityIndicator.center = CGPointMake(overlayView.bounds.width / 2, (overlayView.bounds.height - 20) / 2)
        
        lblLoading.frame = CGRectMake(0, 60, 100, 20)
        lblLoading.text = lblText
        lblLoading.font = UIFont.defaultFontOfSize(15.0)
        lblLoading.textColor = UIColor.darkGrayColor()
        lblLoading.textAlignment = .Center
        overlayView.addSubview(lblLoading)
        
        overlayView.addSubview(activityIndicator)
        
        objWindow.addSubview(grayBackgroundView)
        objWindow.addSubview(overlayView)
        
        activityIndicator.startAnimating()
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
        grayBackgroundView.removeFromSuperview()
    }
    
}