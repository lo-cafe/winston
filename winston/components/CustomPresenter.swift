//
//  CustomPresenter.swift
//  winston
//
//  Created by Igor Marcossi on 24/10/23.
//

import SwiftUI

struct ModalPresenter<Content>: UIViewRepresentable where Content: View {
  
  @Binding private var isPresented: Bool
  
  private let content: () -> Content
  private let onDismiss: (() -> Void)?
  private let parentController: UIViewController?
  
  init(
    parentController: UIViewController?,
    isPresented: Binding<Bool>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.parentController = parentController
    self.onDismiss = onDismiss
    self.content = content
    
    _isPresented = isPresented
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  func makeUIView(context: Context) -> UIView {
    let controller = UIViewController()
    parentController?.addChild(controller)
    context.coordinator.controller = controller
    return controller.view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    if isPresented {
      let hc = ModalHostingController(rootView: content())
      hc.modalPresentationStyle = .fullScreen
      hc.modalTransitionStyle = .crossDissolve
      hc.view.backgroundColor = .clear
      hc.dismissHandler = {
        self.isPresented = false
      }
      
      if let controller = context.coordinator.controller {
        DispatchQueue.main.throttle(interval: 1.0, context: controller) {
          controller.present(hc, animated: true)
        }
      }
    }
  }
  
  class Coordinator: NSObject {
    var controller: UIViewController? = nil
  }
}

class ModalHostingController<Content: View> : UIHostingController<Content> {
  var dismissHandler: () -> Void = { }
}

extension View {
  func customPresenter<Content: View>(parentController: UIViewController?, isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
    self
      .background(ModalPresenter(parentController: parentController, isPresented: isPresented, content: content))
  }
}
