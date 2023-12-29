//
//  AppIconSetting.swift
//  winston
//
//  Created by Igor Marcossi on 30/09/23.
//

import SwiftUI

struct AppIconSetting: View {
  @State private var appIconManager = AppIconManger()
  @State private var appIcon: WinstonAppIcon = .standard
  @Environment(\.useTheme) private var theme
  var body: some View {
    List {
      Section {
        ForEach(WinstonAppIcon.allCases) { icon in
          HStack(spacing: 12) {
            Image(uiImage: icon.preview)
              .resizable()
              .scaledToFill()
              .frame(width: 64, height: 64)
              .fixedSize()
              .mask(RR(16, Color.black))
            
            HStack(spacing: 0) {
              VStack(alignment: .leading) {
                Text(icon.label)
                //                  .fixedSize(horizontal: true, vertical: false)
                  .fontSize(16, .semibold)
                Text(icon.description)
                  .frame(maxWidth: .infinity, alignment: .leading)
                //                  .fixedSize(horizontal: false, vertical: true)
                  .fontSize(14)
                  .opacity(0.5)
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              
              //              Spacer()
              
              if(icon == appIcon)
              {
                Image(systemName: "checkmark")
                  .foregroundColor(.accentColor)
              }
            }
          }
          .onTapGesture {
            appIcon = icon
          }
        }
      }
      .themedListSection()
      
    }
    .themedListBG(theme.lists.bg)
    .onChange(of: appIcon) { icon in
      appIconManager.setIcon(icon) { x in
      }
    }
    .onAppear {
      appIcon = appIconManager.current
    }
    .navigationTitle("App icon")
  }
}
