//
//  UserView.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import SwiftUI
import SDWebImageSwiftUI
import ASCollectionView

//enum UserViewSections: Int {
//  case
//}

struct UserView: View {
  @StateObject var user: User
  @State var loading = true
  @State var disableScroll = false
  @State var lastActivities: [Either<PostData, CommentData>]?
  
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
                  WebImage(url: URL(string: bannerImg))
                    .resizable()
                    .placeholder {
                      ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: 22, height: 22 )
                        .frame(maxWidth: .infinity, minHeight: 160)
                    }
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 160)
                    .mask(RR(16, .black))
                }
                if let iconFull = data.subreddit?.icon_img, iconFull != "" {
                  let icon = String(iconFull.split(separator: "?")[0])
                  WebImage(url: URL(string: icon))
                    .resizable()
                    .placeholder {
                      ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: 22, height: 22 )
                        .frame(width: 30, height: 30 )
                        .background(.gray, in: Circle())
                    }
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(width: 125, height: 125)
                    .mask(Circle())
                    .offset(y: data.subreddit?.banner_img == "" || data.subreddit?.banner_img == nil ? 0 : 80)
                }
              }
              .padding(.bottom, data.subreddit?.banner_img == "" || data.subreddit?.banner_img == nil ? 0 : 78)
              .padding(.horizontal, 16)
              
              VStack {
                HStack {
                  if let postKarma = data.link_karma {
                    DataBlock(icon: "highlighter", label: "Post karma", value: "\(postKarma)")
                      .transition(.fade(duration: 0.5))
                  }
                  
                  if let commentKarma = data.comment_karma {
                    DataBlock(icon: "checkmark.message.fill", label: "Comment karma", value: "\(commentKarma)")
                      .transition(.fade(duration: 0.5))
                  }
                }
                if let created = data.created {
                  DataBlock(icon: "star.fill", label: "User since", value: "\(Date(timeIntervalSince1970: TimeInterval(created)).toFormat("MMM dd, yyyy"))")
                    .transition(.fade(duration: 0.5))
                }
              }
              .fixedSize(horizontal: false, vertical: true)
              .padding(.horizontal, 16)
              .transition(.fade(duration: 0.5))
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
                      ShortPostLink(comment: Comment(data: comment, api: user.redditAPI))
//                      CommentLink(disableScroll: $disableScroll, refresh: refresh, comment: Comment(data: comment, api: user.redditAPI))
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                    .background(RR(20, .secondary.opacity(0.1)))
                  }
                }
              }
            }
          }
          .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
          .transition(.fade(duration: 0.5))
        }
        
      }
      .listStyle(.plain)
      .refreshable {
        await refresh()
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
