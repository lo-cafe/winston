//
//  TabBarOverlay.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import SwiftUI



struct TabBarOverlay: View {
  var meTabTap: () -> ()
  
  @State private var bottomSafeArea = getSafeArea().bottom
  
  @Environment(\.tabBarHeight) private var tabBarHeight
  var body: some View {
    if let tabBarHeight {
      GeometryReader { geo in
        let overlaySize = CGSize(width: geo.size.width, height: max(0, (tabBarHeight)))
        HStack(spacing: 0) {
          ForEach(Nav.TabIdentifier.allCases, id: \.rawValue) { tab in
            if tab == .me {
              AccountSwitcherTrigger(onTap: { Nav.shared.activeTab = .me }) {
                Color.clear
                  .frame(width: .screenW / 5, height: max(0, (tabBarHeight)))
                  .background(Color.hitbox)
                  .contentShape(Rectangle())
              }
            } else {
              Color.clear
                .frame(width: .screenW / 5, height: max(0, (tabBarHeight)))
                .background(Color.hitbox)
                .contentShape(Rectangle())
                .overlay { SimpleTappableView { Nav.shared.activeTab = tab } }
            }
          }
        }
        .frame(overlaySize)
        .swipeAnywhere(size: overlaySize)
        .frame(overlaySize)
        .contentShape(Rectangle())
        .padding(.bottom, bottomSafeArea)
        .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
      }
      .ignoresSafeArea(.all)
    }
  }
}


struct SimpleTappableView: UIViewRepresentable {
  var onTap: () -> Void
  
  private let view = TappableUIView()
  
  func makeUIView(context: Context) -> UIButton {
    addTapRecognizer(to: view, with: context)
    return view
  }
  
  func updateUIView(_ uiView: UIButton, context: Context) { }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  private func addTapRecognizer(to view: UIButton, with context: Context) {
    let recognizer = UITapGestureRecognizer()
    recognizer.delaysTouchesBegan = false
    recognizer.delegate = context.coordinator
    recognizer.addTarget(context.coordinator, action: #selector(Coordinator.handleTap))
    view.addGestureRecognizer(recognizer)
  }
  
  class Coordinator: NSObject, UIGestureRecognizerDelegate {
    
    private var parent: SimpleTappableView
    
    init(parent: SimpleTappableView) {
      self.parent = parent
    }
    
    @objc fileprivate func handleTap(_ sender: UITapGestureRecognizer) {
      if case .ended = sender.state {
        parent.onTap()
      }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      if gestureRecognizer is UITapGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
        return true
      }
      return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      if gestureRecognizer is UIPanGestureRecognizer {
        return false
      }
      return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
      if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
        let velocity = recognizer.velocity(in: recognizer.view)
        return abs(velocity.x) > abs(velocity.y)
      }
      return true
    }
  }
}
