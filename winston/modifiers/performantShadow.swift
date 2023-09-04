//
//  performantShadow.swift
//  winston
//
//  Created by Igor Marcossi on 12/08/23.
//

import SwiftUI
import UIKit

struct PerformantShadow: UIViewRepresentable {
  var cornerRadius: CGFloat
  var color: Color
  var opacity: CGFloat
  var radius: CGFloat
  var offsetY: CGFloat
  var size: CGSize
  
  func makeUIView(context: Context) -> UIView {
    let view = UIView()

      context.coordinator.addRoundedRectangleShadow(to: view, cornerRadius: cornerRadius, color: UIColor(color), opacity: Float(opacity), radius: radius, offsetY: offsetY, size: size)
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
      context.coordinator.updateRoundedRectangleShadow(for: uiView, cornerRadius: cornerRadius, color: UIColor(color), opacity: Float(opacity), radius: radius, offsetY: offsetY, size: size)
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  class Coordinator {
    func addRoundedRectangleShadow(to view: UIView, cornerRadius: CGFloat, color: UIColor, opacity: Float, radius: CGFloat, offsetY: CGFloat, size: CGSize) {
      let shapeLayer = CAShapeLayer()
      shapeLayer.name = "shapeLayer"
      shapeLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius).cgPath
      shapeLayer.fillColor = UIColor.clear.cgColor
      view.layer.addSublayer(shapeLayer)
      
      let shadowLayer = CAShapeLayer()
      shadowLayer.name = "shadowLayer"
      shadowLayer.path = shapeLayer.path
      shadowLayer.fillColor = UIColor.clear.cgColor
      shadowLayer.shadowColor = color.cgColor
      shadowLayer.shadowPath = shadowLayer.path
      shadowLayer.shadowOpacity = opacity
      shadowLayer.shadowRadius = radius
      shadowLayer.shadowOffset = CGSize(width: 0, height: offsetY)
      view.layer.addSublayer(shadowLayer)
    }
    
    func updateRoundedRectangleShadow(for view: UIView, cornerRadius: CGFloat, color: UIColor, opacity: Float, radius: CGFloat, offsetY: CGFloat, size: CGSize) {
      guard let shapeLayer = view.layer.sublayers?.first(where: { $0.name == "shapeLayer" }) as? CAShapeLayer,
            let shadowLayer = view.layer.sublayers?.first(where: { $0.name == "shadowLayer" }) as? CAShapeLayer else { return }
      shapeLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius).cgPath
      shadowLayer.path = shapeLayer.path
      shadowLayer.fillColor = UIColor.clear.cgColor
      shadowLayer.shadowColor = color.cgColor
      shadowLayer.shadowPath = shadowLayer.path
      shadowLayer.shadowOpacity = opacity
      shadowLayer.shadowRadius = radius
      shadowLayer.shadowOffset = CGSize(width: 0, height: offsetY)
    }
  }
}

extension View {
  func performantShadow(horizontalPadding: CGFloat = 0, cornerRadius: CGFloat, color: Color, opacity: Double, radius: CGFloat, offsetY: CGFloat, size: CGSize) -> some View {
    self.background(
      PerformantShadow(cornerRadius: cornerRadius, color: color, opacity: opacity, radius: radius, offsetY: offsetY, size: size)
        .padding(.all, 1)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    )
  }
}
