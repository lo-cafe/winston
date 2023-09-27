//
//  ThemeStoreDetailsView.swift
//  winston
//
//  Created by Daniel Inama on 26/09/23.
//

import SwiftUI

struct ThemeStoreDetailsView: View {
  let theme: ThemeData
  
  @State private var selectedImageIndex = 0 // Track the selected image index
  var body: some View {
    NavigationView{
      VStack{
        OnlineThemeItem(theme: theme)
        Divider()
        HStack{
          Text("Preview")
            .font(.headline)
          Spacer()
        }
        TabView(selection: $selectedImageIndex) { // Use selection binding to track the selected index
          ForEach(theme.thumbnails_urls ?? [], id: \.self) { url in
                URLImage(url: URL(string: url)!)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
            }
        }
        .tabViewStyle(PageTabViewStyle()) // Set the tab view style to page style
        .frame(maxHeight: .infinity) // Adjust the height as need
        .accentColor(.blue) // Set the accent color to blue or any other color that's visible on white

        Divider()
        HStack{
          Text("Description")
            .font(.headline)
          Spacer()
        }
        Text(theme.theme_description == "" ? "Oh no! Looks like someone was lazy with the description :(" : theme.theme_description)
          .padding(.bottom, 10)
        Spacer()
        Text(theme.file_id)
          .font(.caption)
          .opacity(0.5)
      }
      .padding()
    }
    .navigationTitle(theme.theme_name ?? "Theme")
    .navigationBarTitleDisplayMode(.inline)
  }
}
