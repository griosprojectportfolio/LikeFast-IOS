//
//  UserTimelineController.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 10/11/15.
//  Copyright © 2015 GrepRuby3. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class UserTimelineController : BaseController, searchDataDelegate, imageLikeDelegate {
    
    @IBOutlet var userTimelineColleView: UICollectionView?
    
    // MARK: - Search view Collectioons
    var arrSearchData : NSMutableArray = NSMutableArray()
    var arrSelectedMedia_Ids : NSMutableArray = NSMutableArray()
    var searchCellCache = [String:UIImage]()
    
    var objInstagram : Instagram = Instagram()
    var userId : String = String()
    var strTitle : String = String()
    var nextPageUrl : String = String()
    
    // MARK: - Cell Tap gesture objects
    var doubleTapGesture : UITapGestureRecognizer!
    
    
    
    // MARK: - View Related Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = strTitle
        // Do any additional setup after loading the view, typically from a nib.
        self.sharedApi = ApiClient.sharedApiClient()
        self.objInstagram.searchDelegate = self
        self.objInstagram.likeDelegate = self
        self.loadUsersTimelineDataFromInstagram()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup befour appear the view.
        self.addRightAndLeftNavItemOnView()
        self.userTimelineColleView!.registerClass(UserTimelineCell.self, forCellWithReuseIdentifier: "userCell")
        self.setupiAdBannerView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after appear the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Add Navigation bar and their Button Actions Methods
    func addRightAndLeftNavItemOnView(){
        
        let btnBack: UIButton = UIButton(type: UIButtonType.Custom)
        btnBack.frame = CGRectMake(0, 0, 32, 32)
        btnBack.setImage(UIImage(named:"topBarBack"), forState: UIControlState.Normal)
        btnBack.addTarget(self, action: "leftNavBackButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        let leftBarButtonItemback: UIBarButtonItem = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItemback, animated: false)
        
        btnLogOut.frame = CGRectMake(0, 0, 32, 32)
        btnLogOut.setImage(UIImage(named:"menuLogout"), forState: UIControlState.Normal)
        btnLogOut.addTarget(self, action: "logoutButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        let rightBarButtonItemback: UIBarButtonItem = UIBarButtonItem(customView: btnLogOut)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItemback, animated: false)
    }
    
    @IBAction func leftNavBackButtonTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func logoutButtonTapped(sender: UIButton) {
        self.setUserLoggedOutAndResetToken()
    }
    
    // MARK: - Collection view Delegate method
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrSearchData.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.userTimelineColleView!.frame.size.width / 3.5, height: self.userTimelineColleView!.frame.size.width / 3.5);
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userCell", forIndexPath: indexPath) as! UserTimelineCell
        let objMedia : NSDictionary = self.arrSearchData[indexPath.row] as! NSDictionary
        let dictImage : NSDictionary = (objMedia["images"] as! NSDictionary)["standard_resolution"] as! NSDictionary
        let urlString : String = dictImage["url"] as! String
        let mediaID : String = objMedia["id"] as! String
        let isLiked : Bool = self.isMediaLikedByCurrentUser(objMedia)
        cell.applyDefaults(cell.frame, arrSelectedImg: self.arrSelectedMedia_Ids, mediaId: mediaID, isLiked: isLiked)
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action : "detectDoubleTapOnCell:")
        doubleTapGesture.numberOfTapsRequired = 2
        cell.addGestureRecognizer(doubleTapGesture)
        
        cell.imageView.image = nil
        // If this image is already cached, don't re-download
        if let img = self.searchCellCache[urlString] {
            cell.imageView?.image = img
        }
        else {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                if let url = NSURL(string: urlString) {
                    if let data = NSData(contentsOfURL: url){
                        // Convert the downloaded data in to a UIImage object
                        let image = UIImage(data: data)
                        // Store the image in to our cache
                        self.searchCellCache[urlString] = image
                        // Update the cell
                        dispatch_async(dispatch_get_main_queue(), {
                            if let cellToUpdate : UserTimelineCell = self.userTimelineColleView!.cellForItemAtIndexPath(indexPath) as? UserTimelineCell {
                                cellToUpdate.imageView.contentMode = UIViewContentMode.ScaleAspectFit
                                cellToUpdate.imageView.image = image
                            }
                        })
                    }
                }
            })
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row + 1 == self.arrSearchData.count {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                print("Last Cell ====",self.nextPageUrl);
                self.userTimelineColleView!.performBatchUpdates({
                    if !self.nextPageUrl.isEmpty {
                        self.startLoadingOverLayView("Loading...")
                        self.objInstagram.getMoreDataFromPagination(self.nextPageUrl)
                    }
                    },completion: nil)
            }
        }
    }
    
    
    // MARK: - Cell Tap Gesture Recognisture methods
    
    func detectDoubleTapOnCell(sender: UITapGestureRecognizer) {
        let touch = sender.locationInView(self.userTimelineColleView)
        if let indexPath = self.userTimelineColleView?.indexPathForItemAtPoint(touch) {
            let objMedia : NSDictionary = self.arrSearchData[indexPath.row] as! NSDictionary
            let mediaID : String = objMedia["id"] as! String
            self.postImageLikeOnServer(mediaID,indexPath: indexPath)
        }
    }
    
    // MARK: - Image Like and their methods
    
    func postImageLikeOnServer(mediaID : String, indexPath : NSIndexPath) {
        
        self.userLike_count = Int(self.userLike_count) + 1
        self.startLoadingOverLayView("Liking...")
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            
            self.objInstagram.postMediaTolike(mediaID, atIndexPath: indexPath)

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.arrSelectedMedia_Ids.removeAllObjects()
                self.userTimelineColleView?.reloadData()
            }
            
        })
    }
    
    func imageLikeErrorWithTitleAndMessage(title: String ,message: String, indexPath : NSIndexPath) {
        
        self.stopLoadingOverLayView()
        dispatch_async(dispatch_get_main_queue(), {
            if let cellToUpdate : UserTimelineCell = self.userTimelineColleView!.cellForItemAtIndexPath(indexPath) as? UserTimelineCell {
                cellToUpdate.imageLike.image = nil
            }
        })
        self.alertIgramr = UIAlertController.alertWithTitleAndMessage(title , message: message, handler:{(objAlertAction : UIAlertAction!) -> Void in
            self.showAdOnHeartButtonTapped()
        })
        self.presentViewController(self.alertIgramr, animated: true, completion: nil)
    }
    
    func imageLikeSuccessWithTitleAndMessage(title: String ,message: String, indexPath : NSIndexPath) {
        
        self.stopLoadingOverLayView()
        dispatch_async(dispatch_get_main_queue(), {
            if let cellToUpdate : UserTimelineCell = self.userTimelineColleView!.cellForItemAtIndexPath(indexPath) as? UserTimelineCell {
                cellToUpdate.imageLike.image = UIImage( named: "pre_liked")
            }
        })
        self.alertIgramr = UIAlertController.alertWithTitleAndMessage(title , message: message, handler:{(objAlertAction : UIAlertAction!) -> Void in
            self.showAdOnHeartButtonTapped()
        })
        self.presentViewController(self.alertIgramr, animated: true, completion: nil)

    }
    
    // MARK: - Load More Timeline methods and there Delegate Methods
    
    func loadNextPageFromPagination_url(dictData: NSDictionary){
        self.stopLoadingOverLayView()
        if (dictData["pagination"] as! NSDictionary)["next_url"] != nil {
            self.nextPageUrl = (dictData["pagination"] as! NSDictionary)["next_url"] as! String
        }else{
            self.nextPageUrl = ""
        }
        let arrAppend : NSArray = dictData["data"]?.mutableCopy() as! NSArray
        self.arrSearchData.addObjectsFromArray(arrAppend as [AnyObject])
        self.userTimelineColleView?.reloadData()
    }
    
    func getErrorWithTitleAndMessage(title: String ,message: String) {
        self.stopLoadingOverLayView()
        self.alertIgramr = UIAlertController.alertWithTitleAndMessage(title , message: message, handler:{(objAlertAction : UIAlertAction!) -> Void in
        })
        self.presentViewController(self.alertIgramr, animated: true, completion: nil)
    }
    
    
    // MARK: - Some Common Users Timeline methods
    func loadUsersTimelineDataFromInstagram(){
        
        self.startLoadingOverLayView("Loading...")
        
        let recentMediaUrl : String = "https://api.instagram.com/v1/users/\(userId)/media/recent/?access_token=\(self.access_token)"
        let params : NSDictionary = NSDictionary()
        
        self.sharedApi.getJsonDataFromUrl(recentMediaUrl, aParams: params, successBlock:{(operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                let dictData : NSDictionary = responseObject as! NSDictionary
                self.processJsonResponse(dictData)
                self.stopLoadingOverLayView()
            
            }, failureBlock: { (operation: AFHTTPRequestOperation?, error: NSError? ) in
                self.stopLoadingOverLayView()
        })
    }
    
    func processJsonResponse(dictData: NSDictionary) {
        
        self.arrSearchData = dictData["data"]?.mutableCopy() as! NSMutableArray
        if self.arrSearchData.count > 0 {
            self.hideNoDataFoundLabel()
            if (dictData["pagination"] as! NSDictionary)["next_url"] != nil {
                self.nextPageUrl = (dictData["pagination"] as! NSDictionary)["next_url"] as! String
            }else {
                self.nextPageUrl = ""
            }
        }else {
            self.showNoDataFoundLabels()
        }
        self.userTimelineColleView?.reloadData()
    }
    
    
    // MARK: - These functions use for initialization and set layout. Uncomment code if required.
    override func configureComponentsLayout(){
        super.configureComponentsLayout()
        // This function use for common initialization of components.
        self.userTimelineColleView?.frame = CGRectMake(0,64, self.view.frame.size.width, self.view.frame.size.height - 116)
        
    }
    
}