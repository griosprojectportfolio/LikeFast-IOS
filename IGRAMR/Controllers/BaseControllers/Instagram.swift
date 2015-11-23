//
//  Instagram.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 11/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

//let baseURLString = "https://api.instagram.com"
//let clientID = "b8d2f232eddb4593b9f333ddfe8bb876"
//let redirectURI = "igb8d2f232eddb4593b9f333ddfe8bb876://authorize"
//let clientSecret = "9a88162ec76b40088f20a75c887c2fa5"
//let authorizationURL = NSURL(string: baseURLString + "/oauth/authorize/?client_id=" + clientID + "&redirect_uri=" + redirectURI + "&response_type=code")!

let baseURLString = "https://api.instagram.com"
let clientID = "14bf18f19222491b91b2f7aaeb6fba8b"
let redirectURI = "iglikefast://authorize"
let clientSecret = "052fdff28c3748819cb8f8c2ed30e391"
let authorizationURL = NSURL(string: baseURLString + "/oauth/authorize/?client_id=" + clientID + "&redirect_uri=" + redirectURI + "&response_type=code")!

import Foundation
import UIKit

protocol newUserInfoDelegate {
    func getNewUserInfoData(token:String,userId:String)
}

protocol imageLikeDelegate {
    func imageLikeErrorWithTitleAndMessage(title: String ,message: String, indexPath : NSIndexPath)
    func imageLikeSuccessWithTitleAndMessage(title: String ,message: String, indexPath : NSIndexPath)
}

@objc protocol searchDataDelegate {
    
    optional func getUserTimeLineData(dictData: NSDictionary)

    optional func getSearchedDataByHashTag(dictData: NSDictionary)
    optional func getSearchedDataByUserName(dictData: NSDictionary)
    optional func getSearchedDataByRecent(dictData: NSDictionary)
    
    optional func loadNextPageFromPagination_url(dictData: NSDictionary)
    optional func getErrorWithTitleAndMessage(title: String ,message: String)
}


class Instagram : BaseController , UIWebViewDelegate {
    
