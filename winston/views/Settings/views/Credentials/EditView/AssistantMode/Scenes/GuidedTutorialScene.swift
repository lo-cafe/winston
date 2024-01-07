//
//  GuidedTutorialScene.swift
//  winston
//
//  Created by Igor Marcossi on 04/01/24.
//

import SwiftUI
import AVKit



struct GuidedTutorialScene: View {  
  weak var player: AVLooperPlayer?
  let enableEmptyView: ()->()
  @State private var seeingPlayer = false
  @Environment(\.openURL) private var openURL
  @Environment(\.useTheme) private var theme
  
  
  var body: some View {
    ScrollView {
      VStack(alignment: .center, spacing: 24) {
        
        VStack(alignment: .center, spacing: 12) {
          Image(.winstonSide).size(104, .fit)
          
          VStack(alignment: .center, spacing: 4) {
            Text("Enabling the extension").fontSize(32, .bold)
            Text("We built a Safari extension to help you generating the credentials. Let's enable it!")
          }
          .padding(.horizontal, 24)
        }
        
        VStack(alignment: .center, spacing: 20) {
          VStack(alignment: .center, spacing: 16) {
            VStack(alignment: .center, spacing: 2) {
              Text("Click the button and follow the video").fontSize(20, .semibold)
              Text("You can tap the video to pause it.").fontSize(13).opacity(0.65)
            }
            .padding(.horizontal, 16)
            
            WinstonButton(config: .secondary(fullWidth: true)) {
              enableEmptyView()
              openURL(redditApiSettingsUrl)
            } label: {
              Label("Go to Reddit API settings", systemImage: "link")
            }
            
          }
          .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))
          
          if let player {
            VideoPlayer(player: player)
              .aspectRatio(16/9, contentMode: .fill)
              .frame(maxWidth: .infinity)
              .overlay(Color.black.opacity(seeingPlayer ? 0 : 0.5).allowsHitTesting(false))
              .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
              .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                  .stroke(Color.primary.opacity(0.075), lineWidth: 1)
                  .padding(EdgeInsets(top: 0.5, leading: 1, bottom: 0.5, trailing: 1))
              }
              .scaleEffect(seeingPlayer ? 1 : 0.9)
              .blur(radius: seeingPlayer ? 0 : 24)
              .allowsHitTesting(seeingPlayer)
              .overlay {
                if !seeingPlayer {
                  Label("Tap to start a demo video", systemImage: "play.circle.fill")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                      player.play()
                      withAnimation(.spring) { seeingPlayer = true }
                    }
                    .transition(.scaleAndBlur)
                }
              }
          }

        }
        .themedListRowLikeBG()
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
        
      }
      .padding(EdgeInsets(top: 8, leading: 0, bottom: 72, trailing: 0))
    }
    .themedListBG(theme.lists.bg)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color.hitbox)

    //    .gesture(selectedQuestion == nil ? nil : TapGesture().onEnded { withAnimation(.snappy) { selectedQuestion = nil } })
    .contentShape(Rectangle())
    .multilineTextAlignment(.center)
    
  }
}


