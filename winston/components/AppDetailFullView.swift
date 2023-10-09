//
//  AppDetailFullView.swift
//  winston
//
//  Created by Daniel Inama on 05/10/23.
//
import SwiftUI

public struct AppDetailInfoFullView: View {
    
    @ScaledMetric private var spacing: CGFloat = 8
    @ScaledMetric private var rowVerticalPadding: CGFloat = 12
    
    let author: String?
    let themeID: String?
    let themeName: String?
   
    
    private let entries: [Entry]
    
    public init(author: String?, themeId: String?, themeName: String?) {
        self.author = author
        self.themeID = themeId
        self.themeName = themeName
       
        
        self.entries = [
            .init(text: "Author", image: "person", value: author),
            .init(text: "Theme ID", image: "qrcode", value: themeId),
            .init(text: "Theme Name", image: "lanyardcard", value: themeName),
            
        ].filter({ $0.value != nil })
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text("Information")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(spacing: 0) {
                ForEach(Array(zip(entries.indices, entries)), id: \.1) { index, entry in
                    entryView(text: entry.text, image: entry.image, value: entry.value)
                        .overlay(alignment: .bottom, content: {
                            if index != entries.count - 1 {
                                Divider()
                            }
                        })
                }
            }
            .padding(.horizontal)
            .background(Color.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    @ViewBuilder private func entryView(text: String, image: String, value: String?) -> some View {
        if let value {
            LabeledContent {
                Text(value)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.trailing)
                    .textSelection(.enabled)
            } label: {
                Label {
                    Text(text)
                } icon: {
                    Image(systemName: image)
                }
                
            }
            .font(.subheadline)
            .padding(.vertical, rowVerticalPadding)
        }
    }
    
    private struct Entry: Identifiable, Hashable {
        let text: String
        let image: String
        let value: String?
        
        var id: String { text }
    }
}

