////
////  Gesturer.swift
////  winston
////
////  Created by Igor Marcossi on 03/10/23.
////
//
//import Foundation
//import SwiftUI
////import SwiftUIX
//
//struct GesturerHolder<Content: View>: UIViewRepresentable, Identifiable {
////  static func == (lhs: GesturerHolder<Content>, rhs: GesturerHolder<Content>) -> Bool {
////    lhs.id == rhs.id
////  }
//  
//  enum Directions: String, Equatable {
//    case vertical
//    case horizontal
//    case both
//  }
//  
////  private let view = UIView()
//  private var startLocation: CGPoint? = nil
//  private var scrolling = false
//  private var dragOffset: CGFloat = 0
//  private var dragOffsetX: CGFloat = 0
//  private var dragOffsetY: CGFloat = 0
//  
//  var id: String
//  var size: CGSize
//  var directions: Directions = .both
//  var minimumDragDistance: CGFloat? = 0
//  var onTap: (() -> Void)? = nil
//  var onPress: ((Bool) -> Void)? = nil
//  var onPressCancel: (() -> Void)? = nil
//  var onDragChanged: ((@escaping () -> Void, CGPoint, CGPoint, CGPoint) -> Void)? = nil
//  var onDragEnded: ((CGPoint, CGPoint) -> Void)? = nil
//  var disabled: Bool?
//  @ViewBuilder var content: () -> Content
//  
//    init(id: String, size: CGSize, directions: Directions, minimumDragDistance: CGFloat? = 0, onTap: (() -> Void)? = nil, onPress: ( (Bool) -> Void)? = nil, onPressCancel: ( () -> Void)? = nil, onDragChanged: ( (@escaping () -> Void, CGPoint, CGPoint, CGPoint) -> Void)? = nil, onDragEnded: ( (CGPoint, CGPoint) -> Void)? = nil, disabled: Bool? = nil, @ViewBuilder content: @escaping () -> Content) {
//    self.id = id
//    self.size = size
//    self.directions = directions
//    self.minimumDragDistance = minimumDragDistance
//    self.onTap = onTap
//    self.onPress = onPress
//    self.onPressCancel = onPressCancel
//    self.onDragChanged = onDragChanged
//    self.onDragEnded = onDragEnded
//    self.disabled = disabled
//    self.content = content
//  }
//  
//  func makeUIView(context: Context) -> UICollectionViewCell {
//    
////    let hostingView = UIHostingView(rootView: self.content)
//      let viewCell = UICollectionViewCell()
//      let hostingController = UIHostingConfiguration {
//          content()
//      }
//      viewCell.contentConfiguration = hostingController
////    let hostingController = UIHostingController(rootView: self.content())
////    let contentView = self.content(hostingController)
////    hostingController.rootView = contentView
////      viewCell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////      hostingController.sizingOptions = .intrinsicContentSize
//      viewCell.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//      context.coordinator.view = viewCell.contentView
////    context.coordinator.controller = hostingController
////    context.coordinator.view = hostingView
//    
//      
////    if let view = viewCell.contentView {
//      if (onTap != nil) {
//        addTapRecognizer(to: viewCell.contentView, with: context)
//      }
//      if (onPress != nil) {
//        addPressRecognizer(to: viewCell.contentView, with: context)
//      }
//      if (onDragChanged != nil || onDragEnded != nil) {
//        addDragRecognizer(to: viewCell.contentView, with: context)
//      }
////    }
//      return viewCell
////    return hostingView
//  }
//  
//  func updateUIView(_ viewCell: UICollectionViewCell, context: Context) {
////    hostingController.view.bounds = CGRect(origin: .zero, size: size)
////    hostingController.view.frame = hostingController.view.bounds
////    context.coordinator.view = hostingController.view
////      hostingController.view.setContentHuggingPriority(.defaultHigh, for: .vertical)
////      hostingController.view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
////      hostingController.rootView = self.content()
////      hostingController.sizingOptions = .intrinsicContentSize
//      let hostingController = UIHostingConfiguration {
//          content()
//      }
//      viewCell.contentConfiguration = hostingController
//  }
//  
//  func makeCoordinator() -> Coordinator {
//    Coordinator(parent: self)
//  }
//  
//  private func addTapRecognizer(to view: UIView, with context: Context) {
//    let recognizer = UITapGestureRecognizer()
//    recognizer.delaysTouchesBegan = false
//    recognizer.delegate = context.coordinator
//    recognizer.addTarget(context.coordinator, action: #selector(Coordinator.handleTap))
//    view.addGestureRecognizer(recognizer)
//  }
//  
//  private func addPressRecognizer(to view: UIView, with context: Context) {
//    let recognizer = UILongPressGestureRecognizer()
//    recognizer.delaysTouchesBegan = false
//    recognizer.minimumPressDuration = 0
//    recognizer.delegate = context.coordinator
//    recognizer.addTarget(context.coordinator, action: #selector(Coordinator.handlePress))
//    view.addGestureRecognizer(recognizer)
//  }
//  
//  
//  private func addDragRecognizer(to view: UIView, with context: Context) {
//    let recognizer = UIPanGestureRecognizer()
//    recognizer.delaysTouchesBegan = false
//    recognizer.delegate = context.coordinator
//    recognizer.addTarget(context.coordinator, action: #selector(Coordinator.handleDrag))
//    view.addGestureRecognizer(recognizer)
//  }
//  
//  class Coordinator: NSObject, UIGestureRecognizerDelegate {
//    
////    var hostingConfig: UIHostingConfiguration<Content, EmptyView>
//    private var parent: GesturerHolder
////    var controller: UIHostingController<Content>? = nil
//    private var panning = false
//    var view: UIView? = nil
//    
//    init(parent: GesturerHolder) {
//      self.parent = parent
////      self.hostingConfig = hostingConfig
//    }
//    
//    @objc fileprivate func handlePress(_ sender: UILongPressGestureRecognizer) {
//      switch sender.state {
//      case .began: parent.onPress?(true)
//      case .changed: parent.onPress?(false)
//      case .ended: parent.onPress?(false)
//      case .possible, .cancelled, .failed: do {
//        self.parent.onPress?(false)
//        self.parent.onPressCancel?()
//      }
//      @unknown default:
//        parent.onPress?(false)
//      }
//    }
//    
//    @objc fileprivate func handleTap(_ sender: UITapGestureRecognizer) {
//      if case .ended = sender.state {
//        if !panning {
//          parent.onTap?()
//        }
//      }
//    }
//    
//    @objc fileprivate func handleDrag(_ sender: UIPanGestureRecognizer) {
//      let now = sender.translation(in: self.view)
//      let velocity = sender.velocity(in: self.view)
//      switch sender.state {
//      case .began:
//        panning = true
//        //        self.parent.onPress?(false)
//        let location = sender.location(in: self.view)
//        self.parent.startLocation = location
//        if abs(now.x) > parent.minimumDragDistance! {
//          parent.dragOffsetX = now.x > 0 ? -parent.minimumDragDistance! : parent.minimumDragDistance!
//          parent.dragOffsetY = now.y > 0 ? -parent.minimumDragDistance! : parent.minimumDragDistance!
//        }
//        parent.onDragChanged?(sender.cancel, CGPoint(x: now.x + parent.dragOffsetX, y: now.y + parent.dragOffsetY), self.parent.startLocation!, CGPoint(x: velocity.x, y: velocity.y))
//      case .changed:
//        parent.onDragChanged?(sender.cancel, CGPoint(x: now.x + parent.dragOffsetX, y: now.y + parent.dragOffsetY), self.parent.startLocation!, CGPoint(x: velocity.x, y: velocity.y))
//      case .ended, .cancelled, .failed, .possible:
//        panning = false
//        //                print(sender.state == .cancelled ? "lol" : "lel")
//        parent.onDragEnded?(CGPoint(x: now.x + parent.dragOffsetX, y: now.y + parent.dragOffsetY), CGPoint(x: velocity.x, y: velocity.y))
//        parent.dragOffsetX = 0
//        parent.dragOffsetY = 0
//        //                sender.cancel()
//      @unknown default:
//        panning = false
//        parent.onDragEnded?(CGPoint(x: now.x + parent.dragOffsetX, y: now.y + parent.dragOffsetY), CGPoint(x: velocity.x, y: velocity.y))
//        parent.dragOffsetX = 0
//        parent.dragOffsetY = 0
//        sender.cancel()
//      }
//    }
//    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//      if gestureRecognizer is UITapGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
//        return true
//      }
//      return false
//    }
//    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//      if gestureRecognizer is UIPanGestureRecognizer {
//        return false
//      }
//      return true
//    }
//    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//      if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
//        let velocity = recognizer.velocity(in: recognizer.view)
//        return abs(velocity.x) > abs(velocity.y)
//      }
//      return true
//    }
//  }
//}
//
////
////class TappableUIView: UIView {
////
////  init() {
////    super.init(frame: .zero)
////    backgroundColor = .clear
////  }
////
////  required init?(coder aDecoder: NSCoder) {
////    fatalError()
////  }
////
////}
//
//class SelfSizingHostingController<Content>: UIHostingController<Content> where Content: View {
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.view.invalidateIntrinsicContentSize()
//    }
//}
