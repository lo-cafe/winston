//
//  Badge.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import Foundation
import SwiftUI
import Defaults
import NukeUI

struct UserFlair: View, Equatable {
  static func == (lhs: UserFlair, rhs: UserFlair) -> Bool {
    return lhs.flair == rhs.flair && lhs.flairText == rhs.flairText && lhs.flairBackground == rhs.flairBackground
  }
  
  let flair: String
  let flairText: ThemeText
  let flairBackground: ColorSchemes<ThemeColor>
  
  var body: some View {
    Text(flair).font(.system(size: flairText.size, weight: flairText.weight.t))
      .lineLimit(1)
      .foregroundColor(flairText.color())
      .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
      .background(flairBackground())
      .cornerRadius(4.0)
      .allowsHitTesting(false)
  }
}

struct BadgeKit: Equatable {
  let numComments: Int
  let ups: Int
  let saved: Bool
  let author: String
  let authorFullname: String
  let userFlair: String
  let created: Double
}

func flairWithoutEmojis(str: String?) -> [String]? {
  do {
    let emojiRegex = try NSRegularExpression(pattern: ":(.*?):")
    if let s = str {
      let sep = "<separator>"
      return emojiRegex.stringByReplacingMatches(in: s, range: NSMakeRange(0, s.count), withTemplate: sep)
        .components(separatedBy: sep).map{ str in
          return str.replacingOccurrences(of: sep, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { str in
          return !str.isEmpty
        }
    } else {
      return nil
    }
  } catch {
    return nil
  }
}

struct BadgeView: View, Equatable {
  static let authorStatsSpacing: Double = 2
  static func == (lhs: BadgeView, rhs: BadgeView) -> Bool {
    return lhs.avatarURL == rhs.avatarURL && lhs.saved == rhs.saved && lhs.avatarRequest?.url == rhs.avatarRequest?.url && lhs.theme == rhs.theme && lhs.commentsCount == rhs.commentsCount && lhs.newCommentsCount == rhs.newCommentsCount && lhs.votesCount == rhs.votesCount && lhs.likes == rhs.likes
  }
  
  var avatarRequest: ImageRequest?
  var showAuthorOnPostLinks = true
  var saved = false
  var unseen = false
  var usernameColor: Color?
  var author: String
  var fullname: String? = nil
  var userFlair: String?
  var created: Double
  var avatarURL: String?
  var theme: BadgeTheme
  var commentTheme: CommentTheme?
  var commentsCount: String?
  var newCommentsCount: Int?
  var votesCount: String?
  var likes: Bool? = nil
  var openSub: (() -> ())? = nil
  var subName: String? = nil
    
  nonisolated func openUser() {
    Nav.to(.reddit(.user(User(id: author))))
  }
  
  var body: some View {
    let showAvatar = theme.avatar.visible
    let defaultIconColor = theme.statsText.color()
    HStack(spacing: theme.spacing) {
      
      if saved && !showAvatar {
        Image(systemName: "bookmark.fill")
          .fontSize(16)
          .foregroundColor(.green)
          .transition(.scale.combined(with: .opacity))
          .drawingGroup()
      }
      
      if showAvatar {
        AvatarView(saved: saved, avatarImgRequest: avatarRequest, userID: author, fullname: fullname, theme: theme.avatar)
//          .equatable()
          .highPriorityGesture(TapGesture().onEnded(openUser))
      }
      
      VStack(alignment: .leading, spacing: BadgeView.authorStatsSpacing) {
        
        if showAuthorOnPostLinks {
          HStack(alignment: .center, spacing: 4) {
            
            Text(author).font(.system(size: theme.authorText.size, weight: theme.authorText.weight.t)).foregroundStyle(author == "[deleted]" ? .red : usernameColor ?? theme.authorText.color()).lineLimit(1)
              .onTapGesture(perform: openUser)
            
            if unseen {
              PostLinkGlowDot(unseenType: .dot(commentTheme?.unseenDot ?? ColorSchemes<ThemeColor>(light: .init(hex: "FF0000"), dark: .init(hex: "FF0000"))), seen: false, badge: true).equatable()
            }
            
            if let flairs = flairWithoutEmojis(str: userFlair) {
              // TODO Load flair emojis via GET /api/v1/{subreddit}/emojis/{emoji_name}
              ForEach(flairs, id: \.self) {
                UserFlair(flair: $0, flairText: theme.flairText, flairBackground: theme.flairBackground).equatable()
              }
            }
            
            if let openSub = openSub, let subName = subName {
              if theme.forceSubsAsTags {
                Tag(subredditIconKit: nil, text: "r/\(subName)", color: theme.subColor(), fontSize: theme.authorText.size, backgroundColor: theme.subColor())
                .onTapGesture(perform: openSub)
              } else {
                Image(systemName: "arrowshape.right.fill")
                  .fontSize(theme.authorText.size * 0.75)
                  .foregroundStyle(theme.authorText.color().opacity(0.5))
                Text(subName).foregroundStyle(theme.subColor())
                  .fontSize(theme.authorText.size, .semibold).lineLimit(1)
                  .highPriorityGesture(TapGesture().onEnded(openSub))
              }
            }
          }
        }
        
        
        HStack(alignment: .center, spacing: theme.statsText.size * 0.41) {
          
          if let openSub = openSub, let subName = subName, !showAuthorOnPostLinks {
            Tag(subredditIconKit: nil, text: "r/\(subName)", color: theme.subColor(), fontSize: theme.statsText.size, backgroundColor: theme.subColor())
              .highPriorityGesture(TapGesture().onEnded(openSub))
          }
          
          if let commentsCount = commentsCount {
            HStack(alignment: .center, spacing: 2) {
              Image(systemName: "message.fill")
              Text(commentsCount).contentTransition(.numericText())
            }
          }
          
          if let newComments = newCommentsCount {
            if newComments > 0 {
              Text("(\(newComments))").foregroundColor(.accentColor)
            }
          }
          
          if let votesCount = votesCount {
            HStack(alignment: .center, spacing: 2) {
              Image(systemName: "arrow.up")
              Text(votesCount).contentTransition(.numericText())
            }
            .foregroundStyle(likes == nil ? defaultIconColor : likes == true ? .orange : .blue)
          }
          
          HStack(alignment: .center, spacing: 2) {
            Image(systemName: "hourglass.bottomhalf.filled")
            Text(timeSince(Int(created)))
          }
          
        }
        .foregroundStyle(defaultIconColor)
        .font(.system(size: theme.statsText.size, weight: theme.statsText.weight.t))
      }
//      .drawingGroup()
    }
    .scaleEffect(1)
    .animation(showAvatar ? nil : spring.delay(0.4), value: saved)
  }
}

struct Badge: View {
  var showVotes = false
  var post: Post
  var usernameColor: Color?
  var avatarURL: String?
  var theme: BadgeTheme
  //  var extraInfo: [BadgeExtraInfo] = []
  
  
  var body: some View {
    if let data = post.data {
      BadgeView(saved: data.saved, usernameColor: usernameColor, author: data.author, fullname: data.author_fullname, userFlair: data.author_flair_text, created: data.created, avatarURL: avatarURL, theme: theme, commentsCount: formatBigNumber(data.num_comments), votesCount: !showVotes ? nil : formatBigNumber(data.ups))
    }
  }
}

struct BadgeOpt: View, Equatable {
  static func == (lhs: BadgeOpt, rhs: BadgeOpt) -> Bool {
    return lhs.badgeKit == rhs.badgeKit && lhs.theme == rhs.theme && lhs.avatarRequest?.url == rhs.avatarRequest?.url
  }
  
  var avatarRequest: ImageRequest?
  let badgeKit: BadgeKit
  var showVotes = false
  var usernameColor: Color?
  var avatarURL: String?
  var theme: BadgeTheme
  var openSub: (() -> ())? = nil
  var subName: String? = nil
  
  var body: some View {
      BadgeView(avatarRequest: avatarRequest, saved: badgeKit.saved, usernameColor: usernameColor, author: badgeKit.author, fullname: badgeKit.authorFullname, userFlair: badgeKit.userFlair, created: badgeKit.created, avatarURL: avatarURL, theme: theme, commentsCount: formatBigNumber(badgeKit.numComments), votesCount: !showVotes ? nil : formatBigNumber(badgeKit.ups), openSub: openSub, subName: subName)
  }
}

struct BadgeExtraInfo: Hashable, Equatable, Identifiable {
  static func == (lhs: BadgeExtraInfo, rhs: BadgeExtraInfo) -> Bool {
    lhs.id == rhs.id
  }
  var systemImage: String = ""
  var text: String
  //    var textColor: Color = Color.primary
  var iconColor: Color?
  var id: String {
    systemImage + text
  }
}
