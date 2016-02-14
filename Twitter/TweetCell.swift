//
//  TweetCell.swift
//  Twitter
//
//  Created by Evan on 2/9/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit
import KILabel

protocol TweetCellDelegate {
  func tweetCell(cell: TweetCell, didTapURL url: NSURL)
  func tweetCell(cell: TweetCell, didTapUser username: String)
  func tweetCell(cell: TweetCell, didTapHashtag hashtag: String)
}

class TweetCell: UITableViewCell {
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var tweetTextLabel: KILabel!
  @IBOutlet weak var retweetView: UIView!
  @IBOutlet weak var retweetLabel: UILabel!
  @IBOutlet weak var retweetImageView: UIImageView!
  @IBOutlet weak var favoriteImageView: UIImageView!
  @IBOutlet weak var favoriteView: UIView!
  @IBOutlet weak var favoriteLabel: UILabel!
  
  @IBOutlet weak var isRetweetedView: UIView!
  @IBOutlet weak var isRetweetedImageView: UIImageView!
  @IBOutlet weak var retweetByLabel: UILabel!
  @IBOutlet weak var retweetViewHeightConstraint: NSLayoutConstraint!
  
  
  var delegate: TweetCellDelegate?
  
  var tweet: Tweet! {
    didSet {
      profileImageView.layer.cornerRadius = 5
      profileImageView.layer.masksToBounds = true
      
      if tweet.tweetIsRetweet! {
        nameLabel.text = tweet.originalUser?.name
        usernameLabel.text = "@" + tweet.originalUser!.screenName!
        
        retweetByLabel.text = (tweet.user?.name)! + " Retweeted"
        
        retweetByLabel.hidden = false
        isRetweetedImageView.hidden = false
        retweetViewHeightConstraint.constant = 24
        
        if tweet.originalUser?.profileImageUrl != nil {
          profileImageView.image = nil
          profileImageView.backgroundColor = UIColor.whiteColor()
          profileImageView.setImageWithURL(NSURL(string: tweet.originalUser!.profileImageUrl!)!)
        } else {
          profileImageView.image = nil
          profileImageView.backgroundColor = tweet.originalUser?.linkColor
        }
        
        
      } else {
        nameLabel.text = tweet.user?.name
        usernameLabel.text = "@" + tweet.user!.screenName!
        
        retweetByLabel.hidden = true
        isRetweetedImageView.hidden = true
        retweetViewHeightConstraint.constant = 0
        
        
        if tweet.user?.profileImageUrl != nil {
          profileImageView.image = nil
          profileImageView.backgroundColor = UIColor.whiteColor()
          profileImageView.setImageWithURL(NSURL(string: tweet.user!.profileImageUrl!)!)
        } else {
          profileImageView.image = nil
          profileImageView.backgroundColor = tweet.user?.linkColor
        }
      }
      
      
      if tweet.createdAt != nil {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d"
        timeLabel.text = formatter.stringFromDate(tweet.createdAt!)
      } else {
        timeLabel.text = ""
      }
      
      tweetTextLabel.tintColor = User.currentUser?.linkColor //tweet.user?.linkColor
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
      
      if tweet.user?.id == User.currentUser?.id {
        retweetImageView.image = UIImage(named: "retweet-action-inactive")
      } else if tweet.isRetweeted! {
        retweetImageView.image = UIImage(named: "retweet-action-on")
      } else {
        retweetImageView.image = UIImage(named: "retweet-action")
      }
      
      
      
      tweetTextLabel.urlLinkTapHandler = { label, url, range in
        self.delegate?.tweetCell(self, didTapURL: NSURL(string: url)!)
      }
      
      tweetTextLabel.userHandleLinkTapHandler = { label, handle, range in
        self.delegate?.tweetCell(self, didTapUser: handle)
      }
      
      tweetTextLabel.hashtagLinkTapHandler = { label, hashtag, range in
        self.delegate?.tweetCell(self, didTapHashtag: hashtag)
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
    
    if tweet.user?.id == User.currentUser?.id {
      print("can't retweet your own message")
      //Can't retweet your own tweets
      return
      
    } else if tweet.isRetweeted! {
      print("un-retweet")
      
      TwitterClient.sharedInstance.unRetweetWithId(tweet.originalId!, completion: {
        (tweet, error) -> () in
        if error != nil {
          print("error retweeting: \(error!.description)")
          return
        }
        
        self.tweet.isRetweeted = false
        if tweet != nil && tweet!.retweetCount != nil {
          self.tweet.retweetCount!--
          self.retweetLabel.text = String(self.tweet!.retweetCount!)
        } else {
          self.retweetLabel.text = "0"
        }
        
        self.retweetImageView.image = UIImage(named: "retweet-action")
      })
      
    } else {
      print("retweet")
      TwitterClient.sharedInstance.retweetWithId(tweet.originalId!, completion: {
        (tweet, error) -> () in
        if error != nil {
          print("error retweeting: \(error!.description)")
          return
        }
        
        self.tweet.isRetweeted = true
        
        if tweet != nil && tweet!.retweetCount != nil {
          self.tweet.retweetCount!++
          self.retweetLabel.text = String(self.tweet!.retweetCount!)
        } else {
          self.retweetLabel.text = "0"
        }
        
        self.retweetImageView.image = UIImage(named: "retweet-action-on")
      })
      
    }
    
  }
  
  func favoriteTapped(view: AnyObject) {
    
    if !tweet.isFavorited! {
      TwitterClient.sharedInstance.favoriteWithId(tweet.id!, completion: {
        (tweet, error) -> () in
        if error != nil {
          print("error favoriting tweet: \(error!.description)")
          return
        }
        
        self.tweet.isFavorited = tweet?.isFavorited
        self.tweet.favoriteCount = tweet?.favoriteCount
        
        if tweet != nil && tweet!.favoriteCount != nil {
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
