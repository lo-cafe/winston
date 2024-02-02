//
//  SubredditFilters.swift
//  winston
//
//  Created by Zander Bobronnikov on 12/1/23.
//

import SwiftUI
import Defaults

//struct SubredditFilters: View, Equatable {
//  static func == (lhs: SubredditFilters, rhs: SubredditFilters) -> Bool {
//    lhs.subId == rhs.subId && lhs.theme == rhs.theme && lhs.selected == rhs.selected && lhs.searchText == rhs.searchText && lhs.filters == rhs.filters
//  }
//    
//  @Default(.SubredditFeedDefSettings) var subredditFeedDefSettings
//  @Default(.PostLinkDefSettings) var postLinkDefSettings
//  
//  var subId: String
//  var filters: [FilterData]
//  var selected: String
//  var filterCallback: ((String) -> ())
//  var searchText: String
//  var searchCallback: ((String?) -> ())
//  var editCustomFilter: ((FilterData) -> ())
//  
//  @State var compactOn: String = "Normal"
//  
//  var theme: WinstonTheme
//
//  
//  init(subId: String, filters: [FilterData], selected: String, filterCallback: @escaping ((String) -> ()), searchText: String, searchCallback: @escaping ((String?) -> ()), editCustomFilter: @escaping ((FilterData) -> ()), theme: WinstonTheme) {
//    self.subId = subId
//    self.filters = filters
//    self.selected = selected
//    self.filterCallback = filterCallback
//    self.searchText = searchText
//    self.searchCallback = searchCallback
//    self.editCustomFilter = editCustomFilter
//    self.theme = theme
//    
//    _compactOn = State(initialValue: (subredditFeedDefSettings.compactPerSubreddit[subId] ?? postLinkDefSettings.compactMode.enabled) ? "Compact": "Normal")
//  }
//  
//  func toggleCompactMode(compact: Bool) {
//    subredditFeedDefSettings.compactPerSubreddit[self.subId] = compact
//  }
//  
//  func getBackgroundColor() -> Color {
//    switch theme.postLinks.bg {
//    case .color(let colorSchemes):
//      return colorSchemes()
//    case .img(_):
//      return .black
//    }
//  }
//
//  var body: some View {
//    let paddingH = theme.postLinks.theme.outerHPadding + theme.postLinks.theme.innerPadding.horizontal
//    let opacity = theme.postLinks.filterOpacity
//    
//    Section {
//      ScrollView(.horizontal) {
//        HStack(spacing: theme.postLinks.filterPadding.horizontal) {
//          Menu {
//            Button(action: {
//              editCustomFilter(.init())
//            }) {
//              Label("New filter", systemImage: "plus")
//            }
//            
//            Picker("", selection: $compactOn) {
//              Text("Normal").tag("Normal")
//              Text("Compact").tag("Compact")
//            }
//            
//          
//          } label: {
//            Image(systemName: "slider.horizontal.3")
//              .resizable()
//              .foregroundColor(ColorSchemes(light: ThemeColor(hex: "000000"), dark: ThemeColor(hex: "FFFFFF"))())
//              .frame(width: theme.postLinks.filterText.size - 2, height: theme.postLinks.filterText.size - 2)
//              .opacity(0.8)
//          }
//          .onChange(of: compactOn, perform: { value in
//            toggleCompactMode(compact: value == "Compact")
//          })
//          
//          FlairFilter(filter: FilterData(text: "All", text_color: "000000", background_color: "D5D7D9"), filterFont: theme.postLinks.filterText, opacity: opacity, selected: selected, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, editCustomFilter: editCustomFilter)
//          
//          let customFilters = filters.filter({ $0.type != "flair" })
//          ForEach(customFilters) {
//            FlairFilter(filter: $0, filterFont: theme.postLinks.filterText, opacity: opacity, selected: selected, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, editCustomFilter: editCustomFilter).equatable()
//          }
//        
//          let sortedFlairs = filters.filter({ $0.type == "flair" }).sorted(by: {$0.occurences > $1.occurences })
//          ForEach(sortedFlairs) {
//            FlairFilter(filter: $0, filterFont: theme.postLinks.filterText, opacity: opacity, selected: selected, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, editCustomFilter: editCustomFilter).equatable()
//          }
//        }
//      }
//      .cornerRadius(4)
//      .padding(.horizontal, paddingH)
//    }
//    .frame(maxWidth: UIScreen.main.bounds.width)
//    .padding(.vertical, theme.postLinks.filterPadding.vertical)
//    .background(getBackgroundColor())
//  }
//}

