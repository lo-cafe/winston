//
//  SubredditFilters.swift
//  winston
//
//  Created by Zander Bobronnikov on 12/1/23.
//

import SwiftUI
import Defaults

struct SubredditFilters: View, Equatable {
  static func == (lhs: SubredditFilters, rhs: SubredditFilters) -> Bool {
    lhs.subreddit.id == rhs.subreddit.id && lhs.theme == rhs.theme
  }
  
  var subreddit: Subreddit
  
  @Default(.subredditFlairs) var subredditFlairs
  @Default(.compactPerSubreddit) var compactPerSubreddit
  @Default(.compactMode) var compactMode
  
  @Binding var selected: String
  @State var compactOn: String = "Normal"
  
  var theme: WinstonTheme
  var compactToggled: (() -> ())

  @Environment(\.colorScheme) private var cs
  
  init(subreddit: Subreddit, selected: Binding<String>, theme: WinstonTheme, compactToggled: @escaping (() -> ())) {
    self.subreddit = subreddit
    self._selected = selected
    self.theme = theme
    self.compactToggled = compactToggled
    
    _compactOn = State(initialValue: (compactPerSubreddit[subreddit.id] ?? compactMode) ? "Compact": "Normal")
  }
  
  func toggleCompactMode(compact: Bool) {
    compactPerSubreddit[subreddit.id] = compact
    compactToggled()
  }
  
  func getBackgroundColor() -> Color {
    switch theme.postLinks.bg {
    case .color(let colorSchemes):
      return colorSchemes.cs(cs).color()
    case .img(_):
      return .black
    }
  }

  var body: some View {
    let paddingH = theme.postLinks.theme.outerHPadding + theme.postLinks.theme.innerPadding.horizontal
    
    Section {
      ScrollView(.horizontal) {
        HStack(spacing: 6) {
          
          Menu {
            Picker("compact", selection: $compactOn) {
              Text("Normal").tag("Normal")
              Text("Compact").tag("Compact")
            }
          } label: {
            Image(.options).resizable().frame(width: theme.postLinks.filterText.size + 8, height: theme.postLinks.filterText.size + 8).opacity(0.8)
          }
          .onChange(of: compactOn, perform: { value in
            toggleCompactMode(compact: value == "Compact")
          })
          
          FlairFilter(flair: FlairData(text: "All", text_color: "000000", background_color: "D5D7D9"), filterFont: theme.postLinks.filterText, selected: $selected)
          if let flairs = subredditFlairs[subreddit.id] {
            let sortedFlairs = flairs.sorted(by: {$0.occurences > $1.occurences })
            ForEach(sortedFlairs) {
              FlairFilter(flair: $0, filterFont: theme.postLinks.filterText, selected: $selected).equatable()
            }
          }
          
        }
      }
      .cornerRadius(4)
      .padding(.horizontal, paddingH)
    }
    .frame(width: UIScreen.main.bounds.width)
    .listRowSeparator(.hidden)
    .listSectionSeparator(.hidden)
    .listRowInsets(EdgeInsets())
    .padding(.horizontal, .zero)
    .padding(.vertical, theme.postLinks.filtersPadding)
    .background(getBackgroundColor())
  }
}

struct FlairFilter: View, Equatable {
  static func == (lhs: FlairFilter, rhs: FlairFilter) -> Bool {
    lhs.flair == rhs.flair
  }

  var flair: FlairData
  var filterFont: ThemeText
  
  @Binding var selected: String
  
  var body: some View {
    Text(flair.getFormattedText())
      .padding(.horizontal, 4)
      .font(Font.system(size: filterFont.size, weight: filterFont.weight.t))
      .foregroundColor(Color(uiColor: UIColor(hex: flair.text_color)))
      .background(Color(uiColor: UIColor(hex: flair.background_color)))
      .cornerRadius(4)
      .opacity(selected == flair.text ? 1 : 0.4)
      .onTapGesture {
        withAnimation {
          selected = selected == flair.text ? "All" : flair.text
        }
      }
  }
}
