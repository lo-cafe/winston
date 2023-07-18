////
////  Post.swift
////  winston
////
////  Created by Igor Marcossi on 28/06/23.
////
//
//import SwiftUI
//import Kingfisher
//import Defaults
//import VideoPlayer
//import CoreMedia
//import Defaults
//import MarkdownUI
//
//struct PostView: View {
//  @Default(.preferenceShowCommentsCards) var preferenceShowCommentsCards
//  @ObservedObject var post: Post
//  @ObservedObject var subreddit: Subreddit
//  var fromMessage: MessageData?
//  @State var ignoreSpecificComment = false
//  @State var loading = true
//  @State var disableScroll = false
//  @State var loadingMore = false
//  @State var sort: CommentSortOption = Defaults[.preferredCommentSort]
//  @StateObject var comments = ObservableArray<Comment>()
//  @State var lastPostAfter: String?
//  @State var avatars: [String:String]?
//  @EnvironmentObject var redditAPI: RedditAPI
//  
//  func asyncFetch(_ loadMore: Bool = false, _ full: Bool = true) async {
//    var specificID: String? = nil
//    if let fromMessage = fromMessage, let parentID = fromMessage.parent_id {
//      specificID = parentID.hasSuffix(post.id) ? fromMessage.name : parentID
//    }
//    if let result = await post.refreshPost(commentID: ignoreSpecificComment ? nil : specificID, sort: sort, after: nil, subreddit: subreddit.data?.display_name ?? subreddit.id, full: full), let newComments = result.0 {
//      await MainActor.run {
//        withAnimation {
//          if loadMore {
//            comments.data = comments.data + newComments
//          } else {
//            comments.data = newComments
//          }
//          loading = false
//        }
//        lastPostAfter = result.1
//        loadingMore = false
//      }
//      await redditAPI.updateAvatarURLCacheFromComments(comments: newComments)
//    } else {
//      await MainActor.run {
//        withAnimation {
//          loading = false
//        }
//      }
//    }
//  }
//  
//  func fetch(loadMore: Bool = false, full: Bool = true) {
//    if loadMore {
//      loadingMore = true
//    }
//    Task {
//      await asyncFetch(loadMore, full)
//    }
//  }
//  
//  var body: some View {
//    ScrollViewReader { proxy in
//      List {
//        Group {
//          Group {
//            if let data = post.data {
//              VStack(spacing: 16) {
//                VStack(alignment: .leading, spacing: 12) {
//                  Text(data.title)
//                    .fontSize(20, .semibold)
//                    .fixedSize(horizontal: false, vertical: true)
//                  
//                  let imgPost = data.url.hasSuffix("jpg") || data.url.hasSuffix("png")
//                  
//                  if let _ = data.secure_media {
//                    VideoPlayerPost(prefix: "postView", post: post)
//                  }
//                  
//                  if imgPost {
//                    ImageMediaPost(prefix: "postView", post: post)
//                  }
//                  
//                  if data.selftext != "" {
//                    MD(str: data.selftext)
//                  }
//                  
//                  if let fullname = data.author_fullname {
//                    Badge(author: data.author, fullname: fullname, created: data.created)
//                  }
//                }
//                
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .foregroundColor(.primary)
//                .multilineTextAlignment(.leading)
//                
//                HStack(spacing: 0) {
//                  if let link_flair_text = data.link_flair_text {
//                    Rectangle()
//                      .fill(.primary.opacity(0.1))
//                      .frame(maxWidth: .infinity, maxHeight: 1)
//                    
//                    Text(link_flair_text)
//                      .fontSize(13)
//                      .padding(.horizontal, 6)
//                      .padding(.vertical, 2)
//                      .background(Capsule(style: .continuous).fill(.secondary.opacity(0.25)))
//                      .foregroundColor(.primary.opacity(0.5))
//                      .fixedSize()
//                  }
//                  Rectangle()
//                    .fill(.primary.opacity(0.1))
//                    .frame(maxWidth: .infinity, maxHeight: 1)
//                }
//                .padding(.horizontal, 2)
//              }
//            } else {
//              VStack {
//                ProgressView()
//                  .progressViewStyle(.circular)
//                  .frame(maxWidth: .infinity, minHeight: UIScreen.screenHeight - 200 )
//              }
//            }
//            
//            Text("Comments")
//              .fontSize(20, .bold)
//              .frame(maxWidth: .infinity, alignment: .leading)
//          }
//          .listRowBackground(Color.clear)
//          
//          let commentsData = comments.data
//          if commentsData.count > 0, let postFullname = post.data?.name {
//            ForEach(Array(commentsData.enumerated()), id: \.element.id) { i, comment in
//              Section {
//                CommentLink(disableScroll: $disableScroll, postFullname: postFullname, parentElement: .post(comments), comment: comment)
//              }
//              .frame(width: UIScreen.screenWidth - 16)
//            }
//          } else {
//            if loading {
//              ProgressView()
//                .progressViewStyle(.circular)
//                .frame(maxWidth: .infinity, minHeight: 300 )
//                .listRowBackground(Color.clear)
//            } else {
//              Text("No comments around...")
//                .frame(maxWidth: .infinity, minHeight: 300)
//                .opacity(0.25)
//                .listRowBackground(Color.clear)
//            }
//          }
//          
//          Spacer()
//            .frame(maxWidth: .infinity, minHeight: 72)
//        }
//        
//        .listRowSeparator(.hidden)
//        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//      }
////      .introspect(.list, on: .iOS(.v13, .v14, .v15)) { tableView in
////        tableView.contentInset = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: -8)
////      }
////      .introspect(.list, on: .iOS(.v16, .v17)) { collectionView in
////        collectionView.contentInset = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: -8)
////        collectionView.contentSiz
////      }
//      //      .listStyle(.grouped)
//      //      .id(post.id)
//      //      .environmentObject(fromMessage)
//      //    .introspect(.list, on: .iOS(.v16, .v17)) { collectionView in
//      //      collectionView.isScrollEnabled = !disableScroll
//      //      tableView.isScrollEnabled = !disableScroll
//      //      tableView.
//      //      scrollView.isScrollEnabled = !disableScroll
//      //    }
//      //    .defaultMinListRowHeight(
//      //    .scrollDisabled(disableScroll)
//      .refreshable {
//        await asyncFetch(false, true)
//      }
//      .overlay(
//        PostFloatingPill(post: post)
//        , alignment: .bottomTrailing
//      )
//      //    .navigationBarTitle(Text(post.data == nil ? "loading..." : "\(post.data?.num_comments ?? 0) comments"), displayMode: .inline)
//      .navigationBarTitle("\(post.data?.num_comments ?? 0) comments", displayMode: .inline)
//      .navigationBarItems(
//        trailing:
//          HStack {
//            Menu {
//              ForEach(CommentSortOption.allCases) { opt in
//                Button {
//                  sort = opt
//                } label: {
//                  HStack {
//                    Text(opt.rawVal.value.capitalized)
//                    Spacer()
//                    Image(systemName: opt.rawVal.icon)
//                      .foregroundColor(.blue)
//                      .fontSize(17, .bold)
//                  }
//                }
//              }
//            } label: {
//              Button { } label: {
//                Image(systemName: sort.rawVal.icon)
//                  .foregroundColor(.blue)
//                  .fontSize(17, .bold)
//              }
//            }
//            
//            if let data = subreddit.data {
//              NavigationLink {
//                SubredditInfo(subreddit: subreddit)
//              } label: {
//                SubredditIcon(data: data)
//              }
//            }
//          }
//          .animation(nil, value: sort)
//      )
//      .onAppear {
//        if comments.data.count == 0 || post.data == nil {
//          Task {
//            await asyncFetch(false, false)
//            //            var specificID: String? = nil
//            if let fromMessage = fromMessage, let _ = fromMessage.parent_id {
//              if var specificID = fromMessage.name {
//                specificID = specificID.hasPrefix("t1_") ? String(specificID.dropFirst(3)) : specificID
//                doThisAfter(0) {
//                  withAnimation(spring) {
//                    proxy.scrollTo(specificID, anchor: .center)
//                  }
//                }
//              }
//            }
//            //            if let specificID = specificID {
//            //              print(specificID)
//            //            }
//          }
//        }
//        if subreddit.data == nil {
//          Task {
//            await subreddit.refreshSubreddit()
//          }
//        }
//      }
//    }
//  }
//}
//
//
//
////struct Post_Previews: PreviewProvider {
////    static var previews: some View {
////        PostLink()
////    }
////}