    var webView : UIWebView = UIWebView()
    var loadingIndicator: UIActivityIndicatorView!
    var delegate: newUserInfoDelegate?
    var searchDelegate : searchDataDelegate?
    var likeDelegate : imageLikeDelegate?
    let btnBack: UIButton = UIButton(type: UIButtonType.Custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "LOGIN"
        // Do any additional setup after loading the view, typically from a nib.
        self.addRightAndLeftNavItemOnView()
        self.setUpActivityIndicator()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadInstagramLoginView()
        // Do any additional setup befour appear the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after appear the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Activity Indicaor Methods
    func setUpActivityIndicator(){
        loadingIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        loadingIndicator.color = UIColor.appBackgroundColor()
        self.webView.addSubview(loadingIndicator)
    }
    
    // MARK: - Add Navigation bar Images
    func addRightAndLeftNavItemOnView(){
        btnBack.frame = CGRectMake(0, 0, 32, 32)
        btnBack.setImage(UIImage(named:"topBarBack"), forState: UIControlState.Normal)
        btnBack.addTarget(self, action: "leftNavBackButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        let leftBarButtonItemback: UIBarButtonItem = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItemback, animated: false)
    }
    
    @IBAction func leftNavBackButtonTapped(sender: UIButton) {
        self.navigationController?.dismissViewControllerAnimated(true, completion:nil)
    }
    
    
    // MARK: - Instagram Login Methods and their Delegates
    func loadInstagramLoginView(){
        webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        webView.delegate = self
        self.removeCacheFromInAppBrowser()
        let urlRequest : NSURLRequest = NSURLRequest(URL: authorizationURL)
        webView.loadRequest(urlRequest)
        self.view.addSubview(webView)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.URL?.absoluteString
        if let range = urlString!.rangeOfString( redirectURI + "?code=") {
            let location = range.endIndex
            let code = urlString!.substringFromIndex(location)
            self.requestAccessToken(code)
            return false
        }
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loadingIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadingIndicator.stopAnimating()
    }
    
    
    // MARK: - Remove In app Browser Cache
    func removeCacheFromInAppBrowser(){
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
    }
    
    
    // MARK: - Instagram Fetch - Get Access Token
    func requestAccessToken(code: String) {
        
        let params = ["client_id": clientID, "client_secret": clientSecret, "grant_type": "authorization_code", "redirect_uri": redirectURI, "code": code , "scope" : "likes"]
        
        loadingIndicator.stopAnimating()
        activityIndicator = ActivityIndicatorView(frame: self.view.frame)
        activityIndicator.startActivityIndicator(self)
        
        self.sharedApi.baseRequestWithHTTPMethod("POST", URLString: "https://api.instagram.com/oauth/access_token", parameters: params, successBlock:{(operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
            
                self.activityIndicator.stopActivityIndicator(self)
            
                let dictResponse : NSDictionary = responseObject as! NSDictionary
                let arrData : NSArray = NSArray(object: dictResponse)
            
                MagicalRecord.saveWithBlock({ ( context : NSManagedObjectContext!) -> Void in
                    User.entityFromArrayInContext( arrData , localContext: context)
                })
            
                if let accessToken = dictResponse["access_token"] as? String, userID = (dictResponse["user"] as! NSDictionary)["id"] as? String {
                    self.dismissViewControllerAnimated(true, completion: {
                        self.delegate?.getNewUserInfoData(accessToken, userId: userID)
                    })
                }
            
            }, failureBlock: { (operation: AFHTTPRequestOperation?, error: NSError? ) in
                
                self.activityIndicator.stopActivityIndicator(self)
        })
        
    }
    
    // MARK: - Instagram - Recent User Media List
    func getUsersRecentMediaList(userID: String , access_token: String) {
        
        let recentMediaUrl : String = "https://api.instagram.com/v1/users/\(userID)/media/recent/?access_token=\(access_token)"
        let params : NSDictionary = NSDictionary()
        self.sharedApi = ApiClient.sharedApiClient()
        
        self.sharedApi.baseRequestWithHTTPMethod("GET", URLString: recentMediaUrl, parameters: params, successBlock:{(operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
            
                let dictResponse : NSDictionary = responseObject as! NSDictionary
                self.searchDelegate?.getUserTimeLineData!(dictResponse)
            
            }, failureBlock: { (operation: AFHTTPRequestOperation?, error: NSError? ) in
                self.searchDelegate?.getErrorWithTitleAndMessage!("Error", message: "Unable to load Timeline images.")
        })
        
    }
    
    
    // MARK: - Instagram Fetch - Followers List
    func getUsersFollowsList() {
        
        let recentMediaUrl : String = "https://api.instagram.com/v1/users/\(self.current_userId)/follows/?access_token=\(self.access_token)"
        let params : NSDictionary = NSDictionary()
        self.sharedApi = ApiClient.sharedApiClient()
        
        self.sharedApi.baseRequestWithHTTPMethod("GET", URLString: recentMediaUrl, parameters: params, successBlock:{(operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
            
                let dictResponse : NSDictionary = responseObject as! NSDictionary
                print(dictResponse)
            
            }, failureBlock: { (operation: AFHTTPRequestOperation?, error: NSError? ) in
                
        })
        
    }
    
    // MARK: - Instagram Fetch - Followings List
    func getUsersFollowedByList() {
        
        let recentMediaUrl : String = "https://api.instagram.com/v1/users/\(self.current_userId)/followed-by/?access_token=\(self.access_token)"
        let params : NSDictionary = NSDictionary()
        self.sharedApi = ApiClient.sharedApiClient()
        
        self.sharedApi.baseRequestWithHTTPMethod("GET", URLString: recentMediaUrl, parameters: params, successBlock:{(operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
            
            let dictResponse : NSDictionary = responseObject as! NSDictionary
            print(dictResponse)
            
            }, failureBlock: { (operation: AFHTTPRequestOperation?, error: NSError? ) in
                
        })
        
    }
    
    // MARK: - Instagram Fetch - Like Media
    func postMediaTolike(media_id : String, atIndexPath : NSIndexPath) {
        
        let likeMediaUrl : String = "https://api.instagram.com/v1/media/\(media_id)/likes"
        let params = ["access_token" : self.access_token ,"client_id": clientID]
        self.sharedApi = ApiClient.sharedApiClient()
        
        self.sharedApi.baseRequestWithHTTPMethod("POST", URLString: likeMediaUrl, parameters: params, successBlock:{(operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
            
                let dictResponse : NSDictionary = responseObject as! NSDictionary
                print(dictResponse)
                self.likeDelegate?.imageLikeSuccessWithTitleAndMessage("LikeFast", message: "Successfully Liked.", indexPath:atIndexPath )
            
            }, failureBlock: { (operation: AFHTTPRequestOperation?, error: NSError? ) in
                
                self.likeDelegate?.imageLikeErrorWithTitleAndMessage("LikeFast", message: "This client has not been approved to access this resource.",indexPath:atIndexPath)
        })
        
    }
    
    // MARK: - Instagram Fetch - Search Media By Hash Tag
    func getSearchedMediaFromHashTags(strHashTag : String) {
        
        let tagMediaUrl : String = "https://api.instagram.com/v1/tags/\(strHashTag)/media/recent?access_token=\(self.access_token)"
        let params : NSDictionary = NSDictionary()
        self.sharedApi = ApiClient.sharedApiClient()
        
        self.sharedApi.baseRequestWithHTTPMethod("GET", URLString: tagMediaUrl, parameters: params, successBlock:{(operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
            
                let dictResponse : NSDictionary = responseObject as! NSDictionary
                self.searchDelegate?.getSearchedDataByHashTag!(dictResponse)
            
            }, failureBlock: { (operation: AFHTTPRequestOperation?, error: NSError? ) in
                self.searchDelegate?.getErrorWithTitleAndMessage!("Error", message: "Search by HashTag Have some error.")
        })
    }

    // MARK: - Instagram Fetch - Search Media By UserName
    func getSearchedUserFromName(strUserName : String) {
        
        let tagMediaUrl : String = "https://api.instagram.com/v1/users/search?q=\(strUserName)&access_token=\(self.access_token)"
        let params : NSDictionary = NSDictionary()
        self.sharedApi = ApiClient.sharedApiClient()
        
        self.sharedApi.baseRequestWithHTTPMethod("GET", URLString: tagMediaUrl, parameters: params, successBlock:{(operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
            
                let dictResponse : NSDictionary = responseObject as! NSDictionary
                self.searchDelegate?.getSearchedDataByUserName!(dictResponse)
            
            }, failureBlock: { (operation: AFHTTPRequestOperation?, error: NSError? ) in
                self.searchDelegate?.getErrorWithTitleAndMessage!("Error", message: "Search by UserName Have some error.")
        })
    }
    
    // MARK: - Instagram Fetch - Load next page URL
    func getMoreDataFromPagination(strNextPageUrl : String) {
        
        let params : NSDictionary = NSDictionary()
        self.sharedApi = ApiClient.sharedApiClient()
        
        self.sharedApi.baseRequestWithHTTPMethod("GET", URLString: strNextPageUrl, parameters: params, successBlock:{(operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
            
                let dictResponse : NSDictionary = responseObject as! NSDictionary
                self.searchDelegate?.loadNextPageFromPagination_url!(dictResponse)
            
            }, failureBlock: { (operation: AFHTTPRequestOperation?, error: NSError? ) in
                 self.searchDelegate?.getErrorWithTitleAndMessage!("Error", message: "Load more data Have some error.")
        })
    }
    
}