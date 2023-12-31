//
//  TappableView.swift
//  winston
//
//  Created by Igor Marcossi on 30/06/23.
//

import Foundation
import SwiftUI

extension UIGestureRecognizer {
  func cancel() {
    isEnabled = false
    isEnabled = true
  }
}

extension UIGestureRecognizer {
  func project(_ velocity: CGFloat, onto position: CGFloat, decelerationRate: UIScrollView.DecelerationRate = .normal) -> CGFloat {
    let factor = -1 / (1000 * log(decelerationRate.rawValue))
    
    return position + factor * velocity
  }
}

struct TappableView: UIViewRepresentable {
  
  enum Directions {
    case vertical
    case horizontal
    case both
  }
  
  var directions: Directions = .both
  var minimumDragDistance: CGFloat? = 0
  var onTap: (() -> Void)? = nil
  var onPress: ((Bool) -> Void)? = nil
  var onPressCancel: (() -> Void)? = nil
  var onDragStarted: ((UIPanGestureRecognizer) -> Void)? = nil
  var onDragChanged: ((() -> Void, CGPoint, CGPoint, CGPoint) -> Void)? = nil
  var onDragEnded: ((CGPoint, CGPoint) -> Void)? = nil
  var disabled: Bool?
  
  private let view = TappableUIView()
  var startLocation: CGPoint? = nil
  var scrolling = false
  var dragOffset: CGFloat = 0
  var dragOffsetX: CGFloat = 0
  var dragOffsetY: CGFloat = 0
  
  func makeUIView(context: Context) -> UIButton {
    if (onTap != nil) {
      addTapRecognizer(to: view, with: context)
    }
    if (onPress != nil) {
      addPressRecognizer(to: view, with: context)
    }
    if (onDragChanged != nil || onDragEnded != nil) {
      addDragRecognizer(to: view, with: context)
    }
    return view
  }
  
  func updateUIView(_ uiView: UIButton, context: Context) {
    
  }
  
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
  
  private func addPressRecognizer(to view: UIButton, with context: Context) {
    let recognizer = UILongPressGestureRecognizer()
    recognizer.delaysTouchesBegan = false
    recognizer.minimumPressDuration = 0
    recognizer.delegate = context.coordinator
    recognizer.addTarget(context.coordinator, action: #selector(Coordinator.handlePress))
    view.addGestureRecognizer(recognizer)
  }
  
  
  private func addDragRecognizer(to view: UIButton, with context: Context) {
    let recognizer = UIPanGestureRecognizer()
    recognizer.delaysTouchesBegan = false
    recognizer.delegate = context.coordinator
    recognizer.addTarget(context.coordinator, action: #selector(Coordinator.handleDrag))
    view.addGestureRecognizer(recognizer)
  }
  
  class Coordinator: NSObject, UIGestureRecognizerDelegate {
    
    private var parent: TappableView
    private var panning = false
    
    init(parent: TappableView) {
      self.parent = parent
    }
    
    @objc fileprivate func handlePress(_ sender: UILongPressGestureRecognizer) {
      switch sender.state {
      case .began: parent.onPress?(true)
      case .changed: parent.onPress?(false)
      case .ended: parent.onPress?(false)
      case .possible, .cancelled, .failed: do {
        self.parent.onPress?(false)
        self.parent.onPressCancel?()
      }
      @unknown default:
        parent.onPress?(false)
      }
    }
    
    @objc fileprivate func handleTap(_ sender: UITapGestureRecognizer) {
      //            let scrolling = parent.isScrolling(sender.location(in: self.parent.view))
      if case .ended = sender.state {
        if !panning {
          parent.onTap?()
        }
      }
    }
    
    @objc fileprivate func handleDrag(_ sender: UIPanGestureRecognizer) {
      let now = sender.translation(in: self.parent.view)
      let velocity = sender.velocity(in: self.parent.view)
      switch sender.state {
      case .began:
        panning = true
//        self.parent.onPress?(false)
        let location = sender.location(in: self.parent.view)
        self.parent.startLocation = location
        if abs(now.x) > parent.minimumDragDistance! {
          parent.dragOffsetX = now.x > 0 ? -parent.minimumDragDistance! : parent.minimumDragDistance!
          parent.dragOffsetY = now.y > 0 ? -parent.minimumDragDistance! : parent.minimumDragDistance!
        }
        parent.onDragChanged?(sender.cancel, CGPoint(x: now.x + parent.dragOffsetX, y: now.y + parent.dragOffsetY), self.parent.startLocation!, CGPoint(x: velocity.x, y: velocity.y))
      case .changed:
        parent.onDragChanged?(sender.cancel, CGPoint(x: now.x + parent.dragOffsetX, y: now.y + parent.dragOffsetY), self.parent.startLocation!, CGPoint(x: velocity.x, y: velocity.y))
      case .ended, .cancelled, .failed, .possible:
        panning = false
        //                print(sender.state == .cancelled ? "lol" : "lel")
        parent.onDragEnded?(CGPoint(x: now.x + parent.dragOffsetX, y: now.y + parent.dragOffsetY), CGPoint(x: velocity.x, y: velocity.y))
        parent.dragOffsetX = 0
        parent.dragOffsetY = 0
        //                sender.cancel()
      @unknown default:
        panning = false
        parent.onDragEnded?(CGPoint(x: now.x + parent.dragOffsetX, y: now.y + parent.dragOffsetY), CGPoint(x: velocity.x, y: velocity.y))
        parent.dragOffsetX = 0
        parent.dragOffsetY = 0
        sender.cancel()
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


class TappableUIView: UIButton {
  
  init() {
    super.init(frame: .zero)
    backgroundColor = .clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
}
