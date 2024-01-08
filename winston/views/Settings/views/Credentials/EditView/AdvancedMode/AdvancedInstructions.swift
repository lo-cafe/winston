//
//  AdvancedInstructions.swift
//  winston
//
//  Created by Igor Marcossi on 07/01/24.
//

import SwiftUI
import Lottie

struct AdvancedInstructions: View {
  @State private var open = false
  @State private var copied = false
  //  @State private var playbackMode: LottiePlaybackMode = .paused(at: .progress(0))
  @Environment(\.colorScheme) private var cs
  var body: some View {
    let rgb = UIColor(cs == .dark ? .white : .black).rgb
    let colorProvider = ColorValueProvider(.init(r: rgb.0, g: rgb.1, b: rgb.2, a: 1))
    VStack(alignment: .leading, spacing: 0) {
      
      PressableButton(animation: .easeIn(duration: 0.15)) {
        withAnimation(.spring) { open.toggle() }
      } label: { pressed in
        HStack(spacing: 0) {
          HStack(spacing: 8) {
            
            LottieSwitch(animation: .named("book-opening"))
              .isOn($open)
              .valueProvider(colorProvider, for: colorLottieKeypath)
              .configuration(.init(renderingEngine: .coreAnimation))
              .frame(22)
            
            Text("Instructions").fontSize(18, .medium)
          }
          
          Spacer()
          
          Image(systemName: "chevron.right")
            .fontSize(16, .semibold)
            .rotationEffect(.degrees(open ? 90 : 0))
            .opacity(0.35)
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .simpleHighlight(pressed)
        .contentShape(Rectangle())
      }
      
      if open {
        Divider()
        
        VStack(alignment: .leading, spacing: 6) {
          Text("**1.** Open Reddit API settings")
          Text("**2.** Check the **\"web app\"** option")
          Text("**3.** Fill the **\"redirect uri\"** with this:")
          WinstonButton(config: .secondary(fullWidth: true)) {
            withAnimation(.spring) {
              UIPasteboard.general.string = RedditAPI.appRedirectURI
              copied.toggle()
            }
            Hap.shared.play(intensity: 0.75, sharpness: 0.35)
            doThisAfter(0.225) {
              Hap.shared.play(intensity: 1, sharpness: 1)
            }
          } label: {
            HStack {
              Image(systemName: "doc.on.clipboard.fill")
                .symbolEffect(.bounce, value: copied)
              Text("Copy **redirect uri**")
            }
          }
          .padding(.vertical, 2)
          
          Text("**4.** Fill up the form below and follow next instructions.")
          
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .frame(maxWidth: .infinity)
      }
      
    }
    .themedListRowLikeBG()
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }
}

extension LottieSwitch {
  func colorValueProviders(_ colorValueProviders: [String: [Keyframe<LottieColor>]]) -> Self {
    var copy = self

    for (keypath, keyframes) in colorValueProviders {
      copy = copy.valueProvider(
        ColorValueProvider(keyframes),
        for: AnimationKeypath(keypath: keypath))
    }

    return copy
  }
}
