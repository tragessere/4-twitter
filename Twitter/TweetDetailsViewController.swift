//
//  TweetDetailsViewController.swift
//  Twitter
//
//  Created by Evan on 2/14/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit
import KILabel
import SafariServices

class TweetDetailsViewController: UIViewController {
  
  @IBOutlet weak var isRetweetedViewConstraint: NSLayoutConstraint!
  @IBOutlet weak var isRetweetedImageView: UIImageView!
  @IBOutlet weak var userRetweetedLabel: UILabel!
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var tweetTextLabel: KILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var retweetCountLabel: UILabel!
  @IBOutlet weak var favoritesCountLabel: UILabel!
  

  @IBOutlet weak var retweetButton: UIButton!
  @IBOutlet weak var favoriteButton: UIButton!
  
  var tintColor: UIColor?
  var tweet: Tweet?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
//    let retweetTapRecognizer = UITapGestureRecognizer(target: self, action: "retweetTapped:")
//    retweetImageView.userInteractionEnabled = true
//    retweetImageView.addGestureRecognizer(retweetTapRecognizer)
//    
//    let favoriteTapRecognizer = UITapGestureRecognizer(target: self, action: "favoriteTapped:")
//    favoriteImageView.userInteractionEnabled = true
//    favoriteImageView.addGestureRecognizer(favoriteTapRecognizer)
    
    
    
    profileImageView.layer.cornerRadius = 5
    profileImageView.layer.masksToBounds = true
    
    if tweet == nil {
      return
    }
    
    if tweet!.tweetIsRetweet! {
      nameLabel.text = tweet!.originalUser?.name
      usernameLabel.text = "@" + tweet!.originalUser!.screenName!
      
      userRetweetedLabel.text = (tweet!.user?.name)! + " Retweeted"
      
      userRetweetedLabel.hidden = false
      isRetweetedImageView.hidden = false
      isRetweetedViewConstraint.constant = 24
      
      if tweet!.originalUser?.profileImageUrl != nil {
        profileImageView.image = nil
        profileImageView.backgroundColor = UIColor.whiteColor()
        profileImageView.setImageWithURL(NSURL(string: tweet!.originalUser!.profileImageUrl!)!)
      } else {
        profileImageView.image = nil
        profileImageView.backgroundColor = tweet!.originalUser?.linkColor
      }
      
      
    } else {  //Original Tweet
      nameLabel.text = tweet!.user?.name
      usernameLabel.text = "@" + tweet!.user!.screenName!
      
      userRetweetedLabel.hidden = true
      isRetweetedImageView.hidden = true
      isRetweetedViewConstraint.constant = 0
      
      
      if tweet!.user?.profileImageUrl != nil {
        profileImageView.image = nil
        profileImageView.backgroundColor = UIColor.whiteColor()
        profileImageView.setImageWithURL(NSURL(string: tweet!.user!.profileImageUrl!)!)
      } else {
        profileImageView.image = nil
        profileImageView.backgroundColor = tweet!.user?.linkColor
      }
    }
    
    
    if tweet!.createdAt != nil {
      let formatter = NSDateFormatter()
      formatter.dateFormat = "MMM d"
      timeLabel.text = formatter.stringFromDate(tweet!.createdAt!)
    } else {
      timeLabel.text = ""
    }
    
    if tintColor != nil {
      tweetTextLabel.tintColor = tintColor!
      retweetCountLabel.textColor = tintColor!
      favoritesCountLabel.textColor = tintColor!
    }
    if tweet!.text != nil {
      tweetTextLabel.text = tweet!.text?.stringByDecodingHTMLEntities
    }
    
    if tweet!.retweetCount != nil {
      retweetCountLabel.text = String(tweet!.retweetCount!)
    } else {
      retweetCountLabel.text = "0"
    }
    
    if tweet!.favoriteCount != nil {
      favoritesCountLabel.text = String(tweet!.favoriteCount!)
    } else {
      favoritesCountLabel.text = "0"
    }
    
    setImageButtons()
    
    
    tweetTextLabel.urlLinkTapHandler = { label, url, range in
      let svc = SFSafariViewController(URL: NSURL(string: url)!)
      self.presentViewController(svc, animated: true, completion: nil)
    }
    
    tweetTextLabel.userHandleLinkTapHandler = { label, handle, range in
      //Handle this later
    }
    
