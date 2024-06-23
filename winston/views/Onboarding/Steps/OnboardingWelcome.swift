//
//  OnboardingWelcome.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import SwiftUI



struct OnboardingWelcome: View {
  var nextStep: ()->()
  @State var showCat = false
  @State var showMeow = false
  @State var showHello = false
  @State var showAppName = false
  @State var showBtn = false
  @State var showText = false
  var body: some View {
    VStack(spacing: 20) {
      VStack(spacing: 12) {
        if showCat {
          Image(.winstonNoBG)
            .resizable()
            .scaledToFit()
            .frame(height: 128)
            .transition(.scaleAndBlur)
        }
        
        VStack(spacing: -2) {
          if showMeow || showHello {
            Text(showHello ? "I mean, hello!" : "Meow!")
              .foregroundColor(showHello ? .primary.opacity(0.75) : .yellow)
              .fontSize(showHello ? 20 : 24, showHello ? .medium : .bold)
              .id(showHello ? "Hello!" : "Meow")
              .transition(.scaleAndBlur)
          }
          
          if showAppName {
            (Text("I'm ").font(Font.system(size: 24, weight: .semibold)).foregroundColor(.primary.opacity(0.75)) + Text("Winston").font(Font.system(size: 34, weight: .bold)).foregroundColor(.yellow))
              .transition(.scaleAndBlur)
          }
        }
        
        if showText {
          Text("I'm a beautiful beta client (made with A BUNCH of love) for Reddit where you can use your own API key.")
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 300)
            .transition(.opacity)
        }
      }
        
        if showBtn {
          MasterButton(label: "👋 Hi, Winston!", colorHoverEffect: .animated, textSize: 18, height: 48, cornerRadius: 16, action: nextStep)
            .padding(.top, 16)
            .transition(.scaleAndBlur)
        }
      

    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
    .onAppear {
      if !showCat {
        doThisAfter(0.5) {
          withAnimation(spring) { showCat = true }
          doThisAfter(0.85) {
            withAnimation(spring) { showMeow = true }
            doThisAfter(0.75) {
              withAnimation(spring) { showHello = true }
              doThisAfter(1.25) {
                withAnimation(spring) { showAppName = true }
                doThisAfter(1.0) {
                  withAnimation(spring) { showText = true }
                  doThisAfter(1.25) {
                    withAnimation(spring) { showBtn = true }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

struct OnboardingWelcomeWrapper: View {
  var nextStep: ()->()

  var body: some View {
    VStack {
      OnboardingWelcome(nextStep: nextStep)
    }
  }
}
//
//struct OnboardingWelcome_Previews: PreviewProvider {
//  static var previews: some View {
//    OnboardingWelcome()
//  }
//}
