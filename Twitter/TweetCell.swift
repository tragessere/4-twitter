//
//  TweetCell.swift
//  Twitter
//
//  Created by Evan on 2/9/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var tweetTextLabel: UILabel!
  @IBOutlet weak var retweetView: UIView!
  @IBOutlet weak var retweetLabel: UILabel!
  @IBOutlet weak var retweetImageView: UIImageView!
  @IBOutlet weak var favoriteImageView: UIImageView!
  @IBOutlet weak var favoriteView: UIView!
  @IBOutlet weak var favoriteLabel: UILabel!
  
  var tweet: Tweet! {
    didSet {
      profileImageView.layer.cornerRadius = 5
      profileImageView.layer.masksToBounds = true
      
      if tweet.user?.profileImageUrl != nil {
        profileImageView.image = nil
        profileImageView.backgroundColor = UIColor.whiteColor()
        profileImageView.setImageWithURL(NSURL(string: tweet.user!.profileImageUrl!)!)
      } else {
        profileImageView.image = nil
        profileImageView.backgroundColor = tweet.user?.linkColor
      }
    
      nameLabel.text = tweet.user?.name
      usernameLabel.text = "@" + tweet.user!.screenName!
      
      
      let formatter = NSDateFormatter()
      formatter.dateFormat = "MMM d"
      timeLabel.text = formatter.stringFromDate(tweet.createdAt!)
      
      tweetTextLabel.text = tweet.text
      
      if tweet.retweetCount != nil {
        retweetLabel.text = String(tweet.retweetCount!)
      } else {
        retweetLabel.text = "0"
      }
      
      if tweet.favoriteCount != nil {
        favoriteLabel.text = String(tweet.favoriteCount!)
      } else {
        favoriteLabel.text = "0"
      }
      
      if tweet.isFavorited! {
        favoriteImageView.image = UIImage(named: "like-action-on")
      } else {
        favoriteImageView.image = UIImage(named: "like-action")
      }
      
      if tweet.isRetweeted! {
        retweetImageView.image = UIImage(named: "retweet-action-inactive")
      } else {
        retweetImageView.image = UIImage(named: "retweet-action")
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    let retweetTapRecognizer = UITapGestureRecognizer(target: self, action: "retweetTapped:")
    retweetView.userInteractionEnabled = true
    retweetView.addGestureRecognizer(retweetTapRecognizer)
    
    let favoriteTapRecognizer = UITapGestureRecognizer(target: self, action: "favoriteTapped:")
    favoriteView.userInteractionEnabled = true
    favoriteView.addGestureRecognizer(favoriteTapRecognizer)
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func retweetTapped(view: AnyObject) {
    print("tapped retweet")
  }
  
  func favoriteTapped(view: AnyObject) {
    print("tapped favorite")
    
    if !tweet.isFavorited! {
      TwitterClient.sharedInstance.favoriteWithId(tweet.id!, completion: {
        (tweet, error) -> () in
        if error != nil {
          print("error favoriting tweet: \(error!.description)")
          return
        }
        
        self.tweet.isFavorited = tweet?.isFavorited
        self.tweet.favoriteCount = tweet?.favoriteCount
        
        if tweet!.favoriteCount != nil {
          self.favoriteLabel.text = String(tweet!.favoriteCount!)
        } else {
          self.favoriteLabel.text = "0"
        }
        
        self.favoriteImageView.image = UIImage(named: "like-action-on")
      })
    }
    
    else {
      TwitterClient.sharedInstance.unFavoriteWithId(tweet.id!, completion: {
        (tweet, error) -> () in
        if error != nil {
          print("error un-favoriting tweet: \(error!.description)")
          return
        }
        
        self.tweet.isFavorited = tweet?.isFavorited
        self.tweet.favoriteCount = tweet?.favoriteCount
        
        if tweet!.favoriteCount != nil {
          self.favoriteLabel.text = String(tweet!.favoriteCount!)
        } else {
          self.favoriteLabel.text = "0"
        }
        
        self.favoriteImageView.image = UIImage(named: "like-action")
      })
    }
  }
}
