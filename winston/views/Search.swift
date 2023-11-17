//
//  Search.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

enum SearchType: String {
  case subreddit = "Subreddit"
  case user = "User"
  case post = "Post"
}

struct SearchOption: View {
  var activateSearchType: ()->()
  var active: Bool
  var searchType: SearchType
  var body: some View {
    Text(searchType.rawValue)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Capsule(style: .continuous).fill(active ? Color.accentColor : .secondary.opacity(0.15)))
      .foregroundColor(active ? .white : .primary)
      .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke((active ? Color.white : .primary).opacity(0.01), lineWidth: 1))
      .contentShape(Capsule())
      .onTapGesture {
        withAnimation(.interactiveSpring()) {
          activateSearchType()
        }
      }
      .shrinkOnTap()
  }
  
}

enum SearchTypeArr {
  case subreddit([Subreddit])
  case user([User])
  case post([Post])
}

struct Search: View {
  var reset: Bool
  @StateObject var router: Router
  @State private var searchType: SearchType = .subreddit
  @StateObject private var resultsSubs = ObservableArray<Subreddit>()
  @StateObject private var resultsUsers = ObservableArray<User>()
  @StateObject private var resultPosts = ObservableArray<Post>()
  @State private var loading = false
  @State private var hideSpinner = false
  @StateObject var searchQuery = DebouncedText(delay: 0.25)
  
  @State private var dummyAllSub: Subreddit? = nil
  @State private var searchViewLoaded: Bool = false
  
  @State private var topSubs:[ListingChild<SubredditData>] = []
  @State private var topPosts: ([ListingChild<PostData>]?, String?) = ([], "")
  
  @Environment(\.useTheme) private var theme
  
  func fetch() {
    if searchQuery.text == "" { return }
    withAnimation {
      loading = true
    }
    switch searchType {
    case .subreddit:
      resultsSubs.data.removeAll()
      Task(priority: .background) {
        if let subs = await RedditAPI.shared.searchSubreddits(searchQuery.text)?.map({ Subreddit(data: $0, api: RedditAPI.shared) }) {
          await MainActor.run {
            withAnimation {
              resultsSubs.data = subs
              loading = false
              hideSpinner = resultsSubs.data.isEmpty
            }
          }
        }
      }
    case .user:
      resultsUsers.data.removeAll()
      Task(priority: .background) {
        if let users = await RedditAPI.shared.searchUsers(searchQuery.text)?.map({ User(data: $0, api: RedditAPI.shared) }) {
          await MainActor.run {
            withAnimation {
              resultsUsers.data = users
              loading = false
              
              hideSpinner = resultsUsers.data.isEmpty
            }
          }
        }
      }
    case .post:
      resultPosts.data.removeAll()
      Task(priority: .background) {
        if let dummyAllSub = dummyAllSub, let result = await dummyAllSub.fetchPosts(searchText: searchQuery.text), let newPosts = result.0 {
          await MainActor.run {
            withAnimation {
              resultPosts.data = newPosts
              loading = false
              
              hideSpinner = resultPosts.data.isEmpty
            }
          }
        }
      }
    }
  }
  
