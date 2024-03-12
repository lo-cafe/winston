//
//  wait.swift
//  winston
//
//  Created by Igor Marcossi on 05/12/23.
//

import Foundation

func wait(_ miliseconds: Int) async {
  try? await Task.sleep(until: .now + .milliseconds(miliseconds), clock: .continuous)
}
