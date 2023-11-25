//
//  ThemeStore.swift
//  winston
//
//  Created by Daniel Inama on 26/09/23.
//

import SwiftUI
import Defaults
import FileProvider

struct ThemeStore: View {
  @EnvironmentObject var themeStore: ThemeStoreAPI
  @State var themes: [ThemeData] = []
  @State private var isRefreshing = false // Track the refreshing state
  @State private var isPresentingUploadSheet = false
  @StateObject var searchQuery = DebouncedText(delay: 0.35)
  @Environment(\.useTheme) private var theme
  var body: some View {
    HStack{
      List {
        if !themes.isEmpty {
          Section{
            ForEach(themes, id: \.self) { theme in
              NavigationLink(destination: ThemeStoreDetailsView(themeData: theme), label: {
                OnlineThemeItem(theme: theme)
              })
              .themedListRowBG(enablePadding: true)

            }
          }
          .themedListDividers()
        } else {
          ProgressView()
        }
      }
      .themedListBG(theme.lists.bg)
      .searchable(text: $searchQuery.text)
      .onChange(of: searchQuery.debounced) { val in
        Task{
          if val == "" {
            await fetchThemes()
          } else {
            themes = await themeStore.fetchThemesByName(name: val) ?? []
          }
        }
      }
      .refreshable {
        await fetchThemes()
      }
      .onAppear{
        Task{
          await fetchThemes()
        }
      }
      .navigationTitle("Theme Store")
      .navigationBarTitleDisplayMode(.large)
    }
    
    .sheet(isPresented: $isPresentingUploadSheet){
      ThemeStoreUploadSheet()
    }
    
  }
  
  private func fetchThemes() async {
    isRefreshing = true // Start refreshing animation
    themes =  await themeStore.fetchAllThemes() ?? []
    isRefreshing = false // Stop refreshing animation
    
  }
}

struct OnlineThemeItem: View {
  var theme: ThemeData
  var accentColor: Color = .blue
  @Environment(\.openURL) private var openURL
  
  
  var showShareButton: Bool = false
  var showDownloadButton: Bool = true
  
  var body: some View {
    HStack(spacing: 8){
      Group {
        Image(systemName: theme.icon ?? "xmark")
          .fontSize(24)
          .foregroundColor(.white)
      }
      .frame(width: 52, height: 52)
      .background(RR(16, theme.color?.color() ?? .blue))
      VStack(alignment: .leading, spacing: 0) {
        Text(theme.theme_name)
          .fontSize(16, .semibold)
          .frame(maxWidth: 200)
          .lineLimit(1)
          .fixedSize(horizontal: true, vertical: true)
        Text("\(theme.theme_author ?? "")")
          .fontSize(14, .medium)
          .opacity(0.75)
          .frame(maxWidth: 200)
          .lineLimit(1)
          .fixedSize(horizontal: true, vertical: true)
      }
      Spacer()
      if showDownloadButton {
        ThemeItemDownloadButton(theme: theme)
          .accentColor(accentColor)
      }
      if showShareButton {
        ThemeItemShareButton(theme: theme)
          .accentColor(accentColor)
      }
    }
    
  }
  
}


struct ThemeItemShareButton: View {
  var theme: ThemeData
  var body: some View {
    ShareLink(item: URL(string: "https://winston.cafe/theme/\(theme.file_id ?? "")")!)
      .labelStyle(.iconOnly)
  }
}


struct ThemeItemDownloadButton: View {
  var theme: ThemeData
  @State var downloading: Bool = false
  @State var showingImportError: Bool = false
  @Default(.themesPresets) private var themesPresets
  @EnvironmentObject var themeStore: ThemeStoreAPI
  @Environment(\.useTheme) private var themeTheme
  // Computed property to check if themesPresets contains the current theme
  private var isThemeInPresets: Bool {
    themesPresets.contains { $0.id == theme.file_id }
  }
  var body: some View {
    if isThemeInPresets{
      Button {
        //Delete the Theme
        themesPresets = themesPresets.filter { $0.id != theme.file_id}
      } label: {
        Label("Delete", systemImage: "trash")
          .labelStyle(.iconOnly)
          .foregroundColor(.red)
      }.highPriorityGesture(
        TapGesture()
          .onEnded{
            //Delete the Theme
            themesPresets = themesPresets.filter { $0.id != theme.file_id}
          }
      )
    } else {
      if downloading {
        ProgressView()
      } else {
        Button{
          downloadTheme()
        } label: {
          Label("Download", systemImage: "arrow.down.to.line")
            .labelStyle(.iconOnly)
          
        }
        .highPriorityGesture( //Is this really the solution for it working inside a NavigationLink??
          TapGesture()
            .onEnded{
              downloadTheme()
            }
        )
        .alert(isPresented: $showingImportError){
          Alert(title: Text("There was an error importing this theme"))
        }
      }
      
    }
    
  }
  
  func downloadTheme(){
    downloading = true
    Task {
      if let theme_id = theme.file_name {
        themeStore.getDownloadedFilePath(filename: theme_id, completion: { path in
          if let path{
//            print(path)
            showingImportError = !importTheme(at: path)
          }
          downloading = false
        })
      }
    }
  }
}
