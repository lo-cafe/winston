//
//  EndOfFeedView.swift
//  winston
//
//  Created by Ethan Bills on 11/21/23.
//

import SwiftUI

struct EndOfFeedView: View {
  @State private var tapCount = 0
  @State private var showAlert = false

  var body: some View {
    ZStack {
      Image("winstonEOF")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .onTapGesture {
          self.handleTap()
        }

      Text(quirkyEndOfFeed())
        .font(.system(size: 16, weight: .bold))
        .foregroundColor(.white)
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
        .multilineTextAlignment(.center)
        .offset(y: 20)
        .lineLimit(4)
        .onTapGesture {
          self.handleTap()
        }
    }
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("Secrets Unveiled"),
        message: Text(quirkyGoAwayMessage()),
        dismissButton: .default(Text("OK"))
      )
    }
  }

  private func handleTap() {
    tapCount += 1

    if tapCount >= 5 {
      showAlert = true
      tapCount = 0
    }
  }
}


func quirkyEndOfFeed() -> String {
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
    "It’s dangerous to go alone, take another post!",
    "𓏏𓉔𓅂 𓅂𓄿𓂋𓏏𓉔 𓅃𓇋𓃭 𓅂𓈖𓂧 𓅱𓈖 𓏏𓉔𓅂 𓏏𓅃𓅂𓈖𓏏𓇌-𓆑𓇋𓆑𓏏𓉔 𓅱𓆑 𓅓𓄿𓂋𓎢𓉔 𓏏𓅃𓅂𓈖𓏏𓇌 𓄿𓈖𓂧 𓏏𓉔𓇋𓂋𓏏𓇌𓏏𓅃𓅱 ",
    ".. -- ....... - .-. .- .--. .--. . -.. ....... .. -. ....... -.-- --- ..- .-. ....... .-- .- .-.. .-.. ...",
    "Si vis pacem, para bellum",
    "My name is Ozymandias, king of kings: Look on my works, ye Mighty, and despair!",
    "If a can of Alpo costs 38 cents, would it cost $2.50 in Dog Dollars?",
    "A person with one watch knows what time it is; a person with two watches is never sure.",
    "Beer & Pretzels -- Breakfast of Champions.",
    "Neutrinos are into physicists.",
    "HOW YOU CAN TELL THAT IT'S GOING TO BE A ROTTEN DAY: #15 Your pet rock snaps at you.",
    "Pyros of the world... IGNITE !!!",
    "If God didn't mean for us to juggle, tennis balls wouldn't come three to a can.",
    "The difference between this place and yogurt is that yogurt has a live culture."
  ]

  return quirkyResponses.randomElement() ?? "End of feed."
}

private func quirkyGoAwayMessage() -> String {
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
