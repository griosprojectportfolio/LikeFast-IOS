//
//  BaseController.swift
//  DemoAppSwift
//
//  Created by GrepRuby1 on 04/09/15.
//  Copyright (c) 2015 GrepRuby. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

let isiPhone4s     =   UIScreen.mainScreen().bounds.size.height == 480
let isiPhone5      =   UIScreen.mainScreen().bounds.size.width == 320
let isiPhone6      =   UIScreen.mainScreen().bounds.size.width == 375
let isiPhone6plus  =   UIScreen.mainScreen().bounds.size.width == 414
let isiPadAir2     =   UIScreen.mainScreen().bounds.size.width == 768.0


class BaseController: UIViewController , GADInterstitialDelegate{
    
    var sharedApi : ApiClient!
    var activityIndicator : ActivityIndicatorView!
    var bannerAdView : GADBannerView!
    var fullScreenAdView:GADInterstitial?
    var alertIgramr : UIAlertController!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let btnLogOut: UIButton = UIButton(type: UIButtonType.Custom)

    var lblNoData : UILabel = UILabel()
    
    var current_userId : NSNumber {
        get {
            var strCurrentUser : NSNumber = 0
            if(NSUserDefaults.standardUserDefaults().objectForKey("user_id") != nil){
                strCurrentUser = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as! NSNumber
            }
            return strCurrentUser
        }
        set (newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "user_id")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var access_token : String {
        get {
            var strAccessToken : String = ""
            if(NSUserDefaults.standardUserDefaults().objectForKey("access_token") != nil){
                strAccessToken = NSUserDefaults.standardUserDefaults().objectForKey("access_token") as! String
            }
            return strAccessToken
        }
        set (newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "access_token")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var userLike_count : NSNumber {
        get {
            var intLike : NSNumber = 0
            if(NSUserDefaults.standardUserDefaults().objectForKey("userLikeCount") != nil){
                intLike = NSUserDefaults.standardUserDefaults().objectForKey("userLikeCount") as! NSNumber
            }
            return intLike
        }
        set (newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "userLikeCount")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // MARK: - View related Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initializeComponents()
        self.fullScreenAdView = self.setupiAdFullPageView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional before appear the view.
        self.configureComponentsLayout()
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after appear the view.
        let isAssignable = isAssignDataToComponents()
        if isAssignable {
            assignDataToComponents()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: - Banner and Full page ad Methods
    func setupiAdBannerView(){
        self.bannerAdView = GADBannerView()
        self.bannerAdView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height - 50, self.view.frame.size.width, 52)
        self.bannerAdView.adUnitID = "ca-app-pub-7590154983217206/9847557372"
        self.bannerAdView.rootViewController = self
        self.bannerAdView.loadRequest(GADRequest())
        self.bannerAdView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.bannerAdView)
    }
    
    func setupiAdFullPageView() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-7590154983217206/3801023770")
        interstitial.delegate = self
        interstitial.loadRequest(GADRequest())
        return interstitial
    }
    
    func showFullScreenAd(){
        if (self.fullScreenAdView!.isReady) {
            self.fullScreenAdView!.presentFromRootViewController(self)
        }
    }
    
    func showAdOnHeartButtonTapped() {
        // To show Full screen iAd View
        if self.userLike_count == 5 {
            self.userLike_count = 0
            self.showFullScreenAd()
        }
    }
    
    // MARK: GADInterstitialDelegate implementation
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("interstitialDidFailToReceiveAdWithError:\(error.localizedDescription)")
        self.fullScreenAdView = self.setupiAdFullPageView()
    }
    
    func interstitialDidDismissScreen (interstitial: GADInterstitial) {
        print("interstitialDidDismissScreen")
        self.fullScreenAdView = self.setupiAdFullPageView()
    }
    
    
    // MARK: - Common method to all views
    func resetAccessToken_UserId(){
        self.current_userId = 0
        self.access_token = ""
        self.userLike_count = 0
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func setUserLoggedOutAndResetToken(){
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Logout of this account?", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.resetAccessToken_UserId()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        if let popoverController = optionMenu.popoverPresentationController {
                popoverController.sourceView = self.btnLogOut
                popoverController.sourceRect = self.btnLogOut.bounds
        }
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func isMediaLikedByCurrentUser(aDictionary : NSDictionary) -> Bool {
        let objLikes : NSDictionary = aDictionary["likes"] as! NSDictionary
        let arrLikeUsers : NSArray = objLikes["data"] as! NSArray
        for var i = 0 ; i < arrLikeUsers.count ; i++ {
            let dictLike : NSDictionary = arrLikeUsers[i] as! NSDictionary
            if dictLike["id"] as! String == "\(self.current_userId)" {
                return true
            }
        }
        return false
    }
    
    
    // MARK: - Loading view common methods
    func startLoadingIndicatorView(){
        dispatch_async(dispatch_get_main_queue(),{
            self.activityIndicator = ActivityIndicatorView(frame: self.view.frame)
            self.activityIndicator.startActivityIndicator(self)
        })
    }
    
    func stopLoadingIndicatorView(){
        dispatch_async(dispatch_get_main_queue(),{
            self.activityIndicator.stopActivityIndicator(self)
        })
    }
    
    func startLoadingOverLayView(lblLoadingText: String){
        dispatch_async(dispatch_get_main_queue(),{
            LoadingView.shared.showOverlay(self.view, lblText:lblLoadingText)
        })
    }
    
    func stopLoadingOverLayView(){
        dispatch_async(dispatch_get_main_queue(),{
            LoadingView.shared.hideOverlayView()
        })
    }
    
    
    // MARK: - No Data found Labels
    func showNoDataFoundLabels() {
        self.lblNoData = UILabel(frame: CGRect(x: self.view.frame.origin.x, y: self.view.center.y - 150, width: self.view.frame.size.width , height: 100 ))
        self.lblNoData.contentMode = UIViewContentMode.ScaleAspectFit
        self.lblNoData.text = "Data not available."
        self.lblNoData.textColor = UIColor.whiteColor()
        self.lblNoData.textAlignment = .Center
        self.lblNoData.font = UIFont.systemFontOfSize(26.0)
        self.lblNoData.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.lblNoData)
    }
    
    func hideNoDataFoundLabel() {
        self.lblNoData.removeFromSuperview()
    }
    
    
    // MARK: - Common methods to show Alerts
    func showAlertWithTitleAndMessage(title: String ,message: String) {
        self.alertIgramr = UIAlertController.alertWithTitleAndMessage(title , message: message, handler:{(objAlertAction : UIAlertAction!) -> Void in
        })
        self.presentViewController(self.alertIgramr, animated: true, completion: nil)
    }
    
    
    // MARK: - These functions use for initialization and set layout.
    func initializeComponents(){
        initializeApplicationApiClient()
        // This function use for common initialization of components.
    }
    
    func configureComponentsLayout(){
        // This function use for set layout of components.
    }
    
    func assignDataToComponents(){
        // This function use for assign data to components.
    }
    
    func isAssignDataToComponents()->Bool{
        // This function use for triger, assignDataToComponents on viewDidAppear based on return value.
        return true
    }
    
    func initializeApplicationApiClient(){
        // This function use for Api initialization and retrun object.
        // initialization your App api class
        sharedApi = ApiClient.sharedApiClient()
    }
    

    
}
