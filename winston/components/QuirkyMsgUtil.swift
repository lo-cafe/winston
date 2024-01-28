//
//  Quirky Msg Util.swift
//  winston
//
//  Created by Ethan Bills on 1/11/24.
//

import Foundation

class QuirkyMessageUtil {
  static func quirkyEndOfFeed() -> String {
    let quirkyResponses = [
      "You've reached the end of the feed! Congrats!",
      "Wow, you made it to the bottom! 👏",
      "You're a feed-finishing champion! ✨",
      "I'm impressed! You've conquered the feed! 🏆",
      "You're a true feed explorer! 🌎",
      "You've reached the end of the road... for now. 😉",
      "Stay tuned for more feed adventures! 🚀",
      "Don't worry, there's always more feed to discover. 🔍",
      "You've reached the end of the feed, but your journey continues. ♾️",
      "The feed may be over, but your curiosity never ends. 💡",
      "Be excellent to each other!",
      "Maybe it’s time to go outside?",
      "Meow meow, you reached the bottom or something, meow meow meow",
      "That's enough internet for today... (pls come back)",
      "You've made it to the bottom! Now go touch grass!",
      "AAAAAAAAAAH! It's the end of the feed!!!",
      "Frostplexx wuz h3re, at the end of the feed.",
      "RIP Apollo!",
      "...this is awkward. You are at the end!",
      "You’ve read all of Reddit. Does that make you feel good about yourself?",
      "Sorry Mario, your post is in another castle.",
      "It’s dangerous to go alone, take another post!"
    ]

    return quirkyResponses.randomElement() ?? "End of feed."
  }

  static func quirkyGoAwayMessage() -> String {
    let quirkyResponse = [
      "You've discovered the void of nothingness.",
      "No secrets here, just pixels and bytes.",
      "This is not the tap you're looking for.",
      "Go away, or I will taunt you a second time!",
      "The more you tap, the less you find. Strange, isn't it?",
      "The secret is a lie."
    ]

    return quirkyResponse.randomElement() ?? "Go away!"
  }
  
  static func noCommentsFoundMessage() -> String {
    let quirkyResponse = [
      "No comments here! It's like a comment desert.",
      "This is a comment-free zone. Try a different post.",
      "Comment not found. Maybe it's taking a nap?",
      "Oops, looks like the comment section is on vacation.",
      "The comments seem to be playing hide and seek. Can you find them?",
      "Zero comments detected. Must be a stealthy post.",
      "No comments in sight! Must be a commentless masterpiece.",
      "The comment elves are on break. Please enjoy the silence.",
    ]
    
    return quirkyResponse.randomElement() ?? "No comments found. Maybe they're on strike!"
  }

}
