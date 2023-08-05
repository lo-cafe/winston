//
//  GoodNavigator.swift
//  winston
//
//  Created by Igor Marcossi on 30/06/23.
//

import SwiftUI

struct GoodNavigator<Content: View>: View {
    
    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        if #available(iOS 16.0, *) {
          NavigationView {
                self.content()
            }
//          .if(!IPAD) { $0.navigationViewStyle(.stack) }
//
        } else {
            NavigationView {
                self.content()
            }
//          .if(!IPAD) { $0.navigationViewStyle(.stack) }
          
        }
    }
}
