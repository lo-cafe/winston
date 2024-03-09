//
//  Changelogger.swift
//  winston
//
//  Created by Igor Marcossi on 24/02/24.
//

import SwiftUI

struct Changelogger: View {
  var releases: [ChangelogRelease]
  @State private var bgActive = false
  @State private var active = false
  @State private var screenshot: UIImage? = nil
  @State private var openRelease: ChangelogRelease? = nil
  @State private var lastOpenRelease: ChangelogRelease? = nil
  @Namespace private var ns
  
  let bgItemsOpacity = 0.15
  let releaseOpeningAnimation: Animation = .smooth(duration: 0.5, extraBounce: 0.3)
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      
      LazyVStack(alignment: .center, spacing: 24) {
        VStack(alignment: .center, spacing: 8) {
          PlayableLottieView("newspaper", size: 80, color: .changelogYellow, progress: active ? 1 : 0)
          VStack(alignment: .center, spacing: 0) {
            Text("What's new?").fontSize(32, .bold, design: .rounded)
            Text("Isn't this app beautiful?").fontSize(16, .regular, design: .rounded).opacity(0.75)
          }
          .offset(y: active ? 0 : 24)
          .opacity(active ? 1 : 0)
        }
        .opacity(openRelease != nil ? bgItemsOpacity : 1)
        
        
        if active {
          VStack {
            ChangeloggerRelease(release: releases[0], ns: ns, small: false, hidden: openRelease == releases[0]) {
              withAnimation(releaseOpeningAnimation) { openRelease = releases[0]; lastOpenRelease = releases[0]; }
            }
            .opacity(openRelease != nil && openRelease != releases[0] ? bgItemsOpacity : 1)
          }
          .transition(.comeFrom(.bottom, index: 1, total: 4, disableEndDelay: true, disableScale: true))
          .zIndex(lastOpenRelease == releases[0] ? 999 : 2)
          
          Text("What about the past?").fontSize(24, .medium, design: .rounded)
            .opacity(openRelease != nil ? bgItemsOpacity : 1)
            .transition(.comeFrom(.bottom, index: 2, total: 4, disableEndDelay: true, disableScale: true))
          
          VStack(alignment: .center, spacing: 16) {
            ForEach(Array(Array(releases.dropFirst()).enumerated()), id: \.element) { i, release in
              ChangeloggerRelease(release: release, ns: ns, hidden: openRelease == release) {
                withAnimation(releaseOpeningAnimation) { openRelease = release; lastOpenRelease = release; }
              }
              .opacity(openRelease != nil && openRelease != release ? bgItemsOpacity : 1)
              .scrollTransition(topLeading: .identity, bottomTrailing: .interactive) { content, phase in
                content
                  .opacity(phase.isIdentity ? 1 : 0)
                  .scaleEffect(phase.isIdentity ? 1 : 0.75, anchor: .bottom)
                  .offset(y: phase.isIdentity ? 0 : -125)
              }
              .zIndex(lastOpenRelease == release ? 999 : Double(releases.count - i))
              
            }
          }
          .transition(.comeFrom(.bottom, index: 3, total: 4, disableEndDelay: true, disableScale: true))
          .zIndex(lastOpenRelease == releases[0] ? 0 : 3)
        }
      }
      .padding(.top, 64 + 56)
      .padding(.horizontal, 24)
      .frame(maxWidth: .infinity, minHeight: .screenH, alignment: .top)
    }
    .frame(maxWidth: 600, maxHeight: .infinity, alignment: .top)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .overlay(alignment: .topLeading) {
      ZStack {
        if active {
          Button {
            withAnimation(.easeIn) { bgActive = false; active = false; }
          } label: {
            Image(systemName: "xmark.circle.fill")
              .fontSize(32)
              .symbolRenderingMode(.hierarchical)
              .foregroundStyle(.primary.opacity(0.5))
              .background(Circle().fill(Material.bar).padding(.all, 2.5))
          }
          .buttonStyle(.plain)
          .transition(.scale.combined(with: .opacity).animation(.easeOut.speed(2)))
        }
      }
      .padding(.top, 56)
      .padding(.all, 16)
    }
    .allowsHitTesting(openRelease == nil)
    .overlay {
      if let openRelease {
        ChangeloggerRelease(release: openRelease, ns: ns, small: openRelease != releases[0], open: true) {
          withAnimation(releaseOpeningAnimation) {
            self.openRelease = nil
          } completion: {
            lastOpenRelease = nil
          }
        }
      }
    }
    .overlay(alignment: .topTrailing) {
      if active {
        Ribbon()
      }
    }
    .background(Color.hex("161616").opacity(active ? 0.65 : 0))
    .background {
      if let screenshot {
        Image(uiImage: screenshot)
          .resizable()
          .scaledToFill()
          .frame(maxWidth: .infinity,  maxHeight: .infinity)
          .blur(radius: active ? 20 : 0)
          .saturation(active ? 2 : 1)
          .background(.primaryInverted)
          .onAppear {
            withAnimation(.spring) { active = true }
            //            active = true
          }
      }
    }
    .onAppear {
      screenshot = takeScreenshotAndSave()
    }
    .transition(.identity)
  }
}
