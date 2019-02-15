//
//  ViewController.swift
//  Twittermenti
//
//  Created by Aymeric Scherrer on 12/02/2019.
//  Copyright © 2019 Aymeric Scherrer. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    private let sentimentClassifier = TweetSentimentClassifier()
    private var nsDictionary: NSDictionary?
    
    // The number of tweets to fetch from Twitter
    private let tweetCount = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
    }
    
    //MARK: - Function to connect to Twitter
    
    func connectTweeter() -> Swifter? {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            
            nsDictionary = NSDictionary(contentsOfFile: path)
            
            guard let twitterConsumerKey = nsDictionary!.object(forKey: "TwitterConsumerKey") else {
                fatalError("Could not load ConsumerKey")
            }
            guard let twitterConsumerSecret = nsDictionary!.object(forKey: "TwitterConsumerSecret") else {
                fatalError("Could not load ConsumerSecret")
            }
            
            // Instantiation using Twitter's OAuth Consumer Key and secret using Config file
            return Swifter(consumerKey: twitterConsumerKey as! String, consumerSecret: twitterConsumerSecret as! String)
        }
        return nil
    }
    
    //MARK: - Function to fetch tweets
    
    func fetchTweets() {
        if let searchText = textField.text {
            
            if let swifter = connectTweeter() {
            
                swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                    
                    var tweets = [TweetSentimentClassifierInput]()
                    
                    for i in 0..<self.tweetCount {
                        if let tweet = results[i]["full_text"].string {
                            let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                            tweets.append(tweetForClassification)
                        }
                    }
                    
                    self.makePrediction(with: tweets)
                    
                }) { (error) in
                    print("There was an error with the Twitter API request, \(error)")
                }
            }
        }
    }
    
    //MARK: - Function to make prediction using CoreML 2
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for pred in predictions {
                
                let sentiment = pred.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
           
            updateUI(with: sentimentScore)
            
        } catch {
            print("There was an error making a prediction, \(error)")
        }
    }
    
    //MARK: - Update the UI using the sentiment score

    func updateUI(with sentimentScore: Int) {

        switch sentimentScore {
        case _ where sentimentScore > 20:
            sentimentLabel.text = "😍"
        case _ where sentimentScore > 10:
            sentimentLabel.text = "😀"
        case _ where sentimentScore > 0:
            sentimentLabel.text = "🙂"
        case _ where sentimentScore == 0:
            sentimentLabel.text = "😐"
        case _ where sentimentScore > -10:
            sentimentLabel.text = "😕"
        case _ where sentimentScore > -20:
            sentimentLabel.text = "😡"
        default:
            sentimentLabel.text = "🤮"
        }
    }
}
