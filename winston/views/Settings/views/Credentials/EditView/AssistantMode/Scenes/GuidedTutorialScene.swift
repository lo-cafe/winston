//
//  GuidedTutorialScene.swift
//  winston
//
//  Created by Igor Marcossi on 04/01/24.
//

import SwiftUI
import AVKit

let questions: [PeakQuestion] = [
  .init(question: "Why do I need an extension?", answer: "To make easy the process of generating a new API credentials in your Reddit account."),
  .init(question: "What permissions are required?", answer: "The extension have 2 jobs, to allow reddit links to open in Winston, which requires access to all sites, and to show an assistant in your API credentials settings page."),
  .init(question: "Will it steal my data?", answer: "No. But the code is open source, so you can check yourself if you want, or ask about it in our Discord server. Links for both the code and the server are in **About** section in **Settings** tab.")
]

struct GuidedTutorialScene: View {
  @State private var player = AVLooperPlayer(url: Bundle.main.url(forResource: "auth-ext", withExtension: "mov")!)
  @Environment(\.openURL) private var openURL
  @Environment(\.useTheme) private var theme
  
  
  var body: some View {
    ScrollView {
      VStack(alignment: .center, spacing: 16) {
        
        Image(.winstonSide).size(104, .fit)
        
        VStack(alignment: .center, spacing: 4) {
          Text("Enabling the extension").fontSize(32, .bold)
          Text("We built a Safari extension to help you generating the credentials. Let's enable it!")
        }
        .padding(.horizontal, 24)
        
        VStack(alignment: .center, spacing: 20) {
          VStack(alignment: .center, spacing: 16) {
            VStack(alignment: .center, spacing: 2) {
              Text("Click the button and follow the video").fontSize(20, .semibold)
              Text("You can tap the video to pause it.").fontSize(13).opacity(0.65)
            }
            .padding(.horizontal, 16)
            
            Button("Go to Reddit API settings", systemImage: "link") {
              openURL(redditApiSettingsUrl)
            }
            .buttonStyle(SecondaryActionButtonPrimitive.Style(fullWidth: true))
          }
          .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))
          
          VideoPlayer(player: player)
            .aspectRatio(16/9, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
              RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primary.opacity(0.075), lineWidth: 1)
                .padding(EdgeInsets(top: 0.5, leading: 1, bottom: 0.5, trailing: 1))
            }
            .onAppear { player.play() }
          //            .allowsHitTesting(false)
          //            .contentShape(Rectangle())
          //            .onTapGesture { player.togglePlaying() }
        }
        .themedListRowLikeBG()
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
        
        //        PeakQuestionsScroller(peakQuestions: questions)
        //          .padding(.horizontal, 24)
        
      }
      .padding(EdgeInsets(top: 8, leading: 0, bottom: 72, trailing: 0))
    }
    .themedListBG(theme.lists.bg)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color.hitbox)
    .overlay(alignment: .bottom) {
      GeometryReader { _ in
        PeakQuestionsOverlay(peakQuestions: questions)
      }
      .ignoresSafeArea(.all)
    }
    //    .gesture(selectedQuestion == nil ? nil : TapGesture().onEnded { withAnimation(.snappy) { selectedQuestion = nil } })
    .contentShape(Rectangle())
    .multilineTextAlignment(.center)
    
  }
}


