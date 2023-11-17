//
//  TestersCelebration.swift
//  winston
//
//  Created by Igor Marcossi on 18/08/23.
//

import SwiftUI
import ConfettiSwiftUI
import Defaults

struct FAQCel: View {
  var title: String
  var content: String
  var body: some View {
    VStack(spacing: 4) {
      Text(.init(title))
        .fontSize(17, .medium)
        .foregroundColor(.blue)
      Text(.init(content))
        .fontSize(15)
        .opacity(0.9)
    }
  }
}

struct TestersCelebration: View {
  @Environment(\.scenePhase) var scenePhase
  @Environment(\.openURL) var openURL
  @Default(.showTestersCelebrationModal) var showTestersCelebrationModal
  @Default(.showTipJarModal) var showTipJarModal
  @State private var counter: Int = 0
  @State private var thanks = false
  @State private var plans = false
  @State private var spoiler = true
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 16) {
        Text("🥳")
          .fontSize(64)
        
        if thanks {
          Text("Thank you so much!")
            .fontSize(24, .bold)
          
          MasterButton(icon: "balloon.fill", label: "Dismiss modal", color: .green, colorHoverEffect: .animated, textSize: 18, height: 48, cornerRadius: 16, action: {
            withAnimation(spring) {
              showTestersCelebrationModal = false
            }
          })
        } else {
          (
            Text("Winston hit ") + Text("7000").foregroundColor(.yellow) + Text(" testers! (but it needs help)")
          )
          .fontSize(24, .bold)
          Text("We hit 8500 testers on TestFlight and this couldn't make us happier. Thank you so much for using and supporting Winston.")
          Text("However...")
          VStack(spacing: 16) {
            Text("...unfortunately, lo.cafe (the team/group of friends behind Winston) isn't self sustainable yet.\nEven though we have other software for sale, we still have dayjobs.")
            
            Text("Many of you is not aware about our patreon, which has a 1U$ tier. If each of our testers would donate 1U$/month, it'd be more than enough to allow us to focus all our time on Winston and other amazing projects.")
            
            Text("Don't worry if you can't or simply don't wanna donate, we're gonna keep developing Winston anyway and we already love you for being using it ❤️")
            
            VStack {
              Text("Wanna learn more about Winston's situation before donating? Press the button below")
                .fixedSize(horizontal: false, vertical: true)
              VStack(spacing: 16) {
                HStack {
                  Image(systemName: "heart.text.square.fill")
                  Text("Know more about winston")
                }.fontSize(17, .semibold)
                if plans {
                  VStack(spacing: 12) {
                    FAQCel(title: "Is Winston against Reddit's TOS?", content: "Actually **not**, even though Reddit doesn't like it, accordingly to the TOS, the API limits are only applicable when there are profit involved. Winston is open source and free, and it works just like any bot in the internet: by allowing you to use your own API key the way you like it, the way it was supposed to be.")
                    Divider()
                    FAQCel(title: "Will Winston be released in the App Store at some point?", content: "Yes. Reddit is planned to be released in the App Store soon, still allowing users to use their own API key.")
                    Divider()
                    FAQCel(title: "What if Reddit takes Winston down?", content: "Then we'll release another version which uses our own single API key (it won't require any of you to enter your own anymore) and allow you to recharge your account and use it however you like. That's what Reddit wants at the end, but our bet is that Reddit won't find a way to take Winston down because the previously mentioned similarity with a bot in the technical manners.")
                    Divider()
                    FAQCel(title: "Who are you?", content: "We're lo.cafe, a group of friends (Igor (me), Ernesto, Laís, Oeste (teenager cat) and Bidu(old cat)) that produces amazing software together. We made lo-rain, an app that makes it rain over your desktop on MacOS, we're making a game and many other crazy stuff. [Check our website!](https://lo.cafe)")
                  }
                }
              }
              .padding(.horizontal, 18)
              .padding(.vertical, plans ? 18 : 12)
              .background(RR(24, Color("primaryInverted")))
              .contentShape(Rectangle())
              .onTapGesture {
                withAnimation(spring) {
                  plans.toggle()
                }
              }
            }
          }
          .compositingGroup()
          .opacity(spoiler ? 0.55 : 1)
          .blur(radius: spoiler ? 12 : 0)
          .overlay(
            !spoiler
            ? nil
            : VStack {
              Text("It's a long text, we won't spam you with that without your consent.")
                .opacity(0.75)
                .fontSize(14)
              Text("Tap to read")
                .fontSize(16, .medium)
              Image(systemName: "hand.tap.fill")
            }
              .padding(.top, 72)
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
              .contentShape(Rectangle())
              .onTapGesture {
                withAnimation {
                  spoiler = false
                }
              }
          )
        }
      }
      .padding(.bottom, 128)
      .padding(.horizontal, 32)
      .padding(.top, 64)
      .frame(minHeight: UIScreen.screenHeight)
    }
    .overlay(
      thanks
      ? nil
      : HStack {
        MasterButton(icon: "heart.fill", label: "Donate", color: .pink, colorHoverEffect: .animated, textSize: 18, height: 48, fullWidth: true, cornerRadius: 16) {
          openURL(URL(string: "https://patreon.com/user?u=93745105")!)
          withAnimation {
            thanks = true
          }
        }
        
        MasterButton(img: "whiteJar", label: "Tip jar", colorHoverEffect: .animated, textSize: 18, height: 48, fullWidth: true, cornerRadius: 16) {
          openURL(URL(string: "https://ko-fi.com/locafe")!)
          withAnimation {
            thanks = true
          }
        }
      }
        .padding(.bottom, 40)
        .padding(.top, 24)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .bottom)
        .background(
          VStack(spacing: 0) {
            
            Rectangle()
              .fill(.primary.opacity(0.05))
              .frame(maxWidth: .infinity, minHeight: 0.5, maxHeight: 0.5)
            
            Rectangle().fill(.bar)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
            .allowsHitTesting(false)
        )
      , alignment: .bottom
    )
    .closeSheetBtn {
      withAnimation(spring) {
        showTestersCelebrationModal = false
      }
    }
    .ignoresSafeArea(.all)
    .multilineTextAlignment(.center)
    .confettiCannon(counter: $counter, num: 30, openingAngle: Angle.degrees(60), closingAngle: Angle.degrees(120), radius: UIScreen.screenWidth)
    .onAppear {
      if showTipJarModal { showTipJarModal = false }
      doThisAfter(1.0) { withAnimation { counter += 1 } }
    }
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
      if thanks { doThisAfter(0.25) { withAnimation { counter += 1 } } }
    }
  }
}
