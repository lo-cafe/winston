import UIKit
import SwiftUI

class PinchZoomView: UIView, UIGestureRecognizerDelegate {
    weak var delegate: PinchZoomViewDelgate?
  
  private(set) var scale: CGFloat = 1 {
    didSet {
      if scale == 1 && panGesture?.isEnabled == true {
        panGesture?.isEnabled = false
      } else if panGesture?.isEnabled == false {
        panGesture?.isEnabled = true
      }
      delegate?.pinchZoomView(self, didChangeScale: scale)
    }
  }
  
  private(set) var anchor: UnitPoint = .center {
    didSet {
      delegate?.pinchZoomView(self, didChangeAnchor: anchor)
    }
  }
  
  private(set) var offset: CGSize = .zero {
    didSet {
      delegate?.pinchZoomView(self, didChangeOffset: offset)
    }
  }
  
  private(set) var isPinching: Bool = false {
    didSet {
      delegate?.pinchZoomView(self, didChangePinching: isPinching)
    }
  }
  
  private var imgSize: CGSize
  
  private var startLocation: CGPoint = .zero
  private var startOffset: CGSize = .zero
  private var location: CGPoint = .zero
  private var numberOfTouches: Int = 0
  private var panGesture: UIPanGestureRecognizer?
  private var onTap: (()->())?
  
  init(imgSize: CGSize, onTap: (()->())?) {
    self.onTap = onTap
    self.imgSize = CGSize(width: UIScreen.screenWidth, height: (UIScreen.screenWidth * imgSize.height) / imgSize.width)
    super.init(frame: .zero)
    
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
    pinchGesture.cancelsTouchesInView = false
    addGestureRecognizer(pinchGesture)
    
    let newPanGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
    newPanGesture.isEnabled = false
    panGesture = newPanGesture
    addGestureRecognizer(newPanGesture)
    
    if onTap != nil {
      let doubleTap = UIShortTapGestureRecognizer(target: self, action: #selector(doubleTap(gesture:)))
      doubleTap.numberOfTapsRequired = 2
      addGestureRecognizer(doubleTap)

      let monoTap = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
      monoTap.require(toFail: doubleTap)
      monoTap.numberOfTapsRequired = 1
      addGestureRecognizer(monoTap)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  @objc private func tap(gesture: UITapGestureRecognizer) {
    self.onTap?()
  }
  
  @objc private func doubleTap(gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: self)
    
    let imageHeight = imgSize.height
    let imageWidth = imgSize.width
    let scaledImageHeight = imageHeight * scale
    let scaledImageWidth = imageWidth * scale
    
    let overFlowFromCenterTopHeight = max(0, (scaledImageHeight - imageHeight) * CGFloat(anchor.y)) - offset.height
//    let overFlowFromCenterLeftWidth = max(0, (scaledImageWidth - imageWidth) * CGFloat(anchor.x)) - offset.width
    let blackAreaLeft = -(max(0, (scaledImageWidth - UIScreen.screenWidth) * CGFloat(anchor.x)) - offset.width)
    let blackAreaTop = ((UIScreen.screenHeight - imgSize.height) / 2) - overFlowFromCenterTopHeight
    
    let newAnchor = UnitPoint(x: (location.x + -blackAreaLeft) / scaledImageWidth, y: (location.y + -blackAreaTop) / scaledImageHeight)
    
    if scale <= 1 {
      anchor = newAnchor
    }
    withAnimation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0)) {
      if scale > 1 {
        scale = 1
        offset = .zero
      } else {
        scale = 2.5
      }
    }
  }
  
