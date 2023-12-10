//
//  getPostContentWidth.swift
//  winston
//
//  Created by Igor Marcossi on 24/09/23.
//

import Foundation
import SwiftUI
import Defaults

func getPostContentWidth(contentWidth: Double = UIScreen.screenWidth, secondary: Bool = false, theme: WinstonTheme? = nil) -> CGFloat {
  let selectedTheme = theme ?? getEnabledTheme()
  let theme = selectedTheme.postLinks.theme
  var value: CGFloat = 0
  if IPAD {
    value = (contentWidth / 2) - ((theme.innerPadding.horizontal * (secondary ? 2 : 1)) * 2) - 24
  } else {
    value = contentWidth - (((theme.innerPadding.horizontal * (secondary ? 2 : 1)) + theme.outerHPadding) * 2)
  }
  return value
}

struct PostDimensions: Hashable, Equatable {
  static var zero: PostDimensions {
    PostDimensions(contentWidth: 0, titleSize: .zero, dividerSize: .zero, badgeSize: .zero, spacingHeight: 0)
  }
  let contentWidth: Double
  let titleSize: CGSize
  var bodySize: CGSize? = nil
  var urlTagHeight: Double? = nil
  var mediaSize: CGSize? = nil
  var dividerSize: CGSize? = nil
  var badgeSize: CGSize
  var spacingHeight: Double
  var padding: CGSize { self.theme.innerPadding.toSize() }
  var theme: PostLinkTheme
  var compact: Bool
  var size: CGSize {
    let tagHeight = urlTagHeight == nil ? 0 : (self.spacingHeight / 2) + (self.urlTagHeight ?? 0)
    let compactHeight = max(self.titleSize.height + self.spacingHeight + self.badgeSize.height + tagHeight, (mediaSize?.height ?? 0))
    let normalHeight = self.titleSize.height + (self.bodySize?.height ?? 0) + (self.mediaSize?.height ?? 0) + (self.dividerSize?.height ?? 00) + self.badgeSize.height + self.spacingHeight
    return CGSize(
      width: self.contentWidth + (self.padding.width * 2),
      height: (self.compact ? compactHeight : normalHeight) + (self.padding.height * 2)
    )
  }
  
  init(contentWidth: Double, compact: Bool? = nil, theme: PostLinkTheme? = nil, titleSize: CGSize, bodySize: CGSize? = nil, urlTagHeight: Double? = nil, mediaSize: CGSize? = nil, dividerSize: CGSize? = nil, badgeSize: CGSize, spacingHeight: Double) {
    self.contentWidth = contentWidth
    self.compact = compact ?? Defaults[.compactMode]
    self.theme = theme ?? getEnabledTheme().postLinks.theme
    self.titleSize = titleSize
    self.bodySize = bodySize
    self.urlTagHeight = urlTagHeight
    self.mediaSize = mediaSize
    self.dividerSize = dividerSize
    self.badgeSize = badgeSize
    self.spacingHeight = spacingHeight
  }
}

