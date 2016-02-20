
//
//  ProfilePageController.swift
//  Twitter
//
//  Created by Evan on 2/16/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

class ProfilePageController: UIViewController {
  
  @IBOutlet weak var bannerImageView: UIImageView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  @IBOutlet weak var tweetCounterLabel: UILabel!
  @IBOutlet weak var followingCountLabel: UILabel!
  @IBOutlet weak var followersCountLabel: UILabel!
  @IBOutlet weak var likesCounterLabel: UILabel!
  
  var user: User?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let user = user {
      bannerImageView.setImageWithURL(NSURL(string: user.profileBannerUrl!)!)
      profileImageView.setImageWithURL(NSURL(string: user.profileImageUrl!)!)
      nameLabel.text = user.name
      usernameLabel.text = "@" + user.screenName!
      descriptionLabel.text = user.tagline
      
      tweetCounterLabel.text = String(user.tweetCount!)
      tweetCounterLabel.textColor = user.linkColor
      followingCountLabel.text = String(user.followingCount!)
      followingCountLabel.textColor = user.linkColor
      followersCountLabel.text = String(user.followersCount!)
      followersCountLabel.textColor = user.linkColor
      likesCounterLabel.text = String(user.favoritesCount!)
      likesCounterLabel.textColor = user.linkColor
    } else {
      print("null user?")
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
