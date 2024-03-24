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
  static let shared = IAPManager()
  var allProducts: [IAPProduct:Product] = [:]
  var boughtProducts: [IAPProduct] = []
  var transactionListener: Task<Void, Error>? = nil
  
  var totalComets: Int { boughtProducts.reduce(0) { partialResult, iapPrd in
    return partialResult + iapPrd.comets
  } }
  
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
  
  func startListeningForUpdates() {
    transactionListener = createTransactionTask()
  }
  
  deinit {
    transactionListener?.cancel()
  }
  
  private func createTransactionTask() -> Task<Void, Error> {
    return Task.detached {
      for await update in Transaction.updates {
        await self.processResult(update)
      }
    }
  }
  
  func processResult<T>(_ r: VerificationResult<T>) async -> Bool {
    if let transaction = self.verifyPurchase(r) as? StoreKit.Transaction, let iapPrd = IAPProduct(rawValue: transaction.productID) {
      Defaults[.TipJarSettings].comets += iapPrd.comets
      await transaction.finish()
      return true
    }
    return false
  }
  
//  func refreshPurchasedProducts() async {
//    // Iterate through the user's purchased products.
//    var newBoughtProducts = [IAPProduct]()
//    for await verificationResult in Transaction.all {
//      switch verificationResult {
//      case .verified(let transaction):
//        if let iapPrd = IAPProduct(rawValue: transaction.productID) {
//          newBoughtProducts.append(iapPrd)
//        }
//        break
//      case .unverified(let unverifiedTransaction, let verificationError):
//        break
//      }
//    }
//    if newBoughtProducts.count == boughtProducts.count { return }
//    boughtProducts = newBoughtProducts
//  }
  
  private func verifyPurchase<T>(_ result: VerificationResult<T>) -> T? {
    switch result {
    case .unverified:
      return nil
    case .verified(let safe):
      return safe
    }
    return nil
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