    tweetTextLabel.hashtagLinkTapHandler = { label, hashtag, range in
      //Handle this later
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    
    if segue.identifier == "barReply" || segue.identifier == "buttonReply" {
      let navController = segue.destinationViewController as! UINavigationController
      let replyController = navController.viewControllers.first as! CreateTweetViewController
      
      if tweet!.tweetIsRetweet != nil && tweet!.tweetIsRetweet! {
        replyController.user = tweet?.originalUser
        replyController.tweetId = tweet?.originalId
      } else {
        replyController.user = tweet?.user
        replyController.tweetId = tweet?.id
      }
    }
  }

  
  @IBAction func didTapRetweet(sender: AnyObject) {
    
    if tweet!.isRetweeted! {
      TwitterClient.sharedInstance.unRetweetWithId(tweet!.originalId!, completion: {
        (tweet, error) -> () in
        if error != nil {
          print("error retweeting: \(error!.description)")
          return
        }
        
        self.tweet!.isRetweeted = false
        if tweet != nil && tweet!.retweetCount != nil {
          self.tweet!.retweetCount!--
          self.retweetCountLabel.text = String(self.tweet!.retweetCount!)
        } else {
          self.retweetCountLabel.text = "0"
        }
        
        self.setImageButtons()
      })
      
    } else {
      TwitterClient.sharedInstance.retweetWithId(tweet!.originalId!, completion: {
        (tweet, error) -> () in
        if error != nil {
          print("error retweeting: \(error!.description)")
          return
        }
        
        self.tweet!.isRetweeted = true
        
        if tweet != nil && tweet!.retweetCount != nil {
          self.tweet!.retweetCount!++
          self.retweetCountLabel.text = String(self.tweet!.retweetCount!)
        } else {
          self.retweetCountLabel.text = "0"
        }
        
        self.setImageButtons()
      })
    }

  }
  
  @IBAction func didTapFavorite(sender: AnyObject) {
    
    if !tweet!.isFavorited! {
      TwitterClient.sharedInstance.favoriteWithId(tweet!.id!, completion: {
        (tweet, error) -> () in
        if error != nil {
          print("error favoriting tweet: \(error!.description)")
          return
        }
        
        self.tweet!.isFavorited = tweet?.isFavorited
        self.tweet!.favoriteCount = tweet?.favoriteCount
        
        if tweet != nil && tweet!.favoriteCount != nil {
          self.favoritesCountLabel.text = String(tweet!.favoriteCount!)
        } else {
          self.favoritesCountLabel.text = "0"
        }
        
        self.setImageButtons()
      })
    }
      
    else {
      TwitterClient.sharedInstance.unFavoriteWithId(tweet!.id!, completion: {
        (tweet, error) -> () in
        if error != nil {
          print("error un-favoriting tweet: \(error!.description)")
          return
        }
        
        self.tweet!.isFavorited = tweet?.isFavorited
        self.tweet!.favoriteCount = tweet?.favoriteCount
        
        if tweet!.favoriteCount != nil {
          self.favoritesCountLabel.text = String(tweet!.favoriteCount!)
        } else {
          self.favoritesCountLabel.text = "0"
        }
        
        self.setImageButtons()
      })
    }
  }
  
  func setImageButtons() {
    if tweet == nil {
      favoriteButton.enabled = false
    } else if tweet!.isFavorited! {
      favoriteButton.setImage(UIImage(named: "like-action-on"), forState: UIControlState.Normal)
      favoriteButton.setImage(UIImage(named: "like-action-on-pressed"), forState: UIControlState.Highlighted)
    } else {
      favoriteButton.setImage(UIImage(named: "like-action"), forState: UIControlState.Normal)
      favoriteButton.setImage(UIImage(named: "like-action-pressed"), forState: UIControlState.Highlighted)
    }
    
    if tweet == nil || tweet!.user?.id == User.currentUser?.id {
      retweetButton.enabled = false
    } else if tweet!.isRetweeted! {
      retweetButton.enabled = true
      retweetButton.setImage(UIImage(named: "retweet-action-on"), forState: UIControlState.Normal)
      retweetButton.setImage(UIImage(named: "retweet-action-on-pressed"), forState: UIControlState.Highlighted)
    } else {
      retweetButton.enabled = true
      retweetButton.setImage(UIImage(named: "retweet-action"), forState: UIControlState.Normal)
      retweetButton.setImage(UIImage(named: "retweet-action-pressed"), forState: UIControlState.Highlighted)
    }
  }
  
}

extension TweetDetailsViewController: SFSafariViewControllerDelegate {
  func safariViewControllerDidFinish(controller: SFSafariViewController) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }
}
