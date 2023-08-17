//
//  AboutPanel.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import SwiftUI

struct AboutPanel: View {
  @Environment(\.openURL) var openURL
  let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  var body: some View {
      List {
        Section {
          HStack {
            Image("winstonNoBG")
              .resizable()
              .scaledToFit()
              .frame(width: 48, height: 48)

            VStack(alignment: .leading) {
              Text("Winston")
                .fontSize(20, .bold)
              HStack{
                Text("Beta v" + (appVersion ?? "-1")) 
              }
            }
          }
          Text("Winston is developed by the lo.cafe team, a group of friends making amazing software together.")
          Button {
            openURL(URL(string: "https://lo.cafe")!)
          } label: {
            Label("Visit lo.cafe website", systemImage: "cup.and.saucer.fill")
          }
          Button {
            openURL(URL(string: "https://discord.gg/Jw3Syb3nrz")!)
          } label: {
            Label("Join the Discord server", systemImage: "person.3.fill")
          }
          Button {
            openURL(URL(string: "https://patreon.com/user?u=93745105")!)
          } label: {
            Label("Support our work!", systemImage: "heart.fill")
          }
        }
        
        Section {
          Text("Winston is a free and open source software, therefore it isn't against Reddit's policies.")
          Button {
            openURL(URL(string: "https://github.com/Kinark/winston")!)
          } label: {
            Label("Check Winston's source code", systemImage: "arrow.branch")
          }
        }
      }
    }
}

//struct AboutPanel_Previews: PreviewProvider {
//    static var previews: some View {
//        AboutPanel()
//    }
//}
