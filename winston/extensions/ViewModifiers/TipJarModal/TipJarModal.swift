//
//  TipJarModal.swift
//  winston
//
//  Created by Igor Marcossi on 21/03/24.
//

import SwiftUI
import Defaults
import StoreKit
import Pow
import CloudStorage

private let starsCount = 7

struct TipJarModal: View {
  var closeTipJar: () -> ()
  @Environment (\.colorScheme) private var colorScheme: ColorScheme
  @Default(.TipJarSettings) private var tipJarSettings
  @CloudStorage(IAPManager.iCloudCometsKeyName) var comets: Int = 0
  @State private var selectedIAPProduct: IAPManager.IAPProduct? = nil
  @State private var showConfetti = false
  @State private var shotComets = 0
  
  var body: some View {
    let selectedProduct = selectedIAPProduct == nil ? nil : IAPManager.shared.allProducts[selectedIAPProduct!]
    VStack(alignment: .center, spacing: 24) {
      VStack(alignment: .center, spacing: 0) {
        Text("Tip jar").fontSize(24, .bold)
        Text("Thanks for supporting the project!")
      }
      VStack(alignment: .center, spacing: 12) {
        ForEach(IAPManager.IAPProduct.allCases.sorted(by: { $1.comets - $0.comets > 0 })) { iapPrd in
          let prd = IAPManager.shared.allProducts[iapPrd]
          TipJarOption(title: iapPrd.name, description: iapPrd.descripton, price: prd?.displayPrice ?? "", selected: selectedIAPProduct == iapPrd) {
            if selectedIAPProduct != iapPrd { iapPrd.vibrate() }
            selectedIAPProduct = selectedIAPProduct == iapPrd ? nil : iapPrd
          }
        }
      }
      Button {
        if let selectedProduct {
          Task {
            let result = try await selectedProduct.purchase()
            switch result {
            case .pending: print("Pending...")
            case .success(let res):
              if await IAPManager.shared.processResult(res) {
                showConfetti = true
                selectedIAPProduct = nil
                doThisAfter(2) {
                  showConfetti = false
                }
              }
            case .userCancelled: print("Cancelled...")
            @unknown default: break
            }
          }
        }
      } label: {
        Label(
          title: {
            Text(selectedProduct == nil ? "Select a tip above" : "Tip \(selectedProduct!.displayPrice)")
              .fontSize(16, .semibold)
              .contentTransition(.identity)
          },
          icon: { Image(.whiteJar).resizable().scaledToFit().frame(16) }
        )
      }
      .buttonStyle(.action(fullWidth: true))
      .disabled(selectedProduct == nil)
      .blendMode(selectedProduct == nil ? .softLight : .normal)
      
    }
    .padding(.top, 36)
    .padding(.bottom, 150)
    .padding(16)
    .frame(maxWidth: .infinity)
    .background { SpaceAdventure(shotComets: $shotComets, totalWidth: CGFloat.screenW - 32.0, comets: comets) }
    .background(RR(24, Color(uiColor: UIColor.systemGray6)))
    .overlay(alignment: .top) {
      if showConfetti {
        BetterLottieView("confetti-magic", size: .screenW - 32.0, initialDelay: 0, color: nil)
        //        .padding(.top, -176)
          .allowsHitTesting(false)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    .clipped()
    .overlay(alignment: .top) {
      Image(uiImage: AppIconManger.shared.currentAppIcon.preview)
        .resizable()
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .offset(y: -36)
    }
    .overlay(alignment: .topLeading) {
      VStack {
        if comets > 0 {
          HStack(spacing: 4) {
            Image(.meteor).resizable().frame(16)
            HStack(spacing: 0) {
              Text("x").fontSize(16, .semibold)
              Text("\(comets - shotComets)").fontSize(16, .semibold).contentTransition(.numericText())
            }
          }
          .transition(.scaleAndBlur)
          .onLongPressGesture(minimumDuration: 5, maximumDistance: 10) {
            comets = 0
          }
        }
      }
      .animation(.spring, value: comets)
      .padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 0))
      .compositingGroup()
      .opacity(0.25)
    }
    .closeSheetBtn(closeTipJar)
    .geometryGroup()
    .padding(.horizontal, 16)
    .transition(.offset(y: .screenH))
    .task { await IAPManager.shared.fetchAllProducts(); }
  }
}