//struct FlairFilter: View, Equatable {
//  static func == (lhs: FlairFilter, rhs: FlairFilter) -> Bool {
//    lhs.filter == rhs.filter && lhs.selected == rhs.selected && lhs.searchText == rhs.searchText && lhs.filterFont == rhs.filterFont && lhs.opacity == rhs.opacity
//  }
//
//  var filter: FilterData
//  var filterFont: ThemeText
//  var opacity: CGFloat
//  var selected: String
//  var filterCallback: ((String) -> ())
//  var searchText: String
//  var searchCallback: ((String?) -> ())
//  var editCustomFilter: ((FilterData) -> ())
//    
//  var body: some View {
//    let isSelected = filter.type == "search" ? searchText.lowercased() == filter.text.lowercased() : selected == filter.id
//    
//    HStack (spacing: 2) {
//      if filter.type == "search" {
//        Image(systemName: "magnifyingglass")
//          .resizable()
//          .frame(max(8, filterFont.size - 6))
//          .foregroundColor(Color(uiColor: UIColor(hex: filter.text_color)))
//      }
//      
//      Text(filter.getFormattedText())
//        .font(Font.system(size: filterFont.size, weight: filterFont.weight.t))
//    }
//    .foregroundColor(Color(uiColor: UIColor(hex: filter.text_color)))
//    .padding(.horizontal, 4)
//    .background(Color(uiColor: UIColor(hex: filter.background_color)))
//    .cornerRadius(4)
//    .opacity(isSelected ? 1 : opacity)
//    .onTapGesture {
//      if filter.type == "search" {
//        if searchText != filter.text {
//          searchCallback(filter.text)
//        } else {
//          searchCallback(nil)
//        }
//      } else {
//        filterCallback(selected == filter.id ? "flair:All" : filter.id)
//      }
//    }
//    .onLongPressGesture {
//      UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
//      
//      if filter.type != "flair" {
//        editCustomFilter(filter)
//      }
//    }
//  }
//}
//
//struct FilterData: Identifiable, Codable, Defaults.Serializable, Equatable, Hashable {
//  static func == (lhs: FilterData, rhs: FilterData) -> Bool {
//    return lhs.text == rhs.text && lhs.text_color == rhs.text_color && lhs.background_color == rhs.background_color && lhs.type == rhs.type
//  }
//  
//  var id: String
//  var text: String { willSet { if text != newValue { self.id = "\(type):\(newValue)" } } }
//  var text_color: String
//  var background_color: String
//  let occurences: Int
//  
//  // type = flair: filters for posts with link_flair_text = text
//  // type = filter: filters for posts with title or text contains text
//  // type = search: searches for text
//  var type: String { willSet { if type != newValue { self.id = "\(newValue):\(text)" } } }
//  
//  init() {
//    self.id = ""
//    self.text = ""
//    self.text_color = "000000"
//    self.background_color = "D5D7D9"
//    self.occurences = 0
//    self.type = "filter"
//  }
//  
//  init(text: String, text_color: String, background_color: String, occurences: Int = 0, type: String = "flair") {
//    self.id = "\(type):\(text)"
//    self.text = text
//    self.text_color = text_color
//    self.background_color = background_color
//    self.occurences = occurences + 1
//    self.type = type
//  }
//    
//  func getFormattedText() -> String {
//    return self.text.replacingOccurrences(of: "&amp;", with: "&")
//  }
//  
//  static func from(_ cached: CachedFilter) -> FilterData {
//    return FilterData(text: cached.text ?? "", text_color: cached.text_color ?? "000000", background_color: cached.background_color ?? "D5D7D9", occurences: Int(cached.occurences) - 1, type: cached.type ?? "flair")
//  }
//
//  
//  static func getTypeAndText(_ filter: String) -> [String] {
//    let split = filter.components(separatedBy: ":")
//    return [ split[0], String(split[1...].joined(separator: ":")) ]
//  }
//}
