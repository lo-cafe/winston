//
//  UserView.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import SwiftUI
import LonginusSwiftUI

//enum UserViewSections: Int {
//  case
//}

struct UserView: View {
  @StateObject var user: User
  @State private var loading = true
  @State private var lastActivities: [Either<PostData, CommentData>]?
  @State private var contentWidth: CGFloat = 0
  
  func refresh(_ force: Bool = false, _ full: Bool = true) async {
    await user.refetchUser()
  }
  
  var body: some View {
    List {
      if let data = user.data {
        Group {
          VStack(spacing: 16) {
            ZStack {
              if let bannerImgFull = data.subreddit?.banner_img, bannerImgFull != "" {
                let bannerImg = String(bannerImgFull.split(separator: "?")[0])
                LGImage(source: URL(string: bannerImg), placeholder: {
                  ProgressView()
                }, options: [.imageWithFadeAnimation])
                .resizable()
                //                    .placeholder {
                //                      ProgressView()
                //                        .progressViewStyle(.circular)
                //                        .frame(width: 22, height: 22 )
                //                        .frame(maxWidth: .infinity, minHeight: 160)
                //                    }
                .scaledToFill()
                .frame(width: contentWidth, height: 160)
                .mask(RR(16, .black))
              }
              if let iconFull = data.subreddit?.icon_img, iconFull != "" {
                let icon = String(iconFull.split(separator: "?")[0])
                LGImage(source: URL(string: icon), placeholder: {
                  ProgressView()
                }, options: [.imageWithFadeAnimation])
                .resizable()
                //                    .placeholder {
                //                      ProgressView()
                //                        .progressViewStyle(.circular)
                //                        .frame(width: 22, height: 22 )
                //                        .frame(width: 30, height: 30 )
                //                        .background(.gray, in: Circle())
                //                    }
                .scaledToFill()
                .frame(width: 125, height: 125)
                .mask(Circle())
                .offset(y: data.subreddit?.banner_img == "" || data.subreddit?.banner_img == nil ? 0 : 80)
              }
            }
            .frame(maxWidth: .infinity)
            .background(
              GeometryReader { geo in
                Color.clear.onAppear { contentWidth = geo.size.width }
              }
            )
            .padding(.bottom, data.subreddit?.banner_img == "" || data.subreddit?.banner_img == nil ? 0 : 78)
            
            if let description = data.subreddit?.public_description {
              Text((description).md())
                .fontSize(15)
            }
            
            VStack {
              HStack {
                if let postKarma = data.link_karma {
                  DataBlock(icon: "highlighter", label: "Post karma", value: "\(formatBigNumber(postKarma))")
                    .transition(.opacity)
                }
                
                if let commentKarma = data.comment_karma {
                  DataBlock(icon: "checkmark.message.fill", label: "Comment karma", value: "\(formatBigNumber(commentKarma))")
                    .transition(.opacity)
                }
              }
              if let created = data.created {
                DataBlock(icon: "star.fill", label: "User since", value: "\(Date(timeIntervalSince1970: TimeInterval(created)).toFormat("MMM dd, yyyy"))")
                  .transition(.opacity)
              }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8)
            .transition(.opacity)
          }
          
          Text("Last activities")
            .fontSize(20, .bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
          
          if let lastActivities = lastActivities {
            ForEach(lastActivities, id: \.self.hashValue) { item in
              VStack(spacing: 0) {
                switch item {
                case .first(let post):
                  PostLink(post: Post(data: post, api: user.redditAPI), sub: Subreddit(id: post.subreddit, api: user.redditAPI), showSub: true)
                case .second(let comment):
                  VStack {
                    ShortCommentPostLink(comment: Comment(data: comment, api: user.redditAPI))
                    CommentLink(showReplies: false, comment: Comment(data: comment, api: user.redditAPI))
                  }
                  .padding(.horizontal, 12)
                  .padding(.top, 12)
                  .padding(.bottom, 10)
                  .background(RR(20, .listBG))
                }
              }
            }
          }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .transition(.opacity)
      }
      
    }
    .introspect(.list, on: .iOS(.v15)) { list in
      list.backgroundColor = UIColor.systemGroupedBackground
    }
    .introspect(.list, on: .iOS(.v16, .v17)) { list in
      list.backgroundColor = UIColor.systemGroupedBackground
    }
    .listStyle(.plain)
    .refreshable {
        await refresh()
        
        if let data = await user.refetchOverview() {
          DispatchQueue.main.async { // fetching posts on non-main thread
            withAnimation {
              lastActivities = data
            }
          }
          await user.redditAPI.updateAvatarURLCacheFromOverview(subjects: data)
        }
    }
    .navigationTitle(user.data?.name ?? "Loading...")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      Task {
        if user.data == nil {
          await user.refetchUser()
        }
        if lastActivities == nil, let data = await user.refetchOverview() {
          await MainActor.run {
            withAnimation {
              lastActivities = data
            }
          }
          await user.redditAPI.updateAvatarURLCacheFromOverview(subjects: data)
        }
      }
    }
  }
}

//struct UserView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserView()
//    }
//}
