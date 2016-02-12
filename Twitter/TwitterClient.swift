//
//  TwitterClient.swift
//  Twitter
//
//  Created by Evan on 2/7/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "Ei1Jw1RYGNwsHRK9phLX19PlE"
let twitterConsumerSecret = "xVQUXDJtc6rApq6eMQS9Jk54wFKaMx7SZU4pJDPUxBFQj2nUcJ"
//let twitterConsumerKey = "Zwi6PYVjgkXwXhodsla7jVaz9"
//let twitterConsumerSecret = "DCtIS3p2kgslg7vqBAWXqzTPvejfhy5KPTm91yhiAapa3acSqv"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
  
  var loginCompletion: ((user: User?, error: NSError?) -> ())?
  
  class var sharedInstance: TwitterClient {
    struct Static {
      static let instance = TwitterClient(baseURL: twitterBaseURL,
          consumerKey: twitterConsumerKey,
          consumerSecret: twitterConsumerSecret)
    }
    
    return Static.instance
  }
  
  func homeTimeLineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
    
    GET(
      "1.1/statuses/home_timeline.json",
      parameters: params,
      success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
        //print("home timeline: \(response!)")
        let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
        
        completion(tweets: tweets, error: nil)
        
      }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
        print("Error getting home timeline")
        completion(tweets: nil, error: error)
    })
  }
  
  
  func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
    loginCompletion = completion
    
    //Fetch request token & redirect to authorization page
    TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
    TwitterClient.sharedInstance.fetchRequestTokenWithPath(
      "oauth/request_token",
      method: "GET",
      callbackURL: NSURL(string: "cptwitterdemo://oauth"),
      scope: nil,
      success: {(requestToken: BDBOAuth1Credential!) -> Void in
        print("Got request token")
        
        let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
        UIApplication.sharedApplication().openURL(authURL!)
      },
      failure: { (error: NSError!) -> Void in
        print("Failed to get request token\n \(error)")
        self.loginCompletion?(user: nil, error: error)
    })
  }
  
  func favoriteWithId(id: Int64, completion: (tweet: Tweet?, error: NSError?) -> ()) {
    let params : NSDictionary = ["id": NSNumber(longLong: id)]
    
    POST("1.1/favorites/create.json",
      parameters: params,
      progress: nil,
      success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
        let tweet = Tweet.init(dictionary: response as! NSDictionary)
        completion(tweet: tweet, error: nil)
      }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
        completion(tweet: nil, error: error)
    })
  }
  
  func unFavoriteWithId(id: Int64, completion: (tweet: Tweet?, error: NSError?) -> ()) {
    let params : NSDictionary = ["id": NSNumber(longLong: id)]
    
    POST("1.1/favorites/destroy.json",
      parameters: params,
      progress: nil,
      success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
        let tweet = Tweet.init(dictionary: response as! NSDictionary)
        completion(tweet: tweet, error: nil)
      }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
        completion(tweet: nil, error: error)
    })
  }
  
  func openURL(url: NSURL) {
    fetchAccessTokenWithPath(
      "oauth/access_token",
      method: "POST",
      requestToken: BDBOAuth1Credential(queryString: url.query),
      
      success: { (accessToken: BDBOAuth1Credential!) -> Void in
        print("Got the access token!")
        TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
        
        TwitterClient.sharedInstance.GET(
          "1.1/account/verify_credentials.json",
          parameters: nil,
          success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            ///print("user: \(response!)")
            let user = User(dictionary: response as! NSDictionary)
            User.currentUser = user            
            
            self.loginCompletion?(user: user, error: nil)
            
          }, failure: { (task: NSURLSessionDataTask?, error: NSError!) -> Void in
            print("Error getting user")
            self.loginCompletion?(user: nil, error: error)
        })
        
        
        
      },
      failure: { (error: NSError!) -> Void in
        print("Failed to receive access token\n\(error)")
        self.loginCompletion?(user: nil, error: error)
      }
    )

  }
}
