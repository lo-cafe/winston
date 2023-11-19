//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 09/09/23.
//

import Foundation

let SAMPLE_USER_AVATAR = "t2_winston_sample"

let postSampleData = PostData(subreddit: "Apple", selftext: "Winston is simply the best app to ever exist. Other apps bow down before it's greatness.", author_fullname: SAMPLE_USER_AVATAR, saved: false, gilded: 0, clicked: false, title: "Winston won as the best app in the universe", subreddit_name_prefixed: "r/Apple", hidden: false, ups: 453, downs: 0, hide_score: false, name: "aksm88dn", quarantine: false, upvote_ratio: 1.0, subreddit_type: "public", total_awards_received: 0, is_self: false, created: Date().timeIntervalSince1970 - 115200, domain: "", allow_live_comments: false, id: "fake-post", is_robot_indexable: false, author: "Winston", num_comments: 42, send_replies: false, contest_mode: false, permalink: "", url: "https://winston.cafe/tim-cook-hugging-winston.jpg", subreddit_subscribers: 1263, num_crossposts: 0, link_flair_text: "⭐ Amazing News", winstonSeen: false)

let emptyPostData = PostData(subreddit: "", selftext: "", author_fullname: "t2_winston_empty_sample", saved: false, gilded: 0, clicked: false, title: "", subreddit_name_prefixed: "", hidden: false, ups: 0, downs: 0, hide_score: false, name: "akwmdm8", quarantine: false, upvote_ratio: 1.0, subreddit_type: "public", total_awards_received: 0, is_self: false, created: Date().timeIntervalSince1970 - 115200, domain: "", allow_live_comments: false, id: "placeholder-post", is_robot_indexable: false, author: "", num_comments: 42, send_replies: false, contest_mode: false, permalink: "", url: "https://google.com", subreddit_subscribers: 1263, num_crossposts: 0, link_flair_text: "", winstonSeen: false)

let selfPostSampleData = PostData(subreddit: "Apple", selftext: "Winston is simply the best app to ever exist. Other apps bow down before it's greatness.  Besides, who wouldn't use a cute reddit client with a cute cat for the icon.", author_fullname: "t2_winston_sample", saved: false, gilded: 0, clicked: false, title: "Winston won as the best app in the universe", subreddit_name_prefixed: "r/Apple", hidden: false, ups: 453, downs: 0, hide_score: false, name: "aksm88dn", quarantine: false, upvote_ratio: 1.0, subreddit_type: "public", total_awards_received: 0, is_self: false, created: Date().timeIntervalSince1970 - 115200, domain: "", allow_live_comments: false, id: "fake-post", is_robot_indexable: false, author: "Winston", num_comments: 42, send_replies: false, contest_mode: false, permalink: "", url: "https://google.com", subreddit_subscribers: 1263, num_crossposts: 0, link_flair_text: "⭐ Amazing News", winstonSeen: false)

//let postSample = Post(data: postSampleData, api: RedditAPI.shared)
