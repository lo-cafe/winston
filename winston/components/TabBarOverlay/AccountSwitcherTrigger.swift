//
//  AccountSwitcherTrigger.swift
//  winston
//
//  Created by Igor Marcossi on 27/11/23.
//

import SwiftUI

struct AccountSwitcherTrigger<Content: View>: View {
  @Environment(\.accountSwitcherTransmitter) private var transmitter
  @State private var medium = UIImpactFeedbackGenerator(style: .soft)
  @State private var dragging = false
  @State private var takeScreenshot = false
  
  
  var onTap: (()->())? = nil
  var content: () -> Content
  
  var body: some View {
    content()
      .overlay(RadialMenuTriggerButton(transmitter: transmitter, onTap: onTap, onPressStarted: {
        medium.prepare()
        medium.impactOccurred()
        if !transmitter.showing && transmitter.positionInfo != nil { transmitter.showing = true }
      }, onPressEnded: {
        if transmitter.showing {
          transmitter.showing = false
          return
        }
        transmitter.reset()
      }))
  }
}




struct RadialMenuTriggerButton: UIViewRepresentable {
  var transmitter: AccountSwitcherTransmitter
  var onTap: (() -> Void)? = nil
  var onPressStarted: (() -> Void)? = nil
  var onPressEnded: (() -> Void)? = nil
  var disabled: Bool?
  
  var fingerPos: AccountSwitcherTransmitter.PositionInfo? { get { transmitter.positionInfo } set { transmitter.positionInfo = newValue } }
  var snapshot: UIImage? { get { transmitter.screenshot } set { transmitter.screenshot = newValue } }
  
  func makeUIView(context: Context) -> UIButton {
    let view = TappableUIView()
    if (onTap != nil) {
      addTapAndPressRecognizer(to: view, with: context)
    }
    return view
  }
  
  func updateUIView(_ uiView: UIButton, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  private func addTapAndPressRecognizer(to view: UIButton, with context: Context) {
    let tapRecognizer = UITapGestureRecognizer()
    let pressRecognizer = UILongPressGestureRecognizer()
    pressRecognizer.minimumPressDuration = 0.1
    
    pressRecognizer.delegate = context.coordinator
    pressRecognizer.addTarget(context.coordinator, action: #selector(Coordinator.handleLongPress))
    
    tapRecognizer.delegate = context.coordinator
    tapRecognizer.addTarget(context.coordinator, action: #selector(Coordinator.handleTap))
    
    // Ensure the tap doesn't get recognized if a long press is detected
    tapRecognizer.require(toFail: pressRecognizer)
    
    view.addGestureRecognizer(tapRecognizer)
    view.addGestureRecognizer(pressRecognizer)
  }
  
  class Coordinator: NSObject, UIGestureRecognizerDelegate {
    
    private var parent: RadialMenuTriggerButton
    
    init(parent: RadialMenuTriggerButton) {
      self.parent = parent
    }
    
    
    func takeScreenshotAndSave() {
      guard let view = UIApplication.shared.windows.first?.rootViewController?.view else {
        return
      }
      let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
      let screenshotImage = renderer.image { context in
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
      }
      self.parent.snapshot = screenshotImage
    }
    
    @objc fileprivate func handleTap(_ sender: UITapGestureRecognizer) {
      if case .ended = sender.state {
        self.parent.onTap?()
      }
    }
    //
    @objc fileprivate func handleLongPress(_ sender: UILongPressGestureRecognizer) {
      let location = sender.location(in: UIApplication.shared.windows.first?.rootViewController?.view)
      switch sender.state {
      case .began:
        // Long press recognized, but the finger that hasn't moved yet
        //        parent.onPress?(true)
        takeScreenshotAndSave()
        parent.onPressStarted?()
        parent.fingerPos = .init(location)
      case .changed:
        // Finger has started moving
        parent.fingerPos?.location = location
        //              parent.onDragChanged?({ self.panning = false }, location, location, location)
      case .ended, .cancelled, .failed:
        // Finger is lifted up
        //        parent.onPress?(false)
        parent.onPressEnded?()
      default:
        break
      }
    }
    
  }
}
