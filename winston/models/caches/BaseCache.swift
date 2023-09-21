//
//  BaseCache.swift
//  winston
//
//  Created by Igor Marcossi on 20/09/23.
//

import Foundation
import Combine
import SwiftUI


class BaseCache<T: Any>: ObservableObject {
  struct CacheItem {
    let data: T
    let createdAt: Date
  }
  
  @Published var cache: [String: CacheItem] = [:]
  let cacheLimit: Int
  
  init(cacheLimit: Int = 50, cache: [String:CacheItem] = [:]) {
    self.cacheLimit = cacheLimit
    self.cache = cache
  }
  
  func addKeyValue(key: String, data: @escaping () -> T) {
    if !cache[key].isNil { return }
    Task(priority: .background) {
      let itemData = data()
      // Create a new CacheItem with the current date
      let item = CacheItem(data: itemData, createdAt: Date())
      let oldestKey = cache.count > cacheLimit ? cache.min { a, b in a.value.createdAt < b.value.createdAt }?.key : nil
      
      // Add the item to the cache
      await MainActor.run {
        withAnimation {
          cache[key] = item
          if let oldestKey = oldestKey { cache.removeValue(forKey: oldestKey) }
        }
      }
    }
  }
  
}

class BaseObservableCache<T: ObservableObject>: ObservableObject {
  struct CacheItem {
    let data: T
    let createdAt: Date
  }
  
  @Published var cache: [String: CacheItem] = [:]
  let cacheLimit: Int
  
  init(cacheLimit: Int = 50, cache: [String:CacheItem] = [:]) {
    self.cacheLimit = cacheLimit
    self.cache = cache
  }
  
  func addKeyValue(key: String, data: @escaping () -> T) {
    if !cache[key].isNil { return }
    Task(priority: .background) {
      let itemData = data()
      // Create a new CacheItem with the current date
      let item = CacheItem(data: itemData, createdAt: Date())
      let oldestKey = cache.count > cacheLimit ? cache.min { a, b in a.value.createdAt < b.value.createdAt }?.key : nil
      
      // Add the item to the cache
      await MainActor.run {
        withAnimation {
          cache[key] = item
          if let oldestKey = oldestKey { cache.removeValue(forKey: oldestKey) }
        }
      }
    }
  }
  
}
