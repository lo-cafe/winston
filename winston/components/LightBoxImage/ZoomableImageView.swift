//
//  ZoomableImageView.swift
//  winston
//
//  Created by Daniel Inama on 27/08/23.
//

import Foundation
import UIKit
import SwiftUI

//Source https://stackoverflow.com/a/64110231
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content
    private var onTap: (()->())?
    @Binding var isZoomed: Bool // Add the binding parameter
    
    init(onTap: (()->())? = nil,isZoomed: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        //set up helper class
        self.onTap = onTap
        self._isZoomed = isZoomed // Initialize the binding
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // create a UIHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        scrollView.addSubview(hostedView)
        
        
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.require(toFail: doubleTapGesture)
        scrollView.addGestureRecognizer(tapGesture)
        
        return scrollView
    }
    
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content), onTap: self.onTap, isZoomed: $isZoomed)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        var onTap: (() -> ())?
        @Binding var isZoomed: Bool // Use the binding here
        
        
        init(hostingController: UIHostingController<Content>, onTap: (() -> ())? = nil, isZoomed: Binding<Bool>) {
            self.hostingController = hostingController
            self.onTap = onTap
            _isZoomed = isZoomed
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            isZoomed = scrollView.zoomScale > scrollView.minimumZoomScale
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            onTap?()
        }
        
        @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if let scrollView = gestureRecognizer.view as? UIScrollView {
                if scrollView.zoomScale == 1 {
                    let tapLocation = gestureRecognizer.location(in: scrollView   )
                    //CGPoint(x: tapLocation.x / 1.35, y: tapLocation.y * 0.87) -- Magic numbers go brrrr
                    let zoomRect = CGRect(origin: CGPoint(x: tapLocation.x / 1.35, y: tapLocation.y * 0.87), size: CGSize(width: 100, height: 100))
                    scrollView.zoom(to: zoomRect, animated: true)
                } else {
                    scrollView.setZoomScale(1, animated: true)
                }
            }
        }
        
//        func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            let offsetY = scrollView.contentOffset.y
//            let contentHeight = scrollView.contentSize.height
//            let scrollViewHeight = scrollView.bounds.height
//            print()
//            print(offsetY)
//            
//            if offsetY < (contentHeight / 2) || offsetY > (contentHeight / 2) {
//                scrollView.setContentOffset(CGPoint(x: 0, y: contentHeight - scrollViewHeight), animated: false)
//            }
//        }
    }
    
}


