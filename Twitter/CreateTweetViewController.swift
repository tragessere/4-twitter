//
//  CreateTweetViewController.swift
//  Twitter
//
//  Created by Evan on 2/15/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit
import SAMTextView

class CreateTweetViewController: UIViewController {
  @IBOutlet weak var replyToHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  
  @IBOutlet weak var tweetHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var tweetBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var tweetTextView: SAMTextView!
  @IBOutlet weak var characterCountLabel: UILabel!
  
  var user: User?
  var tweetId: Int64?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tweetTextView.placeholder = "Type your tweet..."
    tweetTextView.tintColor = UIColor(red: 0.3333, green: 0.6745, blue: 0.9333, alpha: 1)
    tweetTextView.delegate = self
    
    if user != nil {
      self.navigationItem.title = "Reply"
      
      profileImageView.backgroundColor = user!.linkColor
      if user?.profileImageUrl != nil {
        profileImageView.setImageWithURL(NSURL(string: user!.profileImageUrl!)!)
      }
      
      tweetTextView.text = "@" + user!.screenName! + " "
      
      nameLabel.text = user?.name
      usernameLabel.text = "@" + user!.screenName!
      
    } else {
      replyToHeightConstraint.constant = 0
      profileImageView.hidden = true
      nameLabel.hidden = true
      usernameLabel.hidden = true
    }
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
    
    
    tweetTextView.becomeFirstResponder()
  }
  
  func keyboardWillAppear(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
        tweetBottomConstraint.constant = keyboardSize.height + 12
      }
    }
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func didCancel(sender: AnyObject) {
    tweetTextView.resignFirstResponder()
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func didSubmit(sender: AnyObject) {
    if tweetTextView.text.isEmpty {
      return
    }
    
    TwitterClient.sharedInstance.postTweet(tweetTextView.text, replyToId: tweetId, completion: {
      (tweet, error) -> () in
      if error != nil {
        print("error: \(error)")
        return
      }
      
      //Add a delegate to save new tweet
      self.tweetTextView.resignFirstResponder()
      self.dismissViewControllerAnimated(true, completion: nil)
    })
  }
}


extension CreateTweetViewController: UITextViewDelegate {
  func textViewDidChange(textView: UITextView) {
    characterCountLabel.text = String(140 - textView.text.characters.count)
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    let currentCharacterCount = textView.text.characters.count ?? 0
    
    if (range.length + range.location > currentCharacterCount) {
      return false
    }
    let newLength = currentCharacterCount + text.characters.count - range.length
    return newLength <= 140
  }
}
