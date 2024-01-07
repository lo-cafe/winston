//
//  Onboarding.swift
//  winston
//
//  Created by Igor Marcossi on 31/07/23.
//

import SwiftUI
import Defaults

private let starsCount = 7
private let BG_GRAD_DARK = Color.hex("FFB13D")
private let BG_GRAD_LIGHT = Color.hex("FFCC02")
private let HANG_ANIM = Animation.spring(response: 0.3, dampingFraction: 0.5)
private let ROT_ANIM = Animation.spring(response: 0.4, dampingFraction: 0.25)

struct Onboarding: View {
  @State private var currentTab = 0
  @State var showStars = false
  @State var hanging = true
  @State var hidden = false
  @State var twisted = false
  @State var appID = ""
  @State var appSecret = ""
  @Environment (\.colorScheme) var colorScheme: ColorScheme
  
  @State var tryingToDismiss = false
  
  func nextStep() {
    withAnimation(.spring()) {
      currentTab += 1
    }
  }
  
  func prevStep() {
    withAnimation(.spring()) {
      currentTab -= 1
    }
  }
  
  var body: some View {
    let BG_GRAD = colorScheme == .dark ? BG_GRAD_DARK : BG_GRAD_LIGHT
    TabView(selection: $currentTab) {
      OnboardingWelcomeWrapper(nextStep: nextStep)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture())
        .tag(0)
      OnboardingAPIIntro(prevStep: prevStep, nextStep: nextStep)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture())
        .tag(1)
      Onboarding1OpeningSettings(prevStep: prevStep, nextStep: nextStep)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture())
        .tag(2)
      Onboarding2CreateApp(prevStep: prevStep, nextStep: nextStep)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture())
        .tag(3)
      Onboarding3FillingInfo(prevStep: prevStep, nextStep: nextStep)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture())
        .tag(4)
      Onboarding4GettingAppID(prevStep: prevStep, nextStep: nextStep, appID: $appID)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture())
        .tag(5)
      Onboarding5GettingSecret(prevStep: prevStep, nextStep: nextStep, appSecret: $appSecret)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture())
        .tag(6)
      Onboarding6Auth(prevStep: prevStep, nextStep: nextStep, appSecret: appSecret, appID: appID)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture())
        .tag(7)
      Onboarding7Ending()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture())
        .tag(8)
    }
    .alert(
      "Are you sure?",
      isPresented: $tryingToDismiss
    ) {
      Button(role: .destructive) {
        Defaults[.GeneralDefSettings].onboardingState = .dismissed
        Nav.present(nil)
      } label: {
        Text("Yes").fontWeight(.medium)
      }
    } message: {
      Text("Do you really wanna dismiss the oboarding? You can reopen it later.")
    }
    .closeSheetBtn {
      tryingToDismiss = true
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    //    .padding(.bottom, 16)
    .onChange(of: currentTab) { _ in withAnimation { UIApplication.shared.dismissKeyboard() } }
    .background(
      ZStack {
        if showStars {
          ZStack {
            ForEach(Array(0...starsCount - 1), id: \.self) { number in
              Star(number: number)
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .opacity(1)
          //                    .drawingGroup()
        }
      }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(
          LinearGradient(gradient: Gradient(stops: generateGradientStops(BG_GRAD)), startPoint: .top, endPoint: .bottom)
            .frame(maxWidth: .infinity, maxHeight: colorScheme == .dark ? 175 : .infinity)
            .opacity(colorScheme == .dark ? 0.5 : 1)
          , alignment: .bottom
        )
        .allowsHitTesting(false)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    )
    .ignoresSafeArea(edges: .bottom)
    .onAppear {
      showStars = true
      withAnimation(HANG_ANIM) {
        hanging = false
      }
      withAnimation(ROT_ANIM) {
        twisted = true
      }
    }
    .interactiveDismissDisabled(true)
  }
}



func generateGradientStops(_ color: Color) -> [Gradient.Stop] {
  let opacities = [
    0.0, 0.004, 0.014, 0.03, 0.051, 0.075, 0.102, 0.131, 0.159, 0.188, 0.215, 0.239, 0.26, 0.276, 0.286, 0.29
  ]
  let locations = [
    0.0, 0.081, 0.155, 0.225, 0.29, 0.353, 0.412, 0.471, 0.529, 0.588, 0.647, 0.71, 0.775, 0.845, 0.919, 1.0
  ]
  
  return zip(opacities, locations).map { Gradient.Stop(color: color.opacity($0.0), location: $0.1) }
}

struct Star: View {
  var number: Int
  @State var duration = CGFloat.random(in: 1.25...2)
  @State var up = false
  @State var rotation: CGFloat = 180
  @State var position = CGPoint(x: 0, y: 200 + 42)
  @State var size = CGFloat.rand(10...25)
  @State private var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
  @State private var offset = CGFloat.rand(8...16) * ([-1, 1].randomElement())!
  @Environment (\.colorScheme) var colorScheme: ColorScheme
  
  func move() {
    withAnimation(.easeInOut(duration: duration)) {
      offset = CGFloat.rand(8...16)
      up.toggle()
      rotation = CGFloat.random(in: -20...20)
    }
  }
  
  var body: some View {
    Image(systemName: "star.fill")
      .resizable()
      .scaledToFit()
      .frame(width: size, height: size)
    //            .foregroundColor(Color(NSColor(hex: colorScheme == .dark ? "F9EFBA" : "fafafa")))
      .foregroundColor(Color.hex(colorScheme == .dark ? "F9EFBA" : "7B733C"))
      .rotationEffect(Angle(degrees: rotation))
    //            .shadow(color: Color(NSColor(hex: colorScheme == .dark ? "FFA262" : "656565")), radius: size * 0.75, y: colorScheme == .dark ? 0 : size * 0.5)
      .shadow(color: Color.hex(colorScheme == .dark ? "FFA262" : "A9A400"), radius: size * 0.75, y: colorScheme == .dark ? 0 : size * 0.5)
      .shadow(color: Color.hex(colorScheme == .dark ? "FFA262" : "A9A400").opacity(0.75), radius: size * 0.75, y: colorScheme == .dark ? 0 : size * 0.5)
      .offset(y: up ? offset : 0)
      .position(position)
      .onReceive(timer) { _ in
        move()
      }
      .onAppear {
        timer.upstream.connect().cancel()
        position.x = (((.screenW - 48) / CGFloat(starsCount - 1)) * CGFloat(number)) + 24 + (CGFloat.rand(0...24) * ([-1, 1].randomElement())!)
        DispatchQueue.main.asyncAfter(deadline: .now() + CGFloat.random(in: 0...0.75)) {
          timer = Timer.publish(every: duration, on: .current, in: .common).autoconnect()
          move()
          withAnimation(.spring(response: CGFloat.random(in: 0.5...0.7), dampingFraction: 2)) {
            position.y = CGFloat.rand(50...CGFloat(200 - Int(size) - 30))
          }
        }
      }
      .onDisappear { timer.upstream.connect().cancel() }
  }
}

extension CGFloat {
  static func random(_ range1: ClosedRange<CGFloat>, _ range2: ClosedRange<CGFloat>) -> CGFloat {
    let ranges = [range1, range2]
    let selectedRange = ranges.randomElement()!
    return CGFloat.random(in: selectedRange)
  }
  static func rand(_ range: ClosedRange<CGFloat>) -> CGFloat {
    return CGFloat(arc4random_uniform(UInt32(range.upperBound - range.lowerBound) + 1) + UInt32(range.lowerBound))
  }
}
