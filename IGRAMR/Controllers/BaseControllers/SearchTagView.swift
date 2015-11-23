//
//  SearchTagView.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 09/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

import Foundation

protocol searchTypeDelegate {
    func getSearchTypeData(searchType : String , type : Int)
}


class SearchTagView : UIView , UITableViewDelegate , UITableViewDataSource {
    
    var imageView: UIImageView = UIImageView()
    var tblView : UITableView = UITableView()
    var preSelectedIndex : Int = 100
    var searchOptions : NSArray = ["USERNAME", "HASHTAG"]
    var delegate: searchTypeDelegate?
    
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
        imageView.image = UIImage(named: "filter_bg")
        imageView.userInteractionEnabled = true
        self.addSubview(imageView)

        tblView.frame = CGRectMake(0, 10 , frame.size.width, frame.size.height)
        self.tblView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tblView.delegate = self
        tblView.dataSource = self
        tblView.separatorStyle = UITableViewCellSeparatorStyle.None
        tblView.scrollEnabled = false
        self.imageView.addSubview(tblView)
        
    }
    
    
    // MARK: - TableView Delegate and Data Source Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchOptions.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 35.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell  = self.tblView.dequeueReusableCellWithIdentifier("cell")
        if (cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }

        let imgRadioBtn : UIImageView = UIImageView(frame: CGRectMake(10,10,20,20))
        let lblUserName : UILabel = UILabel(frame: CGRectMake(42,0,90,40))
        lblUserName.text = self.searchOptions[indexPath.row] as? String
        lblUserName.textAlignment = NSTextAlignment.Left
        lblUserName.textColor = UIColor.lightGrayColor()
        lblUserName.font = UIFont.defaultFontOfSize(15)

        if preSelectedIndex == indexPath.row {
            imgRadioBtn.image = UIImage(named: "searchCheck")
            lblUserName.textColor = UIColor.appBackgroundColor()
        }
        cell?.addSubview(imgRadioBtn)
        cell?.addSubview(lblUserName)
        
        cell?.backgroundColor = UIColor.clearColor()
        cell?.selectedBackgroundView = UIView()
        
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        preSelectedIndex = indexPath.row
        self.tblView.deselectRowAtIndexPath(indexPath, animated: true)
        self.tblView.reloadData()
        self.removeFromSuperview()
        self.delegate?.getSearchTypeData(self.searchOptions[indexPath.row] as! String , type: indexPath.row)
    }
}
