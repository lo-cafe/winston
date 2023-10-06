//
//  ThemeStoreDetailsView.swift
//  winston
//
//  Created by Daniel Inama on 26/09/23.
//

import SwiftUI
import Defaults

struct ThemeStoreDetailsView: View {
  let themeData: ThemeData
  @EnvironmentObject var themeStore: ThemeStoreAPI
  @StateObject var viewModel = AppDetailViewObject()
  @Environment(\.useTheme) private var theme
  @Default(.themeStoreTint) var themeStoreTint
  var body: some View {
    FittingScrollView{
      VStack(spacing: 0){
        OnlineThemeItem(theme: themeData, accentColor: Color(uiColor: UIColor(hex: themeData.color!.hex)))
          .padding()
        Divider()
          .padding(.horizontal)
        AppDetailScreenshots(screenshots: viewModel.previews)
          .shadow(radius: 1)
          .padding()
        
        Divider()
          .padding(.horizontal)
        
        AppDetailDescription(text: themeData.theme_description ?? "Uh oh! Someone was lazy and didn't add a description :(")
          .padding()
        
        Divider()
          .padding(.horizontal)
        
        AppDetailInfoFullView(
          author: themeData.theme_author, themeId: themeData.file_id, themeName: themeData.theme_name
        )
        .padding()
        
      }
    } onOffsetChange: {
      viewModel.scrollOffset = $0
    }
    .animation(.default, value: viewModel.hasScrolledPastNavigationBar)
    .toolbarBackground(.visible, for: .tabBar)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear{
      Task{
        let urls = await themeStore.getPreviewImages(id: themeData.file_id ?? "")
        viewModel.previews = urls?.previews ?? []
        viewModel.accent = Color(themeData.color?.hex ?? "#0000FF")
      }
    }
    .toolbar{
      if viewModel.hasScrolledPastNavigationBar {
        ToolbarItem(placement: .principal){
          Group {
            Image(systemName: themeData.icon ?? "xmark")
              .fontSize(12)
              .foregroundColor(.white)
          }
          .frame(width: 32, height: 32)
          .background(RR(8, themeData.color?.color() ?? .blue))
        }
        
        ToolbarItem(placement: .navigationBarTrailing){
          ThemeItemDownloadButton(theme: themeData)
        }
      }
    }
    .if(themeStoreTint){ view in
      view.background{
        LinearGradient(gradient: Gradient(colors: [Color(uiColor: UIColor(hex: themeData.color!.hex)).opacity(0.3), Color(UIColor.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea(.all)
      }
    }
    .if(!themeStoreTint){ view in
      view.themedListBG(theme.lists.bg)
    }
    .tint(Color(uiColor: UIColor(hex: themeData.color!.hex)))
    .accentColor(Color(uiColor: UIColor(hex: themeData.color!.hex)))
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
