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
  @EnvironmentObject var themeStore: ThemeStoreAPI
  @StateObject var viewModel = AppDetailViewObject()
  var body: some View {
    FittingScrollView{
      VStack(spacing: 0){
        OnlineThemeItem(theme: theme)
          .padding()
        Divider()
          .padding(.horizontal)
        AppDetailScreenshots(screenshots: viewModel.previews)
          .padding()
        
        Divider()
          .padding(.horizontal)
        
        AppDetailDescription(text: theme.theme_description ?? "Uh oh! Someone was lazy and didn't add a description :(")
          .padding()
        
        Divider()
          .padding(.horizontal)
        
        AppDetailInfoFullView(
          author: theme.theme_author, themeId: theme.file_id, themeName: theme.theme_name
        )
        .padding()
        
      }
    } onOffsetChange: {
      viewModel.scrollOffset = $0
    }
    .toolbar{
      if viewModel.hasScrolledPastNavigationBar {
        ToolbarItem(placement: .principal){
          Group {
            Image(systemName: theme.icon ?? "xmark")
              .fontSize(12)
              .foregroundColor(.white)
          }
          .frame(width: 32, height: 32)
          .background(RR(8, theme.color?.color() ?? .blue))
        }
        
        ToolbarItem(placement: .navigationBarTrailing){
          ThemeItemDownloadButton(theme: theme)
        }
      }
    }
    .animation(.default, value: viewModel.hasScrolledPastNavigationBar)
    .toolbarBackground(.visible, for: .tabBar)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear{
      Task{
        let urls = await themeStore.getPreviewImages(id: theme.file_id ?? "")
        viewModel.previews = urls?.previews ?? []
        viewModel.accent = Color(theme.color?.hex ?? "#0000FF")
      }
    }
  }
}

extension ThemeStoreDetailsView {
  @MainActor class AppDetailViewObject: ObservableObject {
    @Published var accent: Color = .blue
    @Published var hasScrolledPastNavigationBar: Bool = false
    @Published var previews: [String] = []
    @Published var scrollOffset: CGFloat = .zero {
      didSet {
        hasScrolledPastNavigationBar = scrollOffset < -60
      }
    }
  }
  
}