  @objc private func pan(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .began:
      startOffset = offset
    case .changed:
      let translation = gesture.translation(in: self)
      withAnimation(draggingAnimation) {
        offset = CGSize(width: startOffset.width + translation.x, height: startOffset.height + translation.y)
      }
    case .ended:
      func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
          return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate)
      }
      let translation = gesture.translation(in: self)
      let velocity = gesture.velocity(in: self)
      let disX = project(initialVelocity: velocity.x, decelerationRate: UIScrollView.DecelerationRate.fast.rawValue)
      let disY = project(initialVelocity: velocity.y, decelerationRate: UIScrollView.DecelerationRate.fast.rawValue)
      
      let finalOffset = CGSize(width: startOffset.width + translation.x + disX, height: startOffset.height + translation.y + disY)
      
      let imageHeight = imgSize.height
      let imageWidth = imgSize.width
      let scaledImageHeight = imageHeight * scale
      let scaledImageWidth = imageWidth * scale
      
      let overFlowFromCenterTopHeight = max(0, (scaledImageHeight - imageHeight) * CGFloat(anchor.y)) - finalOffset.height
      let blackAreaLeft = -(max(0, (scaledImageWidth - UIScreen.screenWidth) * CGFloat(anchor.x)) - finalOffset.width)
      let blackAreaTop = ((UIScreen.screenHeight - imgSize.height) / 2) - overFlowFromCenterTopHeight
      let blackAreaRight = blackAreaLeft < 0 ? UIScreen.screenWidth - (scaledImageWidth + blackAreaLeft) : 0
      let blackAreaBot = -(scaledImageHeight - (UIScreen.screenHeight - blackAreaTop))
      
      var newOffset = finalOffset
      
      if scaledImageHeight <= UIScreen.screenHeight {
        let move = (blackAreaBot - blackAreaTop) / 2
        newOffset.height += move
      } else {
        if blackAreaTop > 0 { newOffset.height -= blackAreaTop } else
        if blackAreaBot > 0 { newOffset.height += blackAreaBot }
      }
      
      if scaledImageWidth <= UIScreen.screenWidth {
        let move = (blackAreaRight - blackAreaLeft) / 2
        newOffset.width += move
      } else {
        if blackAreaLeft > 0 {newOffset.width -= blackAreaLeft  } else
        if blackAreaRight > 0 { newOffset.width += blackAreaRight }
      }

      withAnimation(.interpolatingSpring(stiffness: 300, damping: 30, initialVelocity: max(abs(velocity.x), abs(velocity.y)) / 1000.0)) {
        offset = scale <= 1 ? .zero : newOffset
      }
    default:
      break
    }
  }
  
  @objc private func pinch(gesture: UIPinchGestureRecognizer) {
    
    switch gesture.state {
    case .began:
      startLocation = gesture.location(in: self)
      gesture.scale = scale
      startOffset = offset
      
      let imageHeight = imgSize.height
      let imageWidth = imgSize.width
      let scaledImageHeight = imageHeight * scale
      let scaledImageWidth = imageWidth * scale
      
      let overFlowFromCenterTopHeight = max(0, (scaledImageHeight - imageHeight) * CGFloat(anchor.y)) - offset.height
      let overFlowFromCenterLeftWidth = max(0, (scaledImageWidth - imageWidth) * CGFloat(anchor.x)) - offset.width
      let blackAreaLeft = -(max(0, (scaledImageWidth - UIScreen.screenWidth) * CGFloat(anchor.x)) - offset.width)
      let blackAreaTop = ((UIScreen.screenHeight - imgSize.height) / 2) - overFlowFromCenterTopHeight
//      let blackAreaRight = blackAreaLeft < 0 ? UIScreen.screenWidth - (scaledImageWidth + blackAreaLeft) : 0
//      let blackAreaBot = -(scaledImageHeight - UIScreen.screenHeight - blackAreaTop)
      
      let newAnchor = UnitPoint(x: (startLocation.x + -blackAreaLeft) / scaledImageWidth, y: (startLocation.y + -blackAreaTop) / scaledImageHeight)
      
      let newOverFlowFromCenterTopHeight = max(0, (scaledImageHeight - imageHeight) * CGFloat(newAnchor.y)) - offset.height
      let newOverFlowFromCenterLeftWidth = max(0, (scaledImageWidth - imageWidth) * CGFloat(newAnchor.x)) - offset.width
      let diffX = overFlowFromCenterLeftWidth - newOverFlowFromCenterLeftWidth
      let diffY = overFlowFromCenterTopHeight - newOverFlowFromCenterTopHeight
      
      let newOffset = CGSize(width: offset.width - diffX, height: offset.height - diffY)
      (startOffset, offset, isPinching, anchor, numberOfTouches) = (newOffset, newOffset, true, newAnchor, gesture.numberOfTouches)
      
    case .changed:
      if gesture.numberOfTouches != numberOfTouches {
        // If the number of fingers being used changes, the start location needs to be adjusted to avoid jumping.
        let newLocation = gesture.location(in: self)
        let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
        startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)
        
        numberOfTouches = gesture.numberOfTouches
      }
      
      scale = gesture.scale
      
      location = gesture.location(in: self)
      offset = startOffset + CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
      
    case .ended, .cancelled, .failed:
      isPinching = false
      
      let imageHeight = imgSize.height
      let imageWidth = imgSize.width
      let scaledImageHeight = imageHeight * scale
      let scaledImageWidth = imageWidth * scale
      
      let overFlowFromCenterTopHeight = max(0, (scaledImageHeight - imageHeight) * CGFloat(anchor.y)) - offset.height
      let blackAreaLeft = -(max(0, (scaledImageWidth - UIScreen.screenWidth) * CGFloat(anchor.x)) - offset.width)
      let blackAreaTop = ((UIScreen.screenHeight - imgSize.height) / 2) - overFlowFromCenterTopHeight
      let blackAreaRight = blackAreaLeft < 0 ? UIScreen.screenWidth - (scaledImageWidth + blackAreaLeft) : 0
      let blackAreaBot = -(scaledImageHeight - (UIScreen.screenHeight - blackAreaTop))
      
      var newOffset = offset
      
      if scaledImageHeight <= UIScreen.screenHeight {
        let move = (blackAreaBot - blackAreaTop) / 2
        newOffset.height += move
      } else {
        if blackAreaTop > 0 { newOffset.height -= blackAreaTop } else
        if blackAreaBot > 0 { newOffset.height += blackAreaBot }
      }
      
      if scaledImageWidth <= UIScreen.screenWidth {
        let move = (blackAreaRight - blackAreaLeft) / 2
        newOffset.width += move
      } else {
        if blackAreaLeft > 0 {newOffset.width -= blackAreaLeft  } else
        if blackAreaRight > 0 { newOffset.width += blackAreaRight }
      }
      
      let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
      withAnimation(spring) {
        if scale < 1 {
          impactFeedbackgenerator.prepare()
          impactFeedbackgenerator.impactOccurred()
          scale = 1; offset = .zero
        } else { offset = newOffset }
      }
    default:
      break
    }
  }
  
}

