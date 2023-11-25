//
//  UpsellCard.swift
//  winston
//
//  Created by daniel on 22/11/23.
//

import SwiftUI
import Defaults
struct UpsellCard<Content: View>: View {
  var upsellName: String
  var content: (() -> Content)
  @Default(.showingUpsellDict) var showingUpsellDict
  
  init(upsellName: String, _ content: @escaping () -> Content) {
    self.upsellName = upsellName
    self.content = content
  }
  
  var body: some View {
    if showingUpsellDict[upsellName] ?? true {
      ZStack{
        content()
          .padding()
        closeButton
      }
    }
  }
  
  var closeButton: some View {
    VStack{
      HStack{
        Spacer()
        Button(action: {
          showingUpsellDict[upsellName] = false
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
            .imageScale(.large)
        }
        
      }
      Spacer()
    }
    .ignoresSafeArea(.all)
    .opacity(0.5)
  }
  
  
}
