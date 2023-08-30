//
//  timeSince.swift
//  winston
//
//  Created by Igor Marcossi on 25/07/23.
//

import Foundation

func timeSince(_ timestamp: Int) -> String {
  let currentTime = Int(Date().timeIntervalSince1970)
  let timeInterval = currentTime - timestamp
  
  let minute = 60
  let hour = minute * 60
  let day = hour * 24
  let year = day * 365
  
  switch timeInterval {
  case 0..<hour:
    return "\(timeInterval/minute)m"
  case hour..<day:
    return "\(timeInterval/hour)h"
  case day..<year:
    return "\(timeInterval/day)d"
  default:
    return "\(timeInterval/year)y"
  }
}
