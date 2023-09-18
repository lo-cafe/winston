//
//  ThemeEditPanel.swift
//  winston
//
//  Created by Igor Marcossi on 08/09/23.
//

import SwiftUI
import Defaults
import SymbolPicker
import Combine
import DebouncedOnChange

class ThemeEditedInstance: ObservableObject {
  @Published var winstonTheme: WinstonTheme = defaultTheme
  var index: Int
  
  private var cancellable: AnyCancellable?
  
  init(_ theme: WinstonTheme) {
    self.winstonTheme = theme
    self.index = Defaults[.themesPresets].firstIndex { $0.id == theme.id } ?? 0
  }
  
  func load() {
    guard cancellable == nil else { return }
    // Debounce any changes to winstonTheme and update it in Defaults
    self.cancellable = $winstonTheme
      .debounce(for: 1.0, scheduler: RunLoop.main)
      .sink { [weak self] updatedTheme in
        guard let self = self else {
          return
        }
        Defaults[.themesPresets][index] = updatedTheme
      }
  }
}

enum ThemeEditPanels {
  case general, posts, comments, postLinks, feed
}

struct ThemeEditPanel: View {
  @StateObject var themeEditedInstance: ThemeEditedInstance
  @State private var iconPickerOpen = false
  @State private var themeColor: Color = .blue
  
  //  init(theme: WinstonTheme) {
  //    self.index = Defaults[.themesPresets].firstIndex(of: theme) ?? 0
  ////    self._theme = State(initialValue: theme)
  //  }
  var body: some View {
    let theme = themeEditedInstance.winstonTheme
    List {
      
      Image(systemName: theme.metadata.icon)
        .fontSize(48)
        .foregroundColor(.white)
        .frame(width: 96, height: 96)
        .background(RR(32, theme.metadata.color.color()))
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
      
      Section("Theming") {
        NavigationLink(value: ThemeEditPanels.general) {
          Label("General", systemImage: "paintbrush.pointed.fill")
        }
        NavigationLink(value: ThemeEditPanels.feed) {
          Label("Posts feed", systemImage: "rectangle.grid.1x2.fill")
        }
        NavigationLink(value: ThemeEditPanels.postLinks) {
          Label("Posts links", systemImage: "rectangle.and.hand.point.up.left.fill")
        }
        NavigationLink(value: ThemeEditPanels.posts) {
          Label("Post page", systemImage: "doc.richtext.fill")
        }
        NavigationLink(value: ThemeEditPanels.comments) {
          Label("Comments", systemImage: "message.fill")
        }
      }
      
      Section("Metadatas") {
        
        Button {
          iconPickerOpen = true
        } label: {
          HStack {
            Text("Icon")
              .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: theme.metadata.icon)
              .foregroundColor(theme.metadata.color.color())
          }
        }
        .sheet(isPresented: $iconPickerOpen) {
          SymbolPicker(symbol: $themeEditedInstance.winstonTheme.metadata.icon)
        }
        
        ThemeColorPicker("Icon background color", $themeEditedInstance.winstonTheme.metadata.color)
        
        LabeledTextField("Name", $themeEditedInstance.winstonTheme.metadata.name)
        LabeledTextField("Author", $themeEditedInstance.winstonTheme.metadata.author)
        
        VStack(alignment: .leading, spacing: 4) {
          Text("Description:")
            .padding(.top, 8)
          TextEditor(text: $themeEditedInstance.winstonTheme.metadata.description)
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding(.horizontal, 6)
            .background(.primary.opacity(0.05))
            .mask(RR(8, .black))
            .padding(.bottom, 8)
            .fontSize(15)
        }
        
      }
      
    }
    .scrollDismissesKeyboard(.interactively)
    .onAppear {
        themeEditedInstance.load()
    }
    //    .onChange(of: theme, debounceTime: .seconds(1)) { newTheme in
    //      if let i = Defaults[.themesPresets].firstIndex(where: { preset in
    //        preset.id == newTheme.id
    //      }) {
    //        Defaults[.themesPresets][i] = newTheme
    //      }
    //    }
    .navigationTitle(theme.metadata.name)
    .navigationBarTitleDisplayMode(.inline)
    .navigationDestination(for: ThemeEditPanels.self) { x in
      Group {
        switch x {
        case .comments:
          CommentsThemingPanel(theme: $themeEditedInstance.winstonTheme)
        case .general:
          GeneralThemingPanel(theme: $themeEditedInstance.winstonTheme)
        case .postLinks:
          PostLinkThemingPanel(theme: $themeEditedInstance.winstonTheme)
        case .posts:
          PostThemingPanel(theme: $themeEditedInstance.winstonTheme)
        case .feed:
          FeedThemingPanel(theme: $themeEditedInstance.winstonTheme)
        }
      }
      .environment(\.useTheme, theme)
    }
    .environment(\.useTheme, theme)
  }
}
