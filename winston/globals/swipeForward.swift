//
//  swipeForward.swift
//  winston
//
//  Created by Daniel Inama on 12/09/23.
//

import Foundation
import SwiftUI


class NavigationState: ObservableObject {
    @Published var poppedView: String? // Store the popped view's identifier
}

struct PoppedViewCapture: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var navigationState: NavigationState

    var body: some View {
        Color.clear
            .onAppear {
                DispatchQueue.main.async {
                    if let poppedView = navigationState.poppedView {
                        print("Popped View Identifier: \(poppedView)")
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
}

extension View {
    func capturePoppedView() -> some View {
        self.overlay(PoppedViewCapture())
    }
}
