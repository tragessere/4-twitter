//
//  Tweet.swift
//  Twitter
//
//  Created by Evan on 2/7/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

class Tweet: NSObject {
  var user: User?
  var text: String?
  var createdAtString: String?
  var createdAt: NSDate?

  init(dictionary: NSDictionary) {
    user = User(dictionary: dictionary["user"] as! NSDictionary)
    text = dictionary["text"] as? String
    createdAtString = dictionary["created_at"] as? String
    
    var formatter = NSDateFormatter()
    formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
    createdAt = formatter.dateFromString(createdAtString!)
  }
  
  
  class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
    var tweets = [Tweet]()
    
    for dictionary in array {
      print("adding tweet")
      tweets.append(Tweet(dictionary: dictionary))
    }
    
    return tweets
  }
}
