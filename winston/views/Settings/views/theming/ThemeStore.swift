//
//  ThemeStore.swift
//  winston
//
//  Created by Daniel Inama on 26/09/23.
//

import SwiftUI
import Defaults

struct ThemeStore: View {
  @EnvironmentObject var themeStore: ThemeStoreAPI
  @State var themes: [ThemeData] = []
  @State private var isRefreshing = false // Track the refreshing state
  @State private var isPresentingUploadSheet = false
  @State private var eligibility: Bool = false
  @Default(.themestoreID) var themestoreID
  var body: some View {
    NavigationView{
      VStack {
        if eligibility {
          if themes.isEmpty {
            VStack {
              HStack {
                ProgressView()
              }
            }
          } else {
            List {
              ForEach(themes, id: \.self) { theme in
                NavigationLink(destination: ThemeStoreDetailsView(theme: theme), label: {
                  OnlineThemeItem(theme: theme)
                })
              }
            }
          }
        } else {
          HStack{
            VStack{
              Image(systemName: "lock")
                .opacity(0.7)
                .font(.system(size: 50))
                .padding()
              Text("Behold, the Theme Store awaits, its secrets hidden behind a mystical lock. To discover its treasures, an exclusive key exists in a realm known to those who seek it. A hint of wisdom: whispers of this key may be found among the stars...")
                .multilineTextAlignment(.leading)
                .opacity(0.7)
              
              Button {
                UIPasteboard.general.string = themestoreID
              } label: {
                Label(themestoreID, systemImage: "clipboard")
              }
              .buttonStyle(BorderedButtonStyle())
              .foregroundColor(.primary)
              
            }
          }
          .padding()
        }
      }
    }.sheet(isPresented: $isPresentingUploadSheet){
      ThemeStoreUploadSheet()
    }
    .toolbar{
      if eligibility {
        ToolbarItem(placement: .primaryAction){
          Button{
            isPresentingUploadSheet.toggle()
          } label: {
            Label("Upload Theme", systemImage: "arrow.up.to.line")
              .labelStyle(.iconOnly)
          }
        }
      }
      
    }
    .navigationTitle("Theme Store")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      if themestoreID == "" {
        themestoreID = generateShortUniqueID()
      }
      Task {
        eligibility = await themeStore.getEligibilits(id: themestoreID) ?? false
        await fetchThemes()
      }
    }
    .refreshable { // Add pull-to-refresh
      await fetchThemes()
    }
  }
  
  private func fetchThemes() async {
    isRefreshing = true // Start refreshing animation
    themes =  await themeStore.fetchAllThemes() ?? []
    isRefreshing = false // Stop refreshing animation
    
  }
}

#Preview {
  ThemeStore()
}

struct OnlineThemeItem: View {
  var theme: ThemeData
  @Default(.themesPresets) private var themesPresets
  @State var downloading: Bool = false
  @Environment(\.openURL) private var openURL
  // Computed property to check if themesPresets contains the current theme
  private var isThemeInPresets: Bool {
    themesPresets.contains { $0.id == theme.file_id }
  }
  
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
          .fixedSize(horizontal: true, vertical: false)
        Text("Created by \(theme.theme_author ?? "")")
          .fontSize(14, .medium)
          .opacity(0.75)
          .fixedSize(horizontal: true, vertical: false)
      }
      Spacer()
      
      if let attachment = theme.attachment_url, let urlWithoutQuery = attachment.split(separator: "?").first {
        
        
        if isThemeInPresets{
          Button {
            //Delete the Theme
            themesPresets = themesPresets.filter { $0.id != theme.file_id}
          } label: {
            Label("Delete", systemImage: "trash")
              .labelStyle(.iconOnly)
              .foregroundColor(.red)
          }
        } else {
          if downloading {
            ProgressView()
          } else {
            Button{
              //Implement adding this to saved themes
              downloading = true
              let url = URL(string: String(urlWithoutQuery))!
              print(url)
              let fileManager = FileManager.default
              if fileManager.fileExists(atPath: url.absoluteString) {
                do {
                  try fileManager.removeItem(at: url)
                } catch {
                  print("Failed to delete existing file: \(error)")
                }
              }
              
              FileDownloader.loadFileAsync(url: url) { (path, error) in
                if let path{
                  let fileURL =  URL(string: "file://" + path)!
                  unzipTheme(at: fileURL)
                  
                }
                downloading = false
              }
            } label: {
              Label("Download", systemImage: "arrow.down.to.line")
                .labelStyle(.iconOnly)
                .foregroundColor(.blue)
              
            }
          }
          
        }
        
      }
    }
    
  }
  
}

#Preview {
  ThemeStore()
}
