//
//  MyTimeLineController.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 08/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds


class MyTimeLineController : BaseController, searchTypeDelegate, searchDataDelegate, imageLikeDelegate {
    
    @IBOutlet var btnSelectFilter: UIButton?
    @IBOutlet var txtSearchField : UITextField?
    @IBOutlet var collectionView: UICollectionView?
    
    var isNewUser : Bool = false
    
    var arrUserMedia : NSArray = NSArray()
    var objInstagram : Instagram = Instagram()

    // MARK: - Selected cell and cell Cache objects
    var arrSelectedImg : NSMutableArray = NSMutableArray()
    var cellImageCache = [String:UIImage]()
    
    // MARK: - Search view objects
    var isOpenTagView : Bool = true
    var intFilterType : Int!
    var searchTagView : SearchTagView!
    var arrSearchData : NSMutableArray = NSMutableArray()
    var nextPageUrl : String = String()

    // MARK: - Cell Tap gesture objects
    var singleTapGesture : UITapGestureRecognizer!
    var doubleTapGesture : UITapGestureRecognizer!
    
    
    // MARK: - Current View Related Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadTimeLineDataFromDB()
        self.setupiAdBannerView()
        self.objInstagram.searchDelegate = self
        self.objInstagram.likeDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup befour appear the view.
        self.navigationController?.navigationBar.hidden = false
        self.collectionView!.registerClass(MyTimelineCell.self, forCellWithReuseIdentifier: "imageCell")
        self.addRightAndLeftNavItemOnView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadTimeLineDataFromDB", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after appear the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification , object: nil)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Some Common SearchView methods
    func loadTimeLineDataFromDB() {
        
        self.title = "MY TIMELINE"
        
        self.resetAllCollections()
        
        searchTagView = SearchTagView(frame: CGRectMake(15,104,200,210))
        self.searchTagView.delegate = self

        self.intFilterType = 100
        self.btnSelectFilter?.setBackgroundImage(UIImage(named:"statusBarSeach"), forState: UIControlState.Normal)
        self.txtSearchField?.text = ""
        self.txtSearchField?.placeholder = "SEARCH"
        
        self.startLoadingOverLayView("Loading...")
        self.objInstagram.getUsersRecentMediaList("\(self.current_userId)", access_token: self.access_token)
    }
    
    func resetAllCollections(){
        self.nextPageUrl = ""
        self.arrUserMedia = NSArray()
        self.arrSearchData.removeAllObjects()
        self.arrSelectedImg.removeAllObjects()
        self.cellImageCache.removeAll()
        self.collectionView?.reloadData()
        self.hideNoDataFoundLabel()
    }
    
    func storeUserTimeLineData(dictData: NSDictionary) {
        
        MagicalRecord.saveWithBlock({ ( context : NSManagedObjectContext!) -> Void in
            UserMedia.entityFromArrayInContext( dictData["data"] as! [AnyObject] , localContext: context)
        })
        
        if (dictData["pagination"] as! NSDictionary)["next_url"] != nil {
            self.nextPageUrl = (dictData["pagination"] as! NSDictionary)["next_url"] as! String
        }else {
            self.nextPageUrl = ""
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            let userIdPredicate : NSPredicate = NSPredicate(format: "user_id == \(self.current_userId)")
            self.arrUserMedia = UserMedia.MR_findAllSortedBy("created_time", ascending: false, withPredicate: userIdPredicate)
            self.collectionView?.reloadData()
            self.stopLoadingOverLayView()
            if self.isNewUser {
                self.isNewUser = false
                self.showFullScreenAd()
            }
        }
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
        btnLogOut.tintColor = UIColor.whiteColor()
        btnLogOut.setImage(UIImage(named:"menuLogout"), forState: UIControlState.Normal)
        btnLogOut.addTarget(self, action: "logoutButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        let rightBarButtonItemback: UIBarButtonItem = UIBarButtonItem(customView: btnLogOut)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItemback, animated: false)
    }
    
    @IBAction func leftNavBackButtonTapped(sender: UIButton) {
        self.loadTimeLineDataFromDB()
    }
    
    @IBAction func logoutButtonTapped(sender: UIButton) {
        self.setUserLoggedOutAndResetToken()
    }
    
    
    
    // MARK: - Collection view Delegate method
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.getVisibleMedia_count()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.collectionView!.frame.size.width / 3.5, height: self.collectionView!.frame.size.width / 3.5);
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! MyTimelineCell
        let urlString : String = self.getVisibleMedia_url(indexPath)
        let mediaID : String = self.getVisibleMedia_id(indexPath)
        let isLiked : Bool = self.getVisibleMedia_likes(indexPath)
        cell.applyDefaults(cell.frame, arrSelectedImg: self.arrSelectedImg, mediaId: mediaID, isLiked: isLiked)
        
