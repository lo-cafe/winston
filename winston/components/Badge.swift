//
//  Badge.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import Foundation
import SwiftUI
import Defaults


struct Badge: View {
  var saved = false
  var usernameColor: Color = .green
  var showAvatar = true
  var author: String
  var fullname: String? = nil
  var created: Double
  var avatarURL: String?
  var avatarSize: CGFloat = 30
  var nameSize: CGFloat = 13
  var labelSize: CGFloat = 12
  //  var extraInfo: [String:String] = [:]
  var extraInfo: [BadgeExtraInfo] = []
  @EnvironmentObject private var routerProxy: RouterProxy
  @EnvironmentObject private var redditAPI: RedditAPI
  let flagY: CGFloat = 16
  let delay: CGFloat = 0.4
  var body: some View {
    HStack(spacing: 5) {
      
      if saved && !showAvatar {
        Image(systemName: "bookmark.fill")
          .fontSize(16)
          .foregroundColor(.green)
          .transition(.scale.combined(with: .opacity))
      }
      
      if showAvatar {
        ZStack {
          Avatar(url: avatarURL, userID: author, fullname: fullname, avatarSize: avatarSize)
            .background(
              ZStack {
                Image(systemName: "bookmark.fill")
                  .foregroundColor(.green)
                  .offset(y: saved ? flagY : 0)
                
                Circle()
                  .fill(.gray)
                  .performantShadow(cornerRadius: 15, color: .black, opacity: 0.15, radius: 4, offsetY: 4, size: CGSize(width: 30, height: 30))
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .mask(
                    Image(systemName: "bookmark.fill")
                      .foregroundColor(.black)
                      .offset(y: saved ? flagY : 0)
                  )
                
                Circle()
                  .fill(.gray)
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
              }
                .compositingGroup()
                .animation(.interpolatingSpring(stiffness: 150, damping: 12).delay(delay), value: saved)
            )
            .scaleEffect(1)
            .onTapGesture {
              routerProxy.router.path.append(User(id: author, api: redditAPI))
            }
        }
      }
      
      VStack(alignment: .leading) {
        
        Text(author).font(.system(size: nameSize, weight: .semibold)).foregroundColor(author == "[deleted]" ? .red : usernameColor)
          .onTapGesture {
            routerProxy.router.path.append(User(id: author, api: redditAPI))
          }
        
        HStack(alignment: .center, spacing: 6) {
          ForEach(extraInfo, id: \.self){ elem in
            HStack(alignment: .center, spacing: 2){
              Image(systemName: elem.systemImage)
                .foregroundColor(elem.iconColor)
              Text(elem.text)
                .foregroundStyle(elem.textColor)
            }
          }
          
          HStack(alignment: .center, spacing: 2) {
            Image(systemName: "hourglass.bottomhalf.filled")
            Text(timeSince(Int(created)))
          }
        }
        .font(.system(size: labelSize, weight: .medium))
        .compositingGroup()
        .opacity(0.5)
      }
    }
    .scaleEffect(1)
    .animation(showAvatar ? nil : spring.delay(delay), value: saved)
  }
}

struct BadgeExtraInfo: Hashable{
  var systemImage: String = ""
  var text: String
  var textColor: Color = Color.primary
  var iconColor: Color = Color.primary
}


struct PresetBadgeExtraInfo{
  
  init(){}
  
  func upvotesExtraInfo(data: PostData) -> BadgeExtraInfo{
    //    let upvoted = data.likes != nil && data.likes!
    //    let downvoted = data.likes != nil && !data.likes!
    //    return BadgeExtraInfo(systemImage: upvoted  ? "arrow.up" : (downvoted ? "arrow.down" : "arrow.up"), text: "\(formatBigNumber(data.ups))",textColor: upvoted ? .orange : (downvoted ? .blue : .primary), iconColor:  upvoted ? .orange : (downvoted ? .blue : .primary))
    return BadgeExtraInfo(systemImage: "arrow.up", text: "\(formatBigNumber(data.ups))")
  }
  
  func commentsExtraInfo(data: PostData) -> BadgeExtraInfo{
    return BadgeExtraInfo(systemImage: "message.fill", text: "\(formatBigNumber(data.num_comments))")
  }
  
}