protocol PinchZoomViewDelgate: AnyObject {
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
}

struct PinchZoom: UIViewRepresentable {
  
  var onTap: (()->())?
  var imgSize: CGSize
  @Binding var scale: CGFloat
  @Binding var anchor: UnitPoint
  @Binding var offset: CGSize
  @Binding var isPinching: Bool
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeUIView(context: Context) -> PinchZoomView {
    let pinchZoomView = PinchZoomView(imgSize: imgSize, onTap: onTap)
    pinchZoomView.delegate = context.coordinator
    return pinchZoomView
  }
  
  func updateUIView(_ pageControl: PinchZoomView, context: Context) { }
  
  class Coordinator: NSObject, PinchZoomViewDelgate {
    var pinchZoom: PinchZoom
    
    init(_ pinchZoom: PinchZoom) {
      self.pinchZoom = pinchZoom
    }
    
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
      pinchZoom.isPinching = isPinching
    }
    
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
      pinchZoom.scale = scale
    }
    
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
      pinchZoom.anchor = anchor
    }
    
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize) {
      pinchZoom.offset = offset
    }
  }
}

struct PinchToZoom: ViewModifier {
  var onTap: (()->())?
  var size : CGSize
  @Binding var isPinching: Bool
  @Binding var scale: CGFloat
  @Binding var anchor: UnitPoint
  @Binding var offset: CGSize
  
  func body(content: Content) -> some View {
    content
      .frame(width: IPAD ? (UIScreen.screenHeight * size.width) / size.height : UIScreen.screenWidth, height: IPAD ? UIScreen.screenHeight : (UIScreen.screenWidth * size.height) / size.width)
      .scaleEffect(scale, anchor: anchor)
      .offset(offset)
      .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight, alignment: .center)
      .overlay(PinchZoom(onTap: onTap, imgSize: size, scale: $scale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
  }
}

extension View {
  func pinchToZoom(onTap: (()->())? = nil, size: CGSize, isPinching: Binding<Bool>, scale: Binding<CGFloat>, anchor: Binding<UnitPoint>, offset: Binding<CGSize>) -> some View {
    self.modifier(PinchToZoom(onTap: onTap, size: size, isPinching: isPinching, scale: scale, anchor: anchor, offset: offset))
  }
}
