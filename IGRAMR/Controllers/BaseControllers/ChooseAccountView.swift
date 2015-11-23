//
//  ChooseAccountView.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 10/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

import Foundation
import UIKit

protocol userInfoDelegate {
    func getSavedUserInfoData(objUser:User)
}

class ChooseAccountView : UIView , UITableViewDelegate , UITableViewDataSource {
    
    var imageView: UIImageView = UIImageView()
    var tblView : UITableView = UITableView()
    var arrSavedUser : NSArray = NSArray()
    var preSelectedIndex : Int = 100
    var delegate: userInfoDelegate?

    
    // MARK: - Initialze view
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRectMake(frame.origin.x, frame.origin.y , frame.size.width, frame.size.height)
        self.applyDefaults(frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func applyDefaults(frame: CGRect){
        
        imageView.frame = CGRectMake(0, 0 , frame.size.width, frame.size.height)
        imageView.image = UIImage(named: "loginDrop")
        imageView.userInteractionEnabled = true
        self.addSubview(imageView)
        
        tblView.frame = CGRectMake(0, 40 , frame.size.width, frame.size.height - 40)
        self.tblView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tblView.delegate = self
        tblView.dataSource = self
        tblView.separatorStyle = UITableViewCellSeparatorStyle.None
        tblView.scrollEnabled = false
        tblView.backgroundColor = UIColor.clearColor()
        self.imageView.addSubview(tblView)
        
    }
    
    
    
    // MARK: - TableView Delegate and Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSavedUser.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 42.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let objUser : User = self.arrSavedUser[indexPath.row] as! User
        
        var cell  = self.tblView.dequeueReusableCellWithIdentifier("cell")
        if (cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        
        let imgRadioBtn : UIImageView = UIImageView(frame: CGRectMake(20, 15 , 12, 12))
        if preSelectedIndex == indexPath.row {
            imgRadioBtn.image = UIImage(named: "loginDotBlue")
        }else{
            imgRadioBtn.image = UIImage(named: "loginDotGrey")
        }
        cell?.contentView.addSubview(imgRadioBtn)

        let lblUserName : UILabel = UILabel(frame: CGRectMake(42, 0 , 100, 40))
        lblUserName.text = objUser.user_name
        lblUserName.textAlignment = NSTextAlignment.Left
        lblUserName.textColor = UIColor.appBackgroundColor()
        lblUserName.font = UIFont.defaultFontOfSize(15)
        cell?.addSubview(lblUserName)
        
        cell?.backgroundColor = UIColor.clearColor()
        return cell!

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let objUser : User = self.arrSavedUser[indexPath.row] as! User
        preSelectedIndex = indexPath.row
        self.removeFromSuperview()
        self.delegate?.getSavedUserInfoData(objUser)
    }
    
}
