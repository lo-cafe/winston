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

enum ThemeEditPanels {
  case general, posts, comments, postLinks, feed, commonLists
}

struct ThemeEditPanel: View {
  let theme: WinstonTheme
  @State private var draftTheme: WinstonTheme = defaultTheme
  @State private var iconPickerOpen = false
  @State private var themeColor: Color = .blue
  @State private var navPath: [ThemeEditPanels] = []
  
  @Environment(\.dismiss) private var dismiss
  
  var anyChanges: Bool { theme != draftTheme }

  var body: some View {
    NavigationStack(path: $navPath) {
      List {
        Image(systemName: theme.metadata.icon)
          .fontSize(48)
          .foregroundColor(.white)
          .frame(width: 96, height: 96)
          .background(RR(32, theme.metadata.color.color()))
          .frame(maxWidth: .infinity)
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        
        Group {
          Section("Theming") {
            WSListButton(showArrow: true, "General", icon: "paintbrush.pointed.fill") { navPath.append(ThemeEditPanels.general) }
            WSListButton(showArrow: true, "Common lists", icon: "list.bullet") { navPath.append(ThemeEditPanels.commonLists) }
            WSListButton(showArrow: true, "Posts feed", icon: "rectangle.grid.1x2.fill") { navPath.append(ThemeEditPanels.feed) }
            WSListButton(showArrow: true, "Posts links", icon: "rectangle.and.hand.point.up.left.fill") { navPath.append(ThemeEditPanels.postLinks) }
            WSListButton(showArrow: true, "Post page", icon: "doc.richtext.fill") { navPath.append(ThemeEditPanels.posts) }
            WSListButton(showArrow: true, "Comments", icon: "message.fill") { navPath.append(ThemeEditPanels.comments) }
          }
          
          Section("Metadatas") {
            
            WListButton {
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
            
            ThemeColorPicker("Icon background color", $draftTheme.metadata.color)
              LabeledTextField("Name", $draftTheme.metadata.name)
              LabeledTextField("Author", $draftTheme.metadata.author)
              
              VStack(alignment: .leading, spacing: 4) {
                Text("Description:")
                  .padding(.top, 8)
                TextEditor(text: $draftTheme.metadata.description)
                  .frame(maxWidth: .infinity, minHeight: 100)
                  .padding(.horizontal, 6)
                  .background(.primary.opacity(0.05))
                  .mask(RR(8, .black))
                  .padding(.bottom, 8)
                  .fontSize(15)
              }
                      .themedListRowLikeBG(enablePadding: true, disableBG: true)
            
          }
          
        }
        .themedListSection()
        
      }
      .themedListBG(draftTheme.lists.bg)
      .scrollDismissesKeyboard(.interactively)
      .onAppear { if draftTheme.id != theme.id { draftTheme = theme } }
      .navigationTitle(theme.metadata.name)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel", role: .destructive) {
            dismiss()
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            draftTheme.save()
            dismiss()
          }
          .disabled(!anyChanges)
        }
      }
      .navigationDestination(for: ThemeEditPanels.self) { x in
        Group {
          switch x {
          case .comments:
            CommentsThemingPanel(theme: $draftTheme)
          case .general:
            GeneralThemingPanel(theme: $draftTheme)
          case .postLinks:
            PostLinkThemingPanel(theme: $draftTheme, previewPostSample: Post(data: postSampleData, theme: draftTheme))
          case .posts:
            PostThemingPanel(theme: $draftTheme)
          case .feed:
            FeedThemingPanel(theme: $draftTheme)
          case .commonLists:
            CommonListsThemingPanel(theme: $draftTheme)
          }
        }
        .environment(\.useTheme, draftTheme)
      }
      .sheet(isPresented: $iconPickerOpen) {
        SymbolPicker(symbol: $draftTheme.metadata.icon)
      }
      .environment(\.useTheme, draftTheme)
    }
    .interactiveDismissDisabled(anyChanges)
  }
}
