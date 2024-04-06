//
//  IAPManager.swift
//  winston
//
//  Created by Igor Marcossi on 22/03/24.
//

import SwiftUI
import StoreKit
import Defaults

@Observable
class IAPManager {
  static let iCloudCometsKeyName = "iCloudCometsCount"
  static let shared = IAPManager()
  var allProducts = [IAPProduct:Product]()
//  var boughtProducts = [IAPProduct]()
  var transactionListener: Task<Void, Error>? = nil
  
  func addComets(_ newComets: Int) {
    if let cometsInICloud = Int(NSUbiquitousKeyValueStore.default.string(forKey: Self.iCloudCometsKeyName) ?? "0") {
      NSUbiquitousKeyValueStore.default.set("\(cometsInICloud + newComets)", forKey: Self.iCloudCometsKeyName)
      NSUbiquitousKeyValueStore.default.synchronize()
    }
  }
  
  func fetchAllProducts() async {
    if let allRemoteProducts = try? await Product.products(for: IAPProduct.allCases.map { $0.rawValue }) {
      if allProducts.keys.count == allRemoteProducts.count { return }
      var newDict = [IAPProduct:Product]()
      allRemoteProducts.forEach { prd in
        if let iapPrd = IAPProduct(rawValue: prd.id) { newDict[iapPrd] = prd }
      }
      self.allProducts = newDict
    }
  }
  
  deinit {
    transactionListener?.cancel()
  }
  
  func startListeningForUpdates() {
    self.transactionListener = createTransactionTask()
  }
  
  private func createTransactionTask() -> Task<Void, Error> {
    return Task.detached {
      for await update in Transaction.updates {
        _ = await self.processResult(update)
      }
    }
  }
  
  func processResult<T>(_ r: VerificationResult<T>) async -> Bool {
    if let transaction = self.verifyPurchase(r) as? StoreKit.Transaction, let iapPrd = IAPProduct(rawValue: transaction.productID) {
      addComets(iapPrd.comets)
      await transaction.finish()
      return true
    }
    return false
  }
  
  private func verifyPurchase<T>(_ result: VerificationResult<T>) -> T? {
    switch result {
    case .unverified:
      return nil
    case .verified(let safe):
      return safe
    }
  }
  
  enum IAPProduct: String, Identifiable, Hashable, CaseIterable {
    var id: String { self.rawValue }
    case cafezinhoTip, espressoTip, cappuccinoTip
    
    var storeProduct: Product? { IAPManager.shared.allProducts[self] }
    
    var name: String {
      return switch self {
      case .cafezinhoTip: "Cafézinho"
      case .espressoTip: "Espresso"
      case .cappuccinoTip: "Cappuccino"
      }
    }
    
    var descripton: String {
      return switch self {
      case .cafezinhoTip: "A typical brazilian cup of black coffee"
      case .espressoTip: "Oh nice, we appreciate the espresso!"
      case .cappuccinoTip: "A CAPPUCCINO? Oh dude, thx a lot!"
      }
    }
    
    var comets: Int {
      return switch self {
      case .cafezinhoTip: 2
      case .espressoTip: 5
      case .cappuccinoTip: 10
      }
    }
    
    func vibrate() {
      switch self {
      case .cafezinhoTip: Hap.shared.play(intensity: 1, sharpness: 0.2)
      case .espressoTip: Hap.shared.play(intensity: 1, sharpness: 0.6)
      case .cappuccinoTip: Hap.shared.play(intensity: 1, sharpness: 1)
      }
    }
  }
}
