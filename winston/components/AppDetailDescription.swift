//
//  AppDetailDescription.swift
//  winston
//
//  Created by Daniel Inama on 05/10/23.
//

import SwiftUI

public struct AppDetailDescription: View {
    @ScaledMetric private var spacing: CGFloat = 8
    
    let text: String
    
    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text("Description")
                .font(.title3)
                .fontWeight(.semibold)
            
            ExpandableText(text)
        }
    }
}