        if intFilterType == 0 {
            singleTapGesture = UITapGestureRecognizer(target: self, action : "detectSingleTapOnCell:")
            singleTapGesture.numberOfTapsRequired = 1
            cell.addGestureRecognizer(singleTapGesture)
        }else {
            doubleTapGesture = UITapGestureRecognizer(target: self, action : "detectDoubleTapOnCell:")
            doubleTapGesture.numberOfTapsRequired = 2
            cell.addGestureRecognizer(doubleTapGesture)
        }
        
        cell.imageView.image = nil
        // If this image is already cached, don't re-download
        if let img = self.cellImageCache[urlString] {
            cell.imageView?.image = img
        }
        else {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                if let url = NSURL(string: urlString) {
                    if let data = NSData(contentsOfURL: url){
                        // Convert the downloaded data in to a UIImage object
                        let image = UIImage(data: data)
                        // Store the image in to our cache
                        self.cellImageCache[urlString] = image
                        // Update the cell
                        dispatch_async(dispatch_get_main_queue(), {
                            if let cellToUpdate : MyTimelineCell = self.collectionView!.cellForItemAtIndexPath(indexPath) as? MyTimelineCell {
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
        
        if indexPath.row + 1 == self.getVisibleMedia_count(){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            print("Last Cell ====",self.nextPageUrl);
            self.collectionView!.performBatchUpdates({
                if !self.nextPageUrl.isEmpty {
                    self.startLoadingOverLayView("Loading...")
                    self.objInstagram.getMoreDataFromPagination(self.nextPageUrl)
                }
                },completion: nil)
            }
        }
    }
    
    
    // MARK: - Cell Tap Gesture Recognisture methods
    
    func detectSingleTapOnCell(sender: UITapGestureRecognizer) {
        let touch = sender.locationInView(self.collectionView)
        if let indexPath = self.collectionView?.indexPathForItemAtPoint(touch) {
            let userTimelineView = self.storyboard?.instantiateViewControllerWithIdentifier("UserTimeline") as! UserTimelineController
            userTimelineView.userId = self.getVisibleMedia_id(indexPath)
            userTimelineView.strTitle = self.getVisibleMedia_name(indexPath)
            self.navigationController?.pushViewController(userTimelineView, animated: true)
        }
    }
    
    func detectDoubleTapOnCell(sender: UITapGestureRecognizer) {
        let touch = sender.locationInView(self.collectionView)
        if let indexPath = self.collectionView?.indexPathForItemAtPoint(touch) {
            let mediaID : String = self.getVisibleMedia_id(indexPath)
            self.postImageLikeOnServer(mediaID, indexPath: indexPath)
        }
    }
    
    // MARK: - Image Like and their methods
    
    func postImageLikeOnServer(mediaID : String, indexPath : NSIndexPath) {
        
        self.userLike_count = Int(self.userLike_count) + 1
        self.startLoadingOverLayView("Liking...")
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            
            self.objInstagram.postMediaTolike(mediaID, atIndexPath: indexPath)

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.arrSelectedImg.removeAllObjects()
                self.collectionView?.reloadData()
            }
        })
    }
    
    func imageLikeErrorWithTitleAndMessage(title: String ,message: String, indexPath : NSIndexPath) {
        
        self.stopLoadingOverLayView()
        dispatch_async(dispatch_get_main_queue(), {
            if let cellToUpdate : MyTimelineCell = self.collectionView!.cellForItemAtIndexPath(indexPath) as? MyTimelineCell {
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
            if let cellToUpdate : MyTimelineCell = self.collectionView!.cellForItemAtIndexPath(indexPath) as? MyTimelineCell {
                cellToUpdate.imageLike.image = UIImage( named: "pre_liked")
            }
        })
        self.alertIgramr = UIAlertController.alertWithTitleAndMessage(title , message: message, handler:{(objAlertAction : UIAlertAction!) -> Void in
            self.showAdOnHeartButtonTapped()
        })
        self.presentViewController(self.alertIgramr, animated: true, completion: nil)
        
    }

    
    
    // MARK: - Text Field Delegate Methods
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.resetAllCollections()
        if !textField.text!.isEmpty {
            self.postSearchTermOnServerToGetResult(textField.text!)
        }else {
            self.loadTimeLineDataFromDB()
        }
        return false
    }
    
    
    // MARK: - Filter Button Actions and searchTypeDelegate Methods
    @IBAction func searchTagButtonTapped(sender: UIButton) {
        if isOpenTagView{
            isOpenTagView = false
            self.view.addSubview(searchTagView)
        }else{
            isOpenTagView = true
            searchTagView.removeFromSuperview()
        }
    }
    
    func getSearchTypeData(searchType: String, type: Int){
        
        intFilterType = type
        isOpenTagView = true
        self.txtSearchField?.text = ""
        self.title = "SEARCH"
        self.txtSearchField?.becomeFirstResponder()
        self.resetAllCollections()
        
        switch intFilterType {
        case 0 :
            self.btnSelectFilter?.setBackgroundImage(UIImage(named:"statusBarFollower"), forState: UIControlState.Normal)
            self.txtSearchField?.placeholder = "SEARCH BY USERNAME"
        case 1 :
            self.btnSelectFilter?.setBackgroundImage(UIImage(named:"statusBarHashtag"), forState: UIControlState.Normal)
            self.txtSearchField?.placeholder = "SEARCH BY HASHTAG"
        default:
            self.btnSelectFilter?.setBackgroundImage(UIImage(named:"statusBarSeach"), forState: UIControlState.Normal)
        }
    }
    
    func postSearchTermOnServerToGetResult(searchTerm:String){
        self.resetAllCollections()
        switch intFilterType {
        case 0:
            self.startLoadingOverLayView("Searching...")
            self.objInstagram.getSearchedUserFromName(searchTerm)
        case 1:
            self.startLoadingOverLayView("Searching...")
            self.objInstagram.getSearchedMediaFromHashTags(searchTerm)
        default:
            self.alertIgramr = UIAlertController.alertWithTitleAndMessage("Choose Filter" ,message:"Please select search filter first.", handler:{(objAlertAction : UIAlertAction!) -> Void in
                self.txtSearchField?.text = ""
            })
            self.presentViewController(self.alertIgramr, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - searchDataDelegate Delegate Methods
    func getUserTimeLineData(dictData: NSDictionary) {
        self.storeUserTimeLineData(dictData)
    }
    
    func getSearchedDataByUserName(dictData: NSDictionary) {
        
        self.arrSearchData = dictData["data"]?.mutableCopy() as! NSMutableArray
        if self.arrSearchData.count > 0 {
            if dictData["pagination"] != nil {
                self.nextPageUrl = (dictData["pagination"] as! NSDictionary)["next_url"] as! String
            }else {
                self.nextPageUrl = ""
            }
        }else {
            self.showNoDataFoundLabels()
        }
        self.collectionView?.reloadData()
        self.stopLoadingOverLayView()
    }
    
    func getSearchedDataByHashTag(dictData: NSDictionary) {
        
        self.arrSearchData = dictData["data"]?.mutableCopy() as! NSMutableArray
        if self.arrSearchData.count > 0 {
            if (dictData["pagination"] as! NSDictionary)["next_url"] != nil {
                self.nextPageUrl = (dictData["pagination"] as! NSDictionary)["next_url"] as! String
            }else {
                self.nextPageUrl = ""
            }
        }else {
            self.showNoDataFoundLabels()
        }
        self.collectionView?.reloadData()
        self.stopLoadingOverLayView()
    }
    
    func loadNextPageFromPagination_url(dictData: NSDictionary){
        
        self.stopLoadingOverLayView()
        
        if intFilterType == 0 || intFilterType == 1 {
            
            if dictData["pagination"] != nil {
                self.nextPageUrl = (dictData["pagination"] as! NSDictionary)["next_url"] as! String
            }else{
                self.nextPageUrl = ""
            }
            let arrAppend : NSArray = dictData["data"]?.mutableCopy() as! NSArray
            self.arrSearchData.addObjectsFromArray(arrAppend as [AnyObject])
            self.collectionView?.reloadData()
            
        }else {
            
            self.storeUserTimeLineData(dictData)
        }
    }
        
    func getErrorWithTitleAndMessage(title: String ,message: String) {
        self.stopLoadingOverLayView()
        self.alertIgramr = UIAlertController.alertWithTitleAndMessage(title , message: message, handler:{(objAlertAction : UIAlertAction!) -> Void in
        })
        self.presentViewController(self.alertIgramr, animated: true, completion: nil)
    }
    
    
    // MARK: - Get Current Visible Media Properties
    func getVisibleMedia_id( indexPath : NSIndexPath ) -> String {
        
        var mediaID : String = String()
        if intFilterType == 0 || intFilterType == 1 {
            let objMedia : NSDictionary = self.arrSearchData[indexPath.row] as! NSDictionary
            mediaID = objMedia["id"] as! String
        }else {
            let objUserMedia : UserMedia = self.arrUserMedia[indexPath.row] as! UserMedia
            mediaID = objUserMedia.media_id
        }
        return mediaID        
    }
    
    func getVisibleMedia_url( indexPath : NSIndexPath ) -> String {
        
        var urlString : String = String()
        
        if intFilterType == 0 {
            let objUser : NSDictionary = self.arrSearchData[indexPath.row] as! NSDictionary
            urlString = objUser["profile_picture"] as! String
        }else if intFilterType == 1 {
            let objMedia : NSDictionary = self.arrSearchData[indexPath.row] as! NSDictionary
            let dictImage : NSDictionary = (objMedia["images"] as! NSDictionary)["standard_resolution"] as! NSDictionary
            urlString = dictImage["url"] as! String
        }else{
            let objUserMedia : UserMedia = self.arrUserMedia[indexPath.row] as! UserMedia
            urlString = objUserMedia.media_imgUrl
        }
        return urlString
    }
    
    func getVisibleMedia_name( indexPath : NSIndexPath ) -> String {
        
        var strName : String = String()
        
        if intFilterType == 0 {
            let objUser : NSDictionary = self.arrSearchData[indexPath.row] as! NSDictionary
            strName = objUser["full_name"] as! String
        }else if intFilterType == 1 {
            let objMedia : NSDictionary = self.arrSearchData[indexPath.row] as! NSDictionary
            let dictImage : NSDictionary = (objMedia["images"] as! NSDictionary)["standard_resolution"] as! NSDictionary
            strName = dictImage["url"] as! String
        }else{
            let objUserMedia : UserMedia = self.arrUserMedia[indexPath.row] as! UserMedia
            strName = objUserMedia.media_imgUrl
        }
        return strName
    }
    
    func getVisibleMedia_count() -> Int {
        let count : Int = intFilterType == 0 || intFilterType == 1 ? self.arrSearchData.count : self.arrUserMedia.count
        return count
    }
    
    func getVisibleMedia_likes(indexPath : NSIndexPath) -> Bool {
        var isLiked : Bool = false
        if intFilterType == 0 {
            isLiked = false
        }else if intFilterType == 1 {
            let objMedia : NSDictionary = self.arrSearchData[indexPath.row] as! NSDictionary
            isLiked = self.isMediaLikedByCurrentUser(objMedia)
        }else{
            let objUserMedia : UserMedia = self.arrUserMedia[indexPath.row] as! UserMedia
            isLiked = objUserMedia.isUser_liked as Bool
        }
        return isLiked
    }
    
    
    
    // MARK: - These functions use for initialization and set layout. Uncomment code if required.
    override func configureComponentsLayout(){
        super.configureComponentsLayout()
        // This function use for common initialization of components.
        if isiPhone4s {
            self.collectionView?.frame = CGRectMake(0,90, self.view.frame.size.width, self.view.frame.size.height - 140)
        }else if isiPhone5 {
            self.collectionView?.frame = CGRectMake(0,98, self.view.frame.size.width, self.view.frame.size.height - 150)
        }else if isiPhone6plus {
            self.collectionView?.frame = CGRectMake(0,109, self.view.frame.size.width, self.view.frame.size.height - 160)
        }else if isiPadAir2 {
            self.btnSelectFilter?.frame = CGRectMake(self.btnSelectFilter!.frame.origin.x + 10, self.btnSelectFilter!.frame.origin.y + 10, self.btnSelectFilter!.frame.size.width - 10, self.btnSelectFilter!.frame.size.height - 10)
            self.txtSearchField?.frame = CGRectMake(self.txtSearchField!.frame.origin.x,self.txtSearchField!.frame.origin.y + 5, self.txtSearchField!.frame.size.width, self.txtSearchField!.frame.size.height)
            self.txtSearchField?.font = UIFont.systemFontOfSize(22.0)
            self.collectionView?.frame = CGRectMake(0,131, self.view.frame.size.width, self.view.frame.size.height - 180)
        }
    }
    
    
}