  var body: some View {
    NavigationStack(path: $router.path) {
      DefaultDestinationInjector(routerProxy: RouterProxy(router)) {
        List {
          Group {
            Section {
              HStack {
                SearchOption(activateSearchType: { searchType = .subreddit }, active: searchType == SearchType.subreddit, searchType: .subreddit)
                SearchOption(activateSearchType: { searchType = .user }, active: searchType == SearchType.user, searchType: .user)
                SearchOption(activateSearchType: { searchType = .post }, active: searchType == SearchType.post, searchType: .post)
              }
              .id("options")
            }
            
            
//            if searchQuery.text == ""{
//              Section("Popular Subs"){
//                ScrollView(.horizontal){
//                  HStack{
//                    ForEach(topSubs.filter{$0.data?.display_name != "Home"}, id:\.self){ sub in
//                      HorizontalItemElement(sub: sub)
//                        .id(sub.id)
//                    }
//                  }
//                  
//                }
//                .scrollIndicators(.hidden)
//                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//              }
//              
//              if let posts = topPosts.0 {
//                Section("Popular Posts"){
//                  ScrollView(.horizontal){
//                    HStack{
//                      ForEach(posts, id:\.self){ post in
//                        HorizontalPostItem(post: post)
//                      }
//                    }
//                  }
//                  .scrollIndicators(.hidden)
//                  .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                }
//              }
//            }
//            
            
            Section {
              switch searchType {
              case .subreddit:
                ForEach(resultsSubs.data) { sub in
                  SubredditLink(sub: sub)
                }
              case .user:
                ForEach(resultsUsers.data) { user in
                  UserLink(user: user)
                }
              case .post:
                if let dummyAllSub = dummyAllSub {
                  ForEach(resultPosts.data) { post in
                    PostLink(post: post, sub: dummyAllSub)
                    //                      .equatable()
                      .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                      .animation(.default, value: resultPosts.data)
                  }
                }
              }
            }
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        }
        .themedListBG(theme.lists.bg)
        .listStyle(.plain)
        .background(Color(UIColor.systemGroupedBackground))
        .scrollContentBackground(.hidden)
        .loader(loading, hideSpinner && !searchQuery.text.isEmpty)
        .onChange(of: searchType) { _ in fetch() }
        .onChange(of: reset) { _ in router.path.removeLast(router.path.count) }
        .onChange(of: searchQuery.debounced) { val in
          if val == "" {
            resultsSubs.data = []
            resultsUsers.data = []
            resultPosts.data = []
          }
          fetch()
        }
      }
      .searchable(text: $searchQuery.text, placement: .toolbar)
      .autocorrectionDisabled(true)
      .textInputAutocapitalization(.none)
      .refreshable { fetch() }
      .onSubmit(of: .search) { fetch() }
      .navigationTitle("Search")
      .onAppear() {
        if !searchViewLoaded {
          dummyAllSub = Subreddit(id: "all", api: RedditAPI.shared)
          searchViewLoaded = true
        }
        if topSubs.isEmpty {
          Task {
            topSubs = await RedditAPI.shared.fetchPopularSubs() ?? []
            topPosts = await RedditAPI.shared.fetchSubPosts("all", sort: .top(.day)) ?? ([], "")
          }
        }
      }
      //      .defaultNavDestinations(router)
    }
    .swipeAnywhere(routerProxy: RouterProxy(router), routerContainer: router.isRootWrapper)
  }
}


private struct HorizontalPostItem: View {
  let post:  ListingChild<PostData>
  @State var extractedMedia: MediaExtractedType? = nil
  @EnvironmentObject private var routerProxy: RouterProxy
  var body: some View {
    let color = getRandColor()
    if let data = post.data {
      VStack(alignment: .leading, spacing: 4){
        
        Text(data.title)
          .fontSize(16, .semibold)
          .lineLimit(2)
        Text(data.selftext)
          .fontSize(13)
          .lineLimit(3)
        
        
        Spacer()
          .frame(maxHeight: .infinity)
        
        HStack{
          let sub = Subreddit(id: data.subreddit_id ?? "", api: RedditAPI.shared)
          if let subdata = sub.data {
            SubredditIcon(data: subdata, size: 27)
          }
          
          Text("r/\(data.subreddit)")
            .fontSize(13,.medium)
        }
        
      }
      .foregroundColor(.white)
      .padding(.horizontal, 13)
      .padding(.vertical, 11)
      .frame(width: (UIScreen.screenWidth * 0.5), height: 100, alignment: .topLeading)
      .background{
        if let url = getMediaURL(extractedMedia: extractedMedia) {
          URLImage(url: url)
            .scaledToFill()
            .overlay{
              Rectangle()
                .fill(LinearGradient(
                  gradient: Gradient(stops: [
                    .init(color: Color.black.opacity(0.7), location: 0),
                    .init(color: Color.black.opacity(0.3), location: 1)
                  ]),
                  startPoint: .bottom,
                  endPoint: .top
                ))
                .frame(height: 100)
            }
        } else {
          LinearGradient(colors: [color.opacity(0.7), color.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        
      }
      .mask(RR(20, Color.black))
      .onTapGesture {
        routerProxy.router.path.append(PostViewPayload(post: Post(data: data, api: RedditAPI.shared), sub: Subreddit(id: data.subreddit, api: RedditAPI.shared)))
      }
      .onAppear{
        Task {
          extractedMedia = await mediaExtractor(contentWidth: (UIScreen.screenWidth * 0.5), data)
        }
      }
      
    }
  }
  
  func getMediaURL(extractedMedia: MediaExtractedType?) -> URL? {
    switch extractedMedia {
    case .image(let url):
      return url.url
    case .gallery(let imgs):
      return imgs.first!.url
    case .link(let url):
      return nil
    default:
      return nil
    }
  }
  
  func getRandColor()-> Color {
    let colors = [Color.blue, Color.blue, Color.yellow, Color.red, Color.accentColor, Color.orange, Color.cyan, Color.mint, Color.indigo, Color.purple, Color.teal]
    let randCol = colors.randomElement()
    return randCol!
  }
}


private struct HorizontalItemElement: View {
  let sub: ListingChild<SubredditData>
  @Environment(\.useTheme) private var theme
  @EnvironmentObject private var routerProxy: RouterProxy
  var body: some View {
    if let data = sub.data {
      VStack(alignment: .leading, spacing: 4){
        HStack{
          SubredditIcon(data: data, size: 27)
          Text("r/" + data.display_name)
            .fontSize(16, .semibold)
        }
        HStack{
          Text(data.public_description)
            .font(.caption)
            .lineLimit(2)
        }
        Spacer()
          .frame(maxHeight: .infinity)
        
        HStack(alignment: .center, spacing: 2) {
          Image(systemName: "person.3.fill")
          Text(formatBigNumber(data.subscribers ?? 0))
            .contentTransition(.numericText())
        }
        .font(.system(size: 13, weight: .medium))
        .compositingGroup()
        .opacity(0.5)
        
        
      }
      .padding(.horizontal, 13)
      .padding(.vertical, 11)
      .frame(width: (UIScreen.screenWidth * 0.5), height: 100, alignment: .topLeading)
      .background{
        LinearGradient(gradient: Gradient(colors: [Color(uiColor: UIColor(hex: data.banner_background_color ?? "#FFFFFF")).opacity(0.3), Color(uiColor: UIColor(hex: data.banner_background_color ?? "#FFFFFF")).opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing)
          .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        
      }
      .onTapGesture {
        routerProxy.router.path.append(SubredditPostsContainerPayload(sub: Subreddit(id: data.display_name ?? "", api: RedditAPI.shared)))
      }
    }
  }
}


//struct Search_Previews: PreviewProvider {
//    static var previews: some View {
//        Search()
//    }
//}
