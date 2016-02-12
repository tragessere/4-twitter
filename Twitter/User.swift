//
//  User.swift
//  Twitter
//
//  Created by Evan on 2/7/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
  var name: String?
  var screenName: String?
  var profileImageUrl: String?
  var profileBannerUrl: String?
  var tagline: String?
  var location: String?
  
  var tweetCount: Int?
  var favoritesCount: Int?
  var followingCount: Int?
  var followersCount: Int?
  
  var backgroundColor: UIColor?
  var textColor: UIColor?
  var linkColor: UIColor?
  var borderColor: UIColor?
  
  var dictionary: NSDictionary?

  init(dictionary: NSDictionary) {
    super.init()
    
    self.dictionary = dictionary
    
    name = dictionary["name"] as? String
    screenName = dictionary["screen_name"] as? String
    profileImageUrl = dictionary["profile_image_url"] as? String
    profileBannerUrl = dictionary["profile_banner_url"] as? String
    tagline = dictionary["description"] as? String
    location = dictionary["location"] as? String
    
    tweetCount = dictionary["statuses_count"] as? Int
    favoritesCount = dictionary["favourites_count"] as? Int
    followingCount = dictionary["friends_count"] as? Int
    followersCount = dictionary["followers_count"] as? Int
    
    textColor = hexToColor(dictionary["profile_text_color"] as? String)
    backgroundColor = hexToColor(dictionary["profile_background_color"] as? String)
    linkColor = hexToColor(dictionary["profile_link_color"] as? String)
    borderColor = hexToColor(dictionary["profile_sidebar_border_color"] as? String)
    
//    print("background string: \(dictionary["profile_background_color"])")
//    print("background hex: \(backgroundColor)")
  }
  
  func logout() {
    User.currentUser = nil
    TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
    
    NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
  }
  
  
  class var currentUser: User? {
    get {
      if _currentUser == nil {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
        if data != nil {
          do {
            let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
            _currentUser = User(dictionary: dictionary)
          } catch let error as NSError {
            print("JSON load error: \(error)")
          }
        }
      }
    
      return _currentUser
    }
    
    set (user) {
      _currentUser = user
      
      if _currentUser != nil {
        do {
          let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary!,
            options: [])
          
          NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
        } catch let error as NSError {
          print("JSON save error: \(error)")
        }
      } else {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
      }
      NSUserDefaults.standardUserDefaults().synchronize()
      
    }
  }
  
  
  func hexToColor(hexColor: String?) -> UIColor? {
    if hexColor == nil || hexColor!.characters.count == 0{
      return UIColor.lightGrayColor()
    }
    
    let cString = hexColor!.uppercaseString
    
    
    let redString = cString.substringWithRange(
        Range<String.Index>(start: cString.startIndex, end: cString.startIndex.advancedBy(2)))
    
    let greenString = cString.substringWithRange(
      Range<String.Index>(start: cString.startIndex.advancedBy(2), end: cString.startIndex.advancedBy(4)))
    
    let blueString = cString.substringWithRange(
      Range<String.Index>(start: cString.startIndex.advancedBy(4), end: cString.endIndex))
    
    var r: UInt32 = 0
    var g: UInt32 = 0
    var b: UInt32 = 0
    
    NSScanner(string: redString).scanHexInt(&r)
    NSScanner(string: greenString).scanHexInt(&g)
    NSScanner(string: blueString).scanHexInt(&b)
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
  }
}
