//
//  ThemesPanel.swift
//  winston
//
//  Created by Igor Marcossi on 08/09/23.
//

import SwiftUI
import UniformTypeIdentifiers
import Defaults
import Zip

struct ThemesPanel: View {
  @Default(.themesPresets) private var themesPresets
  @State private var isUnzipping = false
  @Environment(\.useTheme) private var theme
  var body: some View {
    List {
      
      Group {
        Section {
          ThemeNavLink(theme: defaultTheme)
            .deleteDisabled(true)
          
          ForEach(themesPresets) { theme in
            if theme.id != "default" {
              WListButton(showArrow: true) {
                Nav.present(.editingTheme(theme))
              } label: {
                ThemeNavLink(theme: theme)
              }
            }
          }
          .onDelete { index in
            withAnimation { themesPresets.remove(atOffsets: index) }
          }
        }
        
        Section {
          WSListButton("Import theme", icon: "doc.zipper") { isUnzipping = true }
            .fileImporter(
              isPresented: $isUnzipping,
              allowedContentTypes: [UTType.zip],
              allowsMultipleSelection: false
            ) { res in
              switch res {
              case .success(let file):
                _ = importTheme(at: file[0])
              case .failure(let error):
                print(error.localizedDescription)
              }
            }
        }
      }
      .themedListSection()
    }
    .themedListBG(theme.lists.bg)
    .overlay(
      themesPresets.count > 1
      ? nil
      : VStack(spacing: 0) {
        Text("Start by duplicating the")
        HStack(spacing: 4) {
          Text("default theme by tapping")
          Image(systemName: "plus")
        }
      }
        .compositingGroup()
        .opacity(0.25)
    )
    .navigationTitle("Themes")
    .navigationBarTitleDisplayMode(.large)
    .toolbar {
      EditButton()
      Button {
        withAnimation { themesPresets.append(defaultTheme.duplicate()) }
      } label: {
        Image(systemName: "plus")
      }
    }
  }
  
  
}

struct ThemeNavLink: View {
  @Default(.selectedThemeID) private var selectedThemeID
  @Default(.themesPresets) private var themesPresets
  @State private var restartAlert = false
  
  @Environment(\.useTheme) private var selectedTheme
  @State private var isMoving = false
  @State private var zipUrl: URL? = nil
  var theme: WinstonTheme
  
  
  func zipFiles() {
    var imgNames: [String] = []
    if case .img(let schemesStr) = theme.postLinks.bg {
      imgNames.append(schemesStr.light)
      imgNames.append(schemesStr.dark)
    }
    if case .img(let schemesStr) = theme.posts.bg {
      imgNames.append(schemesStr.light)
      imgNames.append(schemesStr.dark)
    }
    if case .img(let schemesStr) = theme.lists.bg {
      imgNames.append(schemesStr.light)
      imgNames.append(schemesStr.dark)
    }
    createZipFile(with: imgNames, theme: theme.duplicate()) { url in
      self.zipUrl = url
      self.isMoving = true
    }
  }
  
  var body: some View {
    let isDefault = theme.id == "default"
    HStack(spacing: 8) {
      Group {
        if isDefault {
          Image("winstonFlat")
            .resizable()
            .scaledToFit()
            .frame(height: 36)
        } else {
          Image(systemName: theme.metadata.icon)
            .fontSize(24)
            .foregroundColor(.white)
        }
      }
      .frame(width: 52, height: 52)
      .background(RR(16, theme.metadata.color.color()))
      VStack(alignment: .leading, spacing: 0) {
        Text(theme.metadata.name)
          .fontSize(16, .semibold)
          .fixedSize(horizontal: true, vertical: false)
        Text("by \(theme.metadata.author)")
          .fontSize(14, .medium)
          .opacity(0.75)
          .fixedSize(horizontal: false, vertical: true)
      }
      
      Spacer()
      
      Toggle("", isOn: Binding(get: { selectedTheme == theme  }, set: { _ in
        if themesPresets.first(where: { $0.id == selectedThemeID })?.general != theme.general { restartAlert = true  }
        selectedThemeID = theme.id
      }))
      .highPriorityGesture(TapGesture())
    }
    .padding(.vertical, 2)
    .contextMenu {
      Button {
        withAnimation { themesPresets.append(theme.duplicate()) }
      } label: {
        Label("Duplicate", systemImage: "plus.square.on.square")
      }
      
      Button(action: zipFiles) {
        Label("Export", systemImage: "doc.zipper")
      }
    }
    .fileMover(isPresented: $isMoving, file: zipUrl, onCompletion: { result in
      switch result {
      case .success(let url):
        print("Successfully moved the file to \(url)")
      case .failure(let error):
        print("Failed to move the file with error \(error)")
      }
    })
    .alert("Restart required", isPresented: $restartAlert) {
      Button("Gotcha!", role: .cancel) {
        restartAlert = false
      }
    } message: {
      Text("This theme changes a few settings that requires an app restart to take effect.")
    }
  }
}

func createZipFile(with imgNames: [String], theme: WinstonTheme, completion: @escaping(_ url: URL?) -> Void) {
  do {
    let zipURL = try createZip(images: imgNames, theme: theme)
    completion(zipURL)
  } catch {
    print("Failed to create zip file with error \(error.localizedDescription)")
    completion(nil)
  }
}
