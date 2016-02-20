//
//  Tweet.swift
//  Twitter
//
//  Created by Evan on 2/7/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

class Tweet: NSObject {
  //Current tweet info
  var id: Int64!
  var user: User?
  //Info of the original tweet if this is a retweet.
  var tweetIsRetweet: Bool?
  var originalId: Int64?
  var originalUser: User?
  
  var text: String?
  var createdAtString: String?
  var createdAt: NSDate?
  var isRetweeted: Bool?
  var retweetCount: Int?
  var isFavorited: Bool?
  var favoriteCount: Int?

  init(dictionary: NSDictionary) {
//    print(dictionary)
    //error here when casting the regular id straight to a 64-bit int. (but why?)
    id = Int64(dictionary["id_str"] as! String)
    
    user = User(dictionary: dictionary["user"] as! NSDictionary)
    
    
    text = dictionary["text"] as? String
    createdAtString = dictionary["created_at"] as? String
    retweetCount = dictionary["retweet_count"] as? Int
    favoriteCount = dictionary["favorite_count"] as? Int
    
    if let isRetweetedInt = dictionary["retweeted"] as? Int {
      isRetweeted = (isRetweetedInt == 1)
    }
    
    if let isFavoritedInt = dictionary["favorited"] as? Int {
      isFavorited = (isFavoritedInt == 1)
    }
    
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
    createdAt = formatter.dateFromString(createdAtString!)
    
    //Retweeted messages contain the original tweet inside an inner object
    if let retweeted = dictionary["retweeted_status"] as? NSDictionary {
      tweetIsRetweet = true
      
      originalId = Int64(retweeted["id_str"] as! String)
      originalUser = User(dictionary: retweeted["user"] as! NSDictionary)
      
      text = retweeted["text"] as? String
      retweetCount = retweeted["retweet_count"] as? Int
      favoriteCount = retweeted["favorite_count"] as? Int
      
    } else {
      tweetIsRetweet = false
      
      originalId = id
      originalUser = user
    }
  }
  
  
  class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
    var tweets = [Tweet]()
    
    for dictionary in array {
      tweets.append(Tweet(dictionary: dictionary))
    }
    
    return tweets
  }
}
