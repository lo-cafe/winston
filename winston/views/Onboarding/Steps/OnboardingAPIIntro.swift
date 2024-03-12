//
//  OnboardingAPIIntro.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import SwiftUI

private struct Feature: View {
  var icon: String
  var title: String
  var description: String
  @Environment (\.colorScheme) var colorScheme: ColorScheme
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .foregroundColor(.blue)
        .fontSize(32, .semibold)
        .frame(width: 40)
      VStack(alignment: .leading, spacing: 0) {
        Text(.init(title))
          .fontSize(17, .semibold)
        
        Text(.init(description))
          .fontSize(15)
          .opacity(0.75)
      }
    }
    .padding(.leading, 12)
    .padding(.vertical, 12)
    .padding(.trailing, 16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(RR(16, Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05)))
  }
}

struct OnboardingAPIIntro: View {
  var prevStep: ()->()
  var nextStep: ()->()
  var body: some View {
    ScrollView {
      VStack(spacing: 24) {

        VStack {
          Text("First, I need an API key")
            .fontSize(24, .semibold)
          Text("To use Reddit, Winston uses a special key you can generate yourself in Reddit's site.")
            .opacity(0.75)
        }
        .multilineTextAlignment(.center)
        
        VStack(spacing: 6) {
          Feature(icon: "arrow.up", title: "Huge limit", description: "Reddit API limit is 100 requests per second, it's impossible to reach.")
          Feature(icon: "dollarsign", title: "No costs at all", description: "Even if you pass the limit, there will be no charges, you only get an error.")
          Feature(icon: "point.topleft.down.curvedto.point.bottomright.up.fill", title: "Easy to setup", description: "It's really easy to get set Winston up. We'll guide all the way!")
          Feature(icon: "eye.slash.fill", title: "Safe and private", description: "The key is **only** stored in your iCloud keychain, we can't read it.")
        }
        
        MasterButton(label: "Ok then, guide me", colorHoverEffect: .animated, textSize: 18, height: 48, fullWidth: true, cornerRadius: 16, action: {
          Nav.present(.editingCredential(.init()))
        })
          .padding(.top, 32)
      }
      .padding(.top, 64)
      .padding(.horizontal, 16)
    }
  }
}
