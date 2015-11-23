//
//  UserMedia.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 14/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

import Foundation
import CoreData

class UserMedia: NSManagedObject {

    @NSManaged var created_time: String
    @NSManaged var media_id: String
    @NSManaged var media_imgUrl: String
    @NSManaged var likes: NSNumber
    @NSManaged var user_id: NSNumber
    @NSManaged var isUser_liked: NSNumber

    
    class func findOrCreateByIDInContext(anID : String , localContext : NSManagedObjectContext) -> UserMedia {
        
        if let objUser : UserMedia = UserMedia.MR_findFirstByAttribute("media_id", withValue: anID , inContext: localContext) {
            return objUser
        }else{
            let objUser : UserMedia = UserMedia.MR_createEntityInContext(localContext)
            return objUser
        }
    }
    
    class func entityFromArrayInContext(aArray : NSArray , localContext : NSManagedObjectContext){
        for aDictionary in aArray {
            UserMedia.entityFromDictionaryInContext(aDictionary as! NSDictionary, localContext: localContext)
        }
    }
    
    class func entityFromDictionaryInContext(aDictionary : NSDictionary, localContext : NSManagedObjectContext){
        
        let objImage : NSDictionary = (aDictionary["images"] as! NSDictionary)["standard_resolution"] as! NSDictionary
        let objLikes : NSDictionary = aDictionary["likes"] as! NSDictionary
        let objUser : NSDictionary = aDictionary["user"] as! NSDictionary
        let createdTime : String = aDictionary["created_time"] as! String
        let isLike : Bool = UserMedia.isMediaLikedByCurrentUser(objLikes["data"] as! NSArray, userId: objUser["id"] as! String)

        if let media_id : String = aDictionary["id"] as? String {
            
            let objUserMedia : UserMedia = UserMedia.findOrCreateByIDInContext( media_id , localContext: localContext)
            
            objUserMedia.media_id = media_id
            objUserMedia.created_time = createdTime
            objUserMedia.isUser_liked = isLike

            if let media_imgUrl : String = objImage["url"] as? String {
                objUserMedia.media_imgUrl = media_imgUrl
            }
            
            if let likes : NSNumber = objLikes["count"] as? NSNumber {
                objUserMedia.likes = likes
            }
            
            if let user_id : String = objUser["id"] as? String {
                objUserMedia.user_id = Int(user_id)!
            }

        }
        
    }
    
    class func isMediaLikedByCurrentUser(arrLikeUsers : NSArray, userId: String) -> Bool {
        
        for var i = 0 ; i < arrLikeUsers.count ; i++ {
            let dictLike : NSDictionary = arrLikeUsers[i] as! NSDictionary
            if dictLike["id"] as! String == userId {
                return true
            }
        }
        return false
    }
    
}
