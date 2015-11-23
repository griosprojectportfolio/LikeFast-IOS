//
//  LoginController.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 08/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//


import Foundation
import UIKit

class LoginController : BaseController , userInfoDelegate , newUserInfoDelegate {
    
    var selectedUserId : NSNumber!
    var choosenUser : User!
    var chooseAccountView : ChooseAccountView!
    
    @IBOutlet var btn_chooseLogin: UIButton?
    @IBOutlet var btn_Login: UIButton?
    @IBOutlet var btn_AutoLogin: UIButton?
    @IBOutlet var lblLoginAutom: UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = true
        // Do any additional setup befour appear the view.
        if(self.current_userId != 0) {
            let myTimeLine = self.storyboard?.instantiateViewControllerWithIdentifier("MyTimeLine") as! MyTimeLineController
            myTimeLine.isNewUser = false
            self.navigationController?.pushViewController(myTimeLine, animated: false)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after appear the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: -  Button Tap Action Methods
    @IBAction func loginButtonTapped(sender: UIButton) {
        self.current_userId = self.choosenUser.user_id
        self.access_token = self.choosenUser.access_token
        let myTimeLine = self.storyboard?.instantiateViewControllerWithIdentifier("MyTimeLine") as! MyTimeLineController
        myTimeLine.isNewUser = false
        self.navigationController?.pushViewController(myTimeLine, animated: true)
    }
    
    @IBAction func chooseAccountButtonTapped(sender: UIButton) {
        let arrAllSavedUser : NSArray = User.MR_findAll()
        if arrAllSavedUser.count > 0 {
            self.chooseAccountView.arrSavedUser = arrAllSavedUser
            self.chooseAccountView.tblView.reloadData()
            self.view.addSubview(chooseAccountView)
        }else{
            let instagramView = self.storyboard!.instantiateViewControllerWithIdentifier("InstagramLogin") as! Instagram
            instagramView.delegate = self
            let navController = UINavigationController(rootViewController: instagramView)
            self.presentViewController(navController, animated:true, completion: nil)
        }
    }
    
    @IBAction func loginAutomaticallyButtonTapped(sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.setBackgroundImage(UIImage(named: "loginDotBlue"), forState: UIControlState.Normal)
        }else{
            sender.tag = 0
            sender.setBackgroundImage(UIImage(named: "loginDotGrey"), forState: UIControlState.Normal)
        }
    }
    
    
    // MARK: -  userInfoDelegate Delegate Methods
    func getSavedUserInfoData(objUser : User){
        self.choosenUser = objUser
        self.btn_chooseLogin?.setBackgroundImage(UIImage(named: "loginAcct"), forState: UIControlState.Normal)
        self.btn_chooseLogin?.setTitle(objUser.user_name, forState: UIControlState.Normal)
        self.btn_chooseLogin?.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        self.btn_Login?.hidden = false
        self.lblLoginAutom?.hidden = false
        self.btn_AutoLogin?.hidden = false
    }
    
    
    // MARK: -  newUserInfoDelegate Delegate Methods
    func getNewUserInfoData(token:String,userId:String){
        self.current_userId = Int(userId)!
        self.access_token = token
        let myTimeLine = self.storyboard?.instantiateViewControllerWithIdentifier("MyTimeLine") as! MyTimeLineController
        myTimeLine.isNewUser = true
        self.navigationController?.pushViewController(myTimeLine, animated: true)
    }
    
    
    // MARK: - These functions use for initialization and set layout. Uncomment code if required.
    override func configureComponentsLayout(){
       super.configureComponentsLayout()
       // This function use for set layout of components.
        self.btn_Login?.hidden = true
        self.lblLoginAutom?.hidden = true
        self.btn_AutoLogin?.hidden = true
        chooseAccountView = ChooseAccountView(frame: CGRectMake(self.btn_chooseLogin!.frame.origin.x ,self.btn_chooseLogin!.frame.origin.y, self.btn_chooseLogin!.frame.size.width, 210))
        chooseAccountView.delegate = self
    }
    
    
}