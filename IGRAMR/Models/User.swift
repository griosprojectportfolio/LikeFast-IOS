//
//  User.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 14/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var access_token: String
    @NSManaged var user_id: NSNumber
    @NSManaged var full_name: String
    @NSManaged var bio: String
    @NSManaged var profile_picture: String
    @NSManaged var user_name: String
    @NSManaged var website: String

    
    class func findOrCreateByIDInContext(anID : NSNumber , localContext : NSManagedObjectContext) -> User {
        
        if let objUser : User = User.MR_findFirstByAttribute("user_id", withValue: anID, inContext: localContext) {
            return objUser
        }else{
            let objUser : User = User.MR_createEntityInContext(localContext)
            return objUser
        }
    }
    
    class func entityFromArrayInContext(aArray : NSArray , localContext : NSManagedObjectContext){
        for aDictionary in aArray {
            User.entityFromDictionaryInContext(aDictionary as! NSDictionary, localContext: localContext)
        }
    }
    
    class func entityFromDictionaryInContext(aDictionary : NSDictionary, localContext : NSManagedObjectContext){
        
        let dictUser : NSDictionary = aDictionary["user"] as! NSDictionary
        
        if let user_id : String = dictUser["id"] as? String {
            
            let objUser : User = User.findOrCreateByIDInContext( Int(user_id)!, localContext: localContext)
            
            objUser.user_id = Int(user_id)!
            
            if let first_name : String = dictUser["full_name"] as? String {
                objUser.full_name = first_name
            }
            
            if let bio : String = dictUser["bio"] as? String {
                objUser.bio = bio
            }
            
            if let profile_picture : String = dictUser["profile_picture"] as? String {
                objUser.profile_picture = profile_picture
            }
            
            if let username : String = dictUser["username"] as? String {
                objUser.user_name = username
            }
            
            if let website : String = dictUser["website"] as? String {
                objUser.website = website
            }
            
            if let access_token : String = aDictionary["access_token"] as? String {
                objUser.access_token = access_token
            }
        }
        
    }
    
}
