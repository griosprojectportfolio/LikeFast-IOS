//
//  ApiClient.swift
//  DemoAppSwift
//
//  Created by GrepRuby1 on 04/09/15.
//  Copyright (c) 2015 GrepRuby. All rights reserved.
//

import Foundation
import UIKit

var kAppAPIBaseURLString : String! = ""
//var kAppAPIBaseURLString : String! = "https://gr-mobile-apis.herokuapp.com/api/v1/"

class ApiClient : AFHTTPRequestOperationManager {
    
    // MARK: - API Clients
    
    class func sharedApiClient() -> ApiClient {
        
        var onceToken: dispatch_once_t = 0
        var instance: ApiClient = ApiClient()
        
        dispatch_once(&onceToken, { () -> Void in
            instance = ApiClient(baseURL : NSURL(string : kAppAPIBaseURLString))
        });
        return instance
    }
    
    // MARK: - API Initialization
    
    override init(baseURL url: NSURL?) {
        super.init(baseURL: url)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Check Network Reachability
    
    func isNetworkReachable() -> Bool{
        if Reachability.reachabilityForInternetConnection().currentReachabilityStatus() == NotReachable {
            return false
        }
        return true
    }
    
    
    // MARK: - Common POST Method
    
    func postJsonDataFromUrl(URLString : String, aParams:NSDictionary, successBlock:(task:AFHTTPRequestOperation, responseObject:AnyObject) ->(),failureBlock:(task:AFHTTPRequestOperation, error:NSError) ->()) -> AFHTTPRequestOperation {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        return self.POST(URLString, parameters:aParams as AnyObject, success: { (task:AFHTTPRequestOperation!,respose:AnyObject!) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            successBlock(task: task ,responseObject: respose)
            
            }, failure: { (task:AFHTTPRequestOperation!, error:NSError!) -> Void in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                failureBlock(task: task, error: error)
        })!
    }
    
    
    
    // MARK: - Common GET Method
    
    func getJsonDataFromUrl(URLString : String, aParams:NSDictionary, successBlock:(task:AFHTTPRequestOperation, responseObject:AnyObject) ->(),failureBlock:(task:AFHTTPRequestOperation, error:NSError) ->()) -> AFHTTPRequestOperation {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        return self.GET(URLString, parameters:nil, success: { (task:AFHTTPRequestOperation!,respose:AnyObject!) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            successBlock(task: task ,responseObject: respose)
            
            }, failure: { (task:AFHTTPRequestOperation!, error:NSError!) -> Void in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                failureBlock(task: task, error: error)
                
        })!
    }
    
    
    
    // MARK: - Base Method

    func baseRequestWithHTTPMethod(method : String, URLString : String, parameters : NSDictionary, successBlock:(task:AFHTTPRequestOperation, responseObject:AnyObject) ->(),failureBlock:(task:AFHTTPRequestOperation, error:NSError) ->()) -> AFHTTPRequestOperation {
        
        let isReachable : Bool = isNetworkReachable()
        var requestOperation : AFHTTPRequestOperation!
        
        if !isReachable {
            
            dispatch_async(dispatch_get_main_queue(),{
                LoadingView.shared.hideOverlayView()
                let alert:UIAlertView = UIAlertView(title:"Network error!", message:"Network seems to be Disconnected.", delegate:nil, cancelButtonTitle:"OK")
                alert.show()
            })
            
            return AFHTTPRequestOperation()
            
        }else{
            
            let URL : String = kAppAPIBaseURLString.stringByAppendingString(URLString)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let baseSuccessBlock: (task:AFHTTPRequestOperation!, responseObject:AnyObject!) ->() = { (task:AFHTTPRequestOperation!, responseObject:AnyObject!) ->() in
                print(responseObject, terminator: "")
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                successBlock(task:task,responseObject:responseObject)
            };
            
            let baseFailureBlock: (task:AFHTTPRequestOperation!, error:NSError!) ->() = { (task:AFHTTPRequestOperation!, error:NSError!) ->() in
                print(error, terminator: "")
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                failureBlock(task:task,error:error)
            };
            
            switch method {
                
            case "GET":
                requestOperation = self.GET(URL, parameters:parameters, success:baseSuccessBlock, failure:baseFailureBlock)
            case "POST":
                requestOperation = self.POST(URL, parameters:parameters, success:baseSuccessBlock, failure:baseFailureBlock)
            case "PATCH":
                requestOperation = self.PATCH(URL, parameters:parameters, success:baseSuccessBlock, failure:baseFailureBlock)
            case "DELETE":
                requestOperation = self.DELETE(URL, parameters:parameters, success:baseSuccessBlock, failure:baseFailureBlock)
            default:
                requestOperation = nil
            }
            
            return requestOperation
            
        }
    }
    
}