func getPostDimensions(post: Post, winstonData: PostWinstonData? = nil, columnWidth: Double = UIScreen.screenWidth, secondary: Bool = false, rawTheme: WinstonTheme? = nil, compact: Bool? = nil, subId: String? = nil) -> PostDimensions {
  if let data = post.data {
    let selectedTheme = rawTheme ?? getEnabledTheme()
    let showSelfPostThumbnails = Defaults[.showSelfPostThumbnails]
    let compact = compact ?? Defaults[.compactPerSubreddit][subId ?? data.subreddit_id ?? ""] ?? Defaults[.compactMode]
    let showAuthorOnPostLinks = Defaults[.showAuthorOnPostLinks]
    let maxDefaultHeight: CGFloat = Defaults[.maxPostLinkImageHeightPercentage]
    let maxHeight: CGFloat = (maxDefaultHeight / 100) * (UIScreen.screenHeight)
    let extractedMedia = compact ? winstonData?.extractedMedia : winstonData?.extractedMediaForcedNormal
    let compactImgSize = scaledCompactModeThumbSize()
    let theme = selectedTheme.postLinks.theme
    let postGeneralSpacing = theme.verticalElementsSpacing + theme.linespacing
    let title = data.title
    let body = data.selftext
    
    var ACC_titleHeight: Double = 0
    var ACC_bodyHeight: Double = 0
    
    var contentWidth: CGFloat = 0
    if IPAD {
      contentWidth = (columnWidth / 2) - ((theme.innerPadding.horizontal * (secondary ? 2 : 1)) * 2) - 24
    } else {
      contentWidth = columnWidth - (((theme.innerPadding.horizontal * (secondary ? 2 : 1)) + theme.outerHPadding) * 2)
    }
    
    var ACC_mediaSize: CGSize = .zero
    let compactMediaSize = CGSize(width: compactImgSize, height: compactImgSize)
    
    var urlTagHeight: Double? = nil
    if compact { ACC_mediaSize = extractedMedia != nil || showSelfPostThumbnails ? compactMediaSize : .zero } else {
      if let extractedMedia = extractedMedia {
        func defaultMediaSize(_ size: CGSize) -> CGSize {
          let sourceHeight = size.height == 0 ? winstonData?.postDimensions.mediaSize?.height ?? 0 : size.height
          let sourceWidth = size.width == 0 ? winstonData?.postDimensions.mediaSize?.width ?? 0 : size.width
          let propHeight = (contentWidth * sourceHeight) / (sourceWidth == 0 ? 1 : sourceWidth)
          let finalHeight = maxDefaultHeight != 110 ? Double(min(maxHeight, propHeight)) : Double(propHeight)
          return CGSize(width: contentWidth, height: finalHeight)
        }
        
        switch extractedMedia {
        case .imgs(let mediaExtracted):
          if mediaExtracted.count == 1 {
            ACC_mediaSize = defaultMediaSize(mediaExtracted[0].size)
          } else if mediaExtracted.count > 1 {
            let size = ((contentWidth - 8) / 2)
            ACC_mediaSize = mediaExtracted.count == 2 ? CGSize(width: contentWidth, height: size) : CGSize(width: contentWidth, height: (size * 2) + ImageMediaPost.gallerySpacing)
          }
        case .video(let video):
          ACC_mediaSize = defaultMediaSize(video.size)
        case .streamable(_):
          ACC_mediaSize = CGSize(width: contentWidth, height: 100)
        case .yt(let ytMediaExtracted):
          let size = ytMediaExtracted.size
          let actualHeight = (contentWidth * CGFloat(size.height)) / CGFloat(size.width)
          ACC_mediaSize = CGSize(width: contentWidth, height: actualHeight)
        case .link(_):
          ACC_mediaSize = CGSize(width: contentWidth, height: PreviewLinkContentRaw.height)
        case .repost(let repost):
          if let repostSize = repost.winstonData?.postDimensions { ACC_mediaSize = repostSize.size }
        case .post(_):
          ACC_mediaSize = CGSize(width: contentWidth, height: RedditMediaPost.height)
        case .comment(_):
          ACC_mediaSize = CGSize(width: contentWidth, height: RedditMediaPost.height)
        case .subreddit(_):
          ACC_mediaSize = CGSize(width: contentWidth, height: RedditMediaPost.height)
        case .user(_):
          ACC_mediaSize = CGSize(width: contentWidth, height: RedditMediaPost.height)
        }
      }
    }
    
    if let extractedMedia = extractedMedia {
      switch extractedMedia {
      case .link(_), .post(_), .comment(_), .subreddit(_), .user(_):
        urlTagHeight = OnlyURL.height
      default:
        break
      }
    }
    
    let compactTitleWidth = postGeneralSpacing + VotesCluster.verticalWidth + postGeneralSpacing + compactMediaSize.width
    
    let titleContentWidth = contentWidth - (compact ? compactTitleWidth : 0)
    
    var appendStr = ""
    let titleAttr = NSMutableAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: theme.titleText.size + 0.35, weight: theme.titleText.weight.ut)])
    let titleAttrBlankSpace = NSAttributedString(string: " ", attributes: [.font: UIFont.systemFont(ofSize: theme.titleText.size + 0.35, weight: theme.titleText.weight.ut)])
    if data.over_18 ?? false {
      titleAttr.append(titleAttrBlankSpace)
      appendStr += "NSFW"
    }
    if let flair = data.link_flair_text, !flair.isEmpty {
      titleAttr.append(titleAttrBlankSpace)
      appendStr += flair
    }
    let append = NSMutableAttributedString(string: appendStr, attributes: [.font: UIFont.systemFont(ofSize: ((theme.titleText.size - 1) * 100) / 120, weight: theme.titleText.weight.ut)])
    if !appendStr.isEmpty {
      titleAttr.append(append)
      titleAttr.append(titleAttrBlankSpace)
    }
    ACC_titleHeight = round(titleAttr.boundingRect(with: CGSize(width: titleContentWidth, height: .infinity), options: [.usesLineFragmentOrigin], context: nil).height)
    
    if !body.isEmpty && !compact {
      ACC_bodyHeight = round(NSString(string: body).boundingRect(with: CGSize(width: contentWidth, height: (theme.bodyText.size * 1.2) * 3), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], attributes: [.font: UIFont.systemFont(ofSize: theme.bodyText.size, weight: theme.bodyText.weight.ut)], context: nil).height)
    }
    
    
    
    ACC_mediaSize.width = round(ACC_mediaSize.width)
    ACC_mediaSize.height = round(ACC_mediaSize.height)
    
    let ACC_SubDividerHeight = SubsNStuffLine.height
    
    let badgeAvatarHeight = theme.badge.avatar.visible ? theme.badge.avatar.size : 0
    let badgeAuthorHeight = theme.badge.authorText.size * 1.2
    let badgeStatsFontHeight = theme.badge.statsText.size * 1.2
    let badgeAuthorStatsSpacing = BadgeView.authorStatsSpacing
    
    let ACC_badgeHeight = round(max(badgeAvatarHeight, (showAuthorOnPostLinks ? badgeAuthorHeight + badgeAuthorStatsSpacing : 0) + badgeStatsFontHeight))
    
    
    
    let theresTitle = true
    let theresSelftext = !compact && !data.selftext.isEmpty
    let theresMedia = extractedMedia != nil
    let theresSubDivider = !compact && theme.showDivider
    let theresBadge = true
    let elements = [theresTitle, theresSelftext, !compact && theresMedia, theresSubDivider, theresBadge]
    let ACC_allSpacingsHeight = Double(elements.filter { $0 }.count - 1) * postGeneralSpacing
    
    //    let ACC_verticalPadding = theme.innerPadding.vertical * 2
    
    //    let totalHeight = ACC_titleHeight + ACC_bodyHeight + ACC_mediaSize.height + ACC_SubDividerHeight + ACC_badgeHeight + ACC_verticalPadding + ACC_allSpacingsHeight
    
    let dimensions = PostDimensions(
      contentWidth: contentWidth,
      compact: compact,
      theme: theme,
      titleSize: CGSize(width: titleContentWidth, height: ACC_titleHeight + 1),
      bodySize: !theresSelftext || compact ? nil : CGSize(width: contentWidth, height: ACC_bodyHeight),
      urlTagHeight: urlTagHeight,
      mediaSize: !theresMedia ? nil : compact ? compactMediaSize : CGSize(width: contentWidth, height: ACC_mediaSize.height),
      dividerSize: compact ? nil : CGSize(width: contentWidth, height: ACC_SubDividerHeight),
      badgeSize: CGSize(width: contentWidth, height: ACC_badgeHeight),
      spacingHeight: ACC_allSpacingsHeight
    )
    
    return dimensions
  }
  return .zero
}
