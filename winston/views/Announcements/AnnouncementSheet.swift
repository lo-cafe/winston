//
//  AnnouncementSheet.swift
//  winston
//
//  Created by daniel on 25/11/23.
//

import SwiftUI
import Defaults

struct AnnouncementSheet: View {
  @Binding var showingAnnouncement: Bool
  var announcement: Announcement?
  @Environment(\.useTheme) private var theme
  @Environment(\.colorScheme) private var cs
  var body: some View {
    if let announcement {
      ZStack{
        
        ScrollView{
          VStack{
            Text(announcement.name)
              .fontSize(24, .bold)
            Text(Date(timeIntervalSince1970: Double(announcement.timestamp  ?? 0) / 1000), style: .date)
              .opacity(0.5)
            Divider()
            
            Section {
              MD(.str(announcement.description ?? ""))
            }
            .padding(.top)
            
            Color.clear
              .frame(height: 100)
            
          }
        }
        .padding()
        .ignoresSafeArea(.all)
        .onAppear{
//          Defaults[.lastSeenAnnouncementTimeStamp] = announcement.timestamp ?? 0
        }
        
        VStack{
          Spacer()
          MasterButton(label: announcement.buttonLabel == "" ? "Close" : announcement.buttonLabel, color: theme.general.accentColor.cs(cs).color(), colorHoverEffect: .animated, textSize: 18, height: 48, cornerRadius: 16, action: {
            withAnimation(spring) {
              showingAnnouncement = false
            }
          })
          .padding()
          .frame(width: UIScreen.screenWidth)
          .background(
            Material.ultraThinMaterial
          )
        }
      }
      
      
    }
  }
}
