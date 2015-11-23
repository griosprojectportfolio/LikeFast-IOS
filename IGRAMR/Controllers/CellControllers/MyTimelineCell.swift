//
//  MyTimelineCell.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 09/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

import Foundation
import UIKit

class MyTimelineCell : UICollectionViewCell {
    
    var imageView: UIImageView!
    var checkMark: UIImageView!
    var imageLike: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func applyDefaults(frame: CGRect){
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = UIColor.collectionViewCellBorderColor().CGColor
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        
        //imageLike = UIImageView(frame: CGRect(x: 5, y: 3, width: frame.size.width - 85, height: frame.size.height - 85))
        imageLike = UIImageView(frame: CGRect(x: 5, y: 3, width: 20, height: 20))
        imageLike.contentMode = UIViewContentMode.ScaleAspectFit
        imageLike.backgroundColor = UIColor.clearColor()
        contentView.addSubview(imageLike)
        
        checkMark = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        checkMark.contentMode = UIViewContentMode.ScaleAspectFit
        checkMark.backgroundColor = UIColor.clearColor()
        checkMark.layer.cornerRadius = 10
        checkMark.layer.masksToBounds = true
        contentView.addSubview(checkMark)
        
    }
    
    func applyDefaults(frame: CGRect , arrSelectedImg : NSArray , mediaId : String, isLiked: Bool){
        
        self.applyDefaults(frame)
        
        if arrSelectedImg.containsObject(mediaId){
            self.checkMark.image = UIImage(named: "boxCheck")
        }else{
            self.checkMark.image = nil
        }
        
        if isLiked {
            imageLike.image = UIImage( named: "pre_liked")
        }else {
            imageLike.image = nil
        }
        
    }
    
}