//
//  getPointAroundCircleForIndex.swift
//  winston
//
//  Created by Igor Marcossi on 07/12/23.
//

import Foundation


func getOffsetAroundCircleForIndex(count: Int, index: Int, circleSize: CGSize) -> CGSize {
  let radiusX = circleSize.width / 2
  let radiusY = circleSize.height / 2
  let eccentricity = sqrt(1 - pow(min(radiusX, radiusY) / max(radiusX, radiusY), 2))
  let width = calculateXOffset(count: count, index: index)
  let height = calculateYOffset(count: count, index: index)
  let offset = CGSize(width: width, height: height)
  
  return offset
  
  func calculateXOffset(count: Int, index: Int) -> Double {
    if count == 1 { return -radiusX }
    let t = calculateT(count: count, index: index)
    let e = eccentricity
    let theta = t + (pow(e, 2)/8 + pow(e, 4)/16 + 71*pow(e, 6)/2048) * sin(2*t) +
    (5*pow(e, 4)/256 + 5*pow(e, 6)/256) * sin(4*t) +
    29*pow(e, 6)/6144 * sin(6*t)
    
    let xOffset = radiusX * cos(theta) - radiusX
    return xOffset
  }
  
  func calculateYOffset(count: Int, index: Int) -> Double {
    if count == 1 { return radiusY }
    let t = calculateT(count: count, index: index)
    let e = eccentricity
    let theta = t + (pow(e, 2)/8 + pow(e, 4)/16 + 71*pow(e, 6)/2048) * sin(2*t) +
    (5*pow(e, 4)/256 + 5*pow(e, 6)/256) * sin(4*t) +
    29*pow(e, 6)/6144 * sin(6*t)
    
    let yOffset = radiusY * sin(theta)
    return yOffset
  }
  
  func calculateT(count: Int, index: Int) -> Double {
    let angleSpread: Double = .pi / 3
    let minItemCountForFullSpread: Int = 4
    let actualAngleSpread: Double
    if count >= minItemCountForFullSpread {
      actualAngleSpread = .pi
    } else {
      actualAngleSpread = angleSpread + Double(count - 1) * (.pi - angleSpread) / Double(minItemCountForFullSpread - 1)
    }
    let t = actualAngleSpread * Double(index) / Double(max(1, count-1)) + .pi / 2 - actualAngleSpread / 2
    return t
  }
  
}
