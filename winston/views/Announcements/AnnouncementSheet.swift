//
//  AnnouncementSheet.swift
//  winston
//
//  Created by daniel on 25/11/23.
//

import SwiftUI
import Defaults
import MarkdownUI

struct AnnouncementSheet: View {
  var announcement: Announcement?
  @Environment(\.useTheme) private var theme
  @Environment(\.dismiss) private var dismiss
  var body: some View {
    if let announcement {
      ZStack{
        
        ScrollView{
          VStack{
            Text(announcement.name ?? "")
              .fontSize(24, .bold)
            Text(Date(timeIntervalSince1970: Double(announcement.timestamp  ?? 0) / 1000), style: .date)
              .opacity(0.5)
            Divider()
            
            Section {
              let text = MarkdownUtil.formatForMarkdown(announcement.description ?? "")
              Markdown(text.isEmpty ? "Announcement without description." : text)
                .markdownTheme(.winstonMarkdown(fontSize: 16))
            }
            .padding(.top)
            
            Color.clear
              .frame(height: 100)
            
          }
        }
        .padding()
        .ignoresSafeArea(.all)
//        .onAppear{
//          Defaults[.lastSeenAnnouncementTimeStamp] = announcement.timestamp ?? 0
//        }
        
        VStack{
          Spacer()
          MasterButton(label: announcement.buttonLabel == "" ? "Close" : announcement.buttonLabel, color: theme.general.accentColor(), colorHoverEffect: .animated, textSize: 18, height: 48, cornerRadius: 16, action: {
            withAnimation(spring) {
              dismiss()
            }
          })
          .padding()
          .frame(width: .screenW)
          .background(
            Material.ultraThinMaterial
          )
        }
      }
      
      
    }
  }
}
