//
//  calculateDistance.swift
//  winston
//
//  Created by Igor Marcossi on 29/11/23.
//

import CoreGraphics

func calculateDistance(between firstPoint: CGPoint, and secondPoint: CGPoint) -> Double {
  let xDistance = secondPoint.x - firstPoint.x
  let yDistance = secondPoint.y - firstPoint.y
  return Double(sqrt((xDistance * xDistance) + (yDistance * yDistance)))
}

extension CGPoint {
  func distanceTo(point: CGPoint) -> Double {
    return calculateDistance(between: self, and: point)
  }
}


func calculateDistancePoint(point1: CGPoint, point2: CGPoint) -> CGPoint {
  let xDistance = point2.x - point1.x
  let yDistance = point2.y - point1.y

  return CGPoint(x: xDistance, y: yDistance)
}

extension CGPoint {
  func distancePointTo(point: CGPoint) -> CGPoint {
    return calculateDistancePoint(point1: self, point2: point)
  }
}
