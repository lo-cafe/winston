//
//  UserView.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserView: View {
  @State var user: User
  @State var loading = true
  @State var lastActivities: [Either<CommentData, PostData>]?
  
  var body: some View {
    ScrollView {
      if let data = user.data {
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
                    .frame(width: 30, height: 30 )
                    .background(.gray, in: Circle())
                }
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
                .scaledToFill()
                .frame(width: 125, height: 125)
                .mask(Circle())
                .offset(y: 80)
            }
          }
          .padding(.bottom, 62)
          
          VStack {
            HStack {
              if let postKarma = data.link_karma {
                DataBlock(icon: "highlighter", label: "Post karma", value: "\(postKarma)")
              }
              
              if let commentKarma = data.comment_karma {
                DataBlock(icon: "checkmark.message.fill", label: "Comment karma", value: "\(commentKarma)")
              }
            }
            if let created = data.created {
              DataBlock(icon: "star.fill", label: "User since", value: "\(Date(timeIntervalSince1970: TimeInterval(created)).toFormat("MMM dd, yyyy"))")
            }
          }
          
          VStack {
            Text("Last activities")
              .fontSize(20, .bold)
              .frame(maxWidth: .infinity, alignment: .leading)
            
            if let lastActivities = lastActivities {
              ForEach(lastActivities, id: \.self.hashValue) { activity in
                VStack {
                  switch activity {
                  case .first(let comment):
                    CommentLink(comment: Comment(data: comment, api: user.redditAPI))
                  case .second(let post):
                    PostLink(post: Post(data: post, api: user.redditAPI), sub: Subreddit(id: post.subreddit, api: user.redditAPI))
                  }
                }
              }
            }
          }
        }
        .padding([.horizontal, .bottom], 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      } else {
        ProgressView()
          .progressViewStyle(.circular)
          .frame(maxWidth: .infinity, minHeight: UIScreen.screenHeight - 200 )
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .navigationTitle(user.data?.name ?? "Loading...")
    .navigationBarTitleDisplayMode(.inline)
    .refreshable {
      var newUser = user
      await newUser.refetchUser()
      user = newUser
    }
    .onAppear {
      Task {
        var newUser = user
        if user.data == nil {
          await newUser.refetchUser()
          user = newUser
        }
        if lastActivities == nil, let data = await newUser.refetchOverview() {
          lastActivities = data
//          data.forEach { x in
//            print(x)
//            switch x {
//            case .first(let a):
//              print("comment")
//            case .second(let a):
//              print("post")
//            }
//          }
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
