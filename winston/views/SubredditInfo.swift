//
//  SubredditInfo.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftDate

struct SubredditInfo: View {
  @ObservedObject var subreddit: Subreddit
  @State var loading = true
  
  var body: some View {
    ScrollView {
      if let data = subreddit.data {
        VStack (spacing: 16) {
          let communityIcon = data.community_icon.split(separator: "?")
          let icon = data.icon_img == "" ? communityIcon.count > 0 ? String(communityIcon[0]) : "" : data.icon_img
          WebImage(url: URL(string: icon))
            .resizable()
            .scaledToFill()
            .frame(width: 125, height: 125)
            .mask(Circle())
          
          VStack {
            Text("r/\(data.display_name)")
              .fontSize(22, .bold)
            Text("Created \(Date(timeIntervalSince1970: TimeInterval(data.created)).toFormat("MMM dd, yyyy"))")
              .fontSize(16, .medium)
              .opacity(0.5)
          }
          
          HStack {
            
            DataBlock(icon: "person.3.fill", label: "Subscribers", value: "\(data.subscribers)")
            DataBlock(icon: "app.connected.to.app.below.fill", label: "Online", value: loading ? "loading..." : "\(data.accounts_active ?? 0)")

          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .fixedSize(horizontal: false, vertical: true)
          
          VStack {
            Text("Description")
              .fontSize(20, .bold)
              .frame(maxWidth: .infinity, alignment: .leading)
            
            Text((data.public_description == "" ? data.description : data.public_description).md())

              .frame(maxWidth: .infinity, alignment: .leading)
              .multilineTextAlignment(.leading)
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
        .padding([.horizontal, .bottom], 16)
        .frame(maxWidth: .infinity)
      }
    }
  }
}
//
//struct SubredditInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        SubredditInfo()
//    }
//}
