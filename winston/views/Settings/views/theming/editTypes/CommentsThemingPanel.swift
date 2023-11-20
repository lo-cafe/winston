//
//  CommentsThemingPanel.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import SwiftUI

private enum Category: String, CaseIterable {
  case general, badge
}

struct CommentsGeneralSettings: View {
  @Binding var theme: WinstonTheme
  var body: some View {
    Group {
      FakeSection("Spacing") {
        LabeledSlider(label: "Inner horizontal padding", value: $theme.comments.theme.innerPadding.horizontal, range: 0...64)
          .resetter($theme.comments.theme.innerPadding.horizontal, defaultTheme.comments.theme.innerPadding.horizontal)
        Divider()
        LabeledSlider(label: "Inner vertical padding", value: $theme.comments.theme.innerPadding.vertical, range: 0...64)
          .resetter($theme.comments.theme.innerPadding.vertical, defaultTheme.comments.theme.innerPadding.vertical)
        Divider()
        LabeledSlider(label: "Outer horizontal padding", value: $theme.comments.theme.outerHPadding, range: 0...64)
          .resetter($theme.comments.theme.outerHPadding, defaultTheme.comments.theme.outerHPadding)
        Divider()
        // Hack for bypassing SwiftUI views limit
        Group {
          LabeledSlider(label: "Root comments spacing", value: $theme.comments.spacing, range: 0...64)
            .resetter($theme.comments.spacing, defaultTheme.comments.spacing)
          Divider()
          LabeledSlider(label: "Replies spacing", value: $theme.comments.theme.repliesSpacing, range: 0...64)
            .resetter($theme.comments.theme.repliesSpacing, defaultTheme.comments.theme.repliesSpacing)
          Divider()
          LabeledSlider(label: "Body/author spacing", value: $theme.comments.theme.bodyAuthorSpacing, range: 0...64)
            .resetter($theme.comments.theme.bodyAuthorSpacing, defaultTheme.comments.theme.bodyAuthorSpacing)
          Divider()
          LabeledSlider(label: "Line spacing", value: $theme.comments.theme.linespacing, range: 0...64)
            .resetter($theme.comments.theme.linespacing, defaultTheme.comments.theme.linespacing)
        }
      }
      
      FakeSection("Comment body font") {
        FontSelector(theme: $theme.comments.theme.bodyText, defaultVal: defaultTheme.comments.theme.bodyText)
      }
      
      FakeSection("Indentation lines") {
        LabeledSlider(label: "Corner curvature", value: $theme.comments.theme.indentCurve, range: 3...32)
          .resetter($theme.comments.theme.indentCurve, defaultTheme.comments.theme.indentCurve)
        
        SchemesColorPicker(theme: $theme.comments.theme.indentColor, defaultVal: defaultTheme.comments.theme.indentColor)
      }
      
      FakeSection("Background") {
        SchemesColorPicker(theme: $theme.comments.theme.bg, defaultVal: defaultTheme.comments.theme.bg)
        LabeledSlider(label: "Corner radius", value: $theme.comments.theme.cornerRadius, range: 0...48)
          .resetter($theme.comments.theme.cornerRadius, defaultTheme.comments.theme.cornerRadius)
      }
      
      FakeSection("Comments divider") {
        LineThemeEditor(theme: $theme.comments.divider, defaultVal: defaultTheme.comments.divider)
      }
        
      FakeSection("Load More spacing") {
        LabeledSlider(label: "Inner horizontal padding", value: $theme.comments.theme.loadMoreInnerPadding.horizontal, range: 0...64)
          .resetter($theme.comments.theme.innerPadding.horizontal, defaultTheme.comments.theme.loadMoreInnerPadding.horizontal)
        Divider()
        LabeledSlider(label: "Inner vertical padding", value: $theme.comments.theme.loadMoreInnerPadding.vertical, range: 0...64)
          .resetter($theme.comments.theme.innerPadding.vertical, defaultTheme.comments.theme.loadMoreInnerPadding.vertical)
        Divider()
        LabeledSlider(label: "Outer top padding", value: $theme.comments.theme.loadMoreOuterTopPadding, range: 0...64)
          .resetter($theme.comments.theme.outerHPadding, defaultTheme.comments.theme.loadMoreOuterTopPadding)
      }
      
      FakeSection("Load More text") {
        FontSelector(theme: $theme.comments.theme.loadMoreText, defaultVal: defaultTheme.comments.theme.loadMoreText)
      }
      
      FakeSection("Load More background") {
        SchemesColorPicker(theme: $theme.comments.theme.loadMoreBackground, defaultVal:  defaultTheme.comments.theme.loadMoreBackground)
      }
      
      FakeSection("Unseen Dot") {
        SchemesColorPicker(theme: $theme.comments.theme.unseenDot, defaultVal:  defaultTheme.comments.theme.unseenDot)
      }
    }
  }
}

