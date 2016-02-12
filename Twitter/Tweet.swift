//
//  Tweet.swift
//  Twitter
//
//  Created by Evan on 2/7/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

class Tweet: NSObject {
  var id: Int64!
  
  var user: User?
  var text: String?
  var createdAtString: String?
  var createdAt: NSDate?
  var isRetweeted: Bool?
  var retweetCount: Int?
  var isFavorited: Bool?
  var favoriteCount: Int?

  init(dictionary: NSDictionary) {
    //error here when casting the regular id straight to a 64-bit int.
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
    formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
    createdAt = formatter.dateFromString(createdAtString!)
    
    //Retweeted messages return a favorite count of '0'
    if let retweeted = dictionary["retweeted_status"] as? NSDictionary {
      favoriteCount = retweeted["favorite_count"] as? Int
    }
  }
  
  
  class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
    var tweets = [Tweet]()
    
    for dictionary in array {
//      print(dictionary)
      tweets.append(Tweet(dictionary: dictionary))
    }
    
    return tweets
  }
}
