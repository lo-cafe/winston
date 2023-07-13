//
//  SubredditInfo.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import SwiftUI
import Kingfisher
import SwiftDate

enum SubInfoTabs: String, CaseIterable, Identifiable {
  var id: Self {
    return self
  }
  
  case info = "Info"
  case myposts = "My posts"
}

struct SubredditInfo: View {
  @ObservedObject var subreddit: Subreddit
  @State var loading = true
  @State var selectedTab: SubInfoTabs = .info
  
  @StateObject var myPosts = ObservableArray<Post>()
  @State var myPostsLoaded = false
  
  var body: some View {
    List {
      Group {
        if let data = subreddit.data {
          VStack (spacing: 16) {
            SubredditIcon(data: data, size: 125)
            
            VStack {
              Text("r/\(data.display_name ?? "")")
                .fontSize(22, .bold)
              Text("Created \(Date(timeIntervalSince1970: TimeInterval(data.created)).toFormat("MMM dd, yyyy"))")
                .fontSize(16, .medium)
                .opacity(0.5)
            }
            
            Picker("", selection: $selectedTab) {
              ForEach(SubInfoTabs.allCases) { tab in
                Text(tab.rawValue)
              }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: .infinity)
            
            if selectedTab == .info {
              HStack {
                
                DataBlock(icon: "person.3.fill", label: "Subscribers", value: "\(formatBigNumber(data.subscribers ?? 0))")
                DataBlock(icon: "app.connected.to.app.below.fill", label: "Online", value: loading ? "loading..." : "\(formatBigNumber(data.accounts_active ?? 0))")
                
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .fixedSize(horizontal: false, vertical: true)
              
              VStack {
                Text("Description")
                  .fontSize(20, .bold)
                  .frame(maxWidth: .infinity, alignment: .leading)
                
                Text((data.public_description == "" ? data.description ?? "" : data.public_description ?? "").md())
                
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .multilineTextAlignment(.leading)
              }
            } else {
              Text("This is not working yet :(")
//              if myPostsLoaded {
//
//              } else {
//                ProgressView()
//                  .frame(maxWidth: .infinity, minHeight: 400)
//                  .onAppear {
//
//                  }
//              }
            }
            
          }
          .onAppear {
            if loading {
              Task {
                await subreddit.refreshSubreddit()
                loading = false
              }
            }
          }
          .padding(.bottom, 16)
          .frame(maxWidth: .infinity)
        }
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
      .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}
//
//struct SubredditInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        SubredditInfo()
//    }
//}