struct CommentsThemingPanel: View {
  @Binding var theme: WinstonTheme
  @State private var selectedCategory = Category.general.rawValue
  @StateObject private var routerProxy = RouterProxy(Router(id: "CommentsThemingPanel"))
  @StateObject private var sampleComment = Comment(data: getCommentSampleData(), api: RedditAPI.shared)
//  
  var body: some View {
    ScrollWithPreview(handlerBGOnly: false, theme: theme.postLinks.bg) {
      VStack(spacing: 32) {
        TagsOptionsCarousel($selectedCategory, (Category.allCases.map { $0.rawValue }))
        
        switch selectedCategory {
        case Category.general.rawValue:
          CommentsGeneralSettings(theme: $theme)
        case Category.badge.rawValue:
          BadgeSettings(theme: $theme.comments.theme.badge, defaultVal: defaultTheme.comments.theme.badge)
        default:
          EmptyView()
        }
      }
    } preview: {
      ScrollView(showsIndicators: false) {
        VStack(spacing: theme.comments.spacing) {
          PreviewComment(selectedTheme: theme, comment: sampleComment)
          NiceDivider(divider: theme.comments.divider)
          PreviewComment(selectedTheme: theme, comment: sampleComment)
          NiceDivider(divider: theme.comments.divider)
          PreviewComment(selectedTheme: theme, comment: sampleComment)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, theme.comments.theme.outerHPadding)
      }
      .highPriorityGesture(DragGesture())
      .frame(height: (UIScreen.screenHeight - getSafeArea().top - getSafeArea().bottom) / 2, alignment: .top)
      .clipped()
//      .mask(RR(20, .black).padding(.horizontal, theme.comments.theme.outerHPadding))
    }
    .scrollContentBackground(.hidden)
    .themedListBG(theme.lists.bg)
    .navigationTitle("Comments")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct PreviewComment: View {
  var selectedTheme: WinstonTheme
  var comment: Comment
  @Environment(\.colorScheme) private var cs
  var body: some View {
    let theme = selectedTheme.comments
    VStack(spacing: 0) {
      Spacer()
        .frame(maxWidth: .infinity, minHeight: theme.theme.cornerRadius * 2, maxHeight: theme.theme.cornerRadius * 2, alignment: .top)
        .background(CommentBG(cornerRadius: theme.theme.cornerRadius, pos: .top).fill(theme.theme.bg.cs(cs).color()))
        .frame(maxWidth: .infinity, minHeight: theme.theme.cornerRadius, maxHeight: theme.theme.cornerRadius, alignment: .top)
        .clipped()
      
      if let commentWinstonData = comment.winstonData {
        CommentLink(comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
      }
      
      Spacer()
        .frame(maxWidth: .infinity, minHeight: theme.theme.cornerRadius * 2, maxHeight: theme.theme.cornerRadius * 2, alignment: .top)
        .background(CommentBG(cornerRadius: theme.theme.cornerRadius, pos: .bottom).fill(theme.theme.bg.cs(cs).color()))
        .frame(maxWidth: .infinity, minHeight: theme.theme.cornerRadius, maxHeight: theme.theme.cornerRadius, alignment: .bottom)
        .clipped()
    }
  }
}
