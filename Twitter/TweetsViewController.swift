
//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Evan on 2/7/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit
import SafariServices

class TweetsViewController: UIViewController {
  
  @IBOutlet var tableView: UITableView!
  var tweets: [Tweet]?
//  var refreshControl: UIRefreshControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 130
    
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    tableView.insertSubview(refreshControl, atIndex: 0)
    
    refresh(refreshControl)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func refresh(refreshControl: UIRefreshControl) {
    
    TwitterClient.sharedInstance.homeTimeLineWithParams(nil) { (
      tweets, error) -> () in
      self.tweets = tweets
      self.tableView.reloadData()
      refreshControl.endRefreshing()
    }
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
  @IBAction func onLogout(sender: AnyObject) {
    User.currentUser?.logout()
  }
}

extension TweetsViewController: UITableViewDelegate, UITableViewDataSource, TweetCellDelegate, SFSafariViewControllerDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tweets == nil {
      return 0
    } else {
      return tweets!.count
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
    
    cell.tweet = tweets![indexPath.row]
    cell.delegate = self
    
    return cell
  }
  
  func tweetCell(cell: TweetCell, didTapURL url: NSURL) {
    let svc = SFSafariViewController(URL: url)
    presentViewController(svc, animated: true, completion: nil)
  }
  
  func tweetCell(cell: TweetCell, didTapUser username: String) {
    //Figure this out later
  }
  
  func tweetCell(cell: TweetCell, didTapHashtag hashtag: String) {
    //Figure this out later
  }
  
  func safariViewControllerDidFinish(controller: SFSafariViewController) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
