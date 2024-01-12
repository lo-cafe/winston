//
//  FloatingFeedMenu.swift
//  winston
//
//  Created by Igor Marcossi on 16/12/23.
//

import SwiftUI
import Combine
import Defaults

struct FloatingFeedMenu: View, Equatable {
  static func == (lhs: FloatingFeedMenu, rhs: FloatingFeedMenu) -> Bool {
    lhs.subId == rhs.subId && lhs.filters == rhs.filters && lhs.selected == rhs.selected && lhs.menuOpen == rhs.menuOpen
  }
  
  var subId: String
  var filters: [FilterData]
  var selected: String
  var filterCallback: ((String) -> ())
  var searchText: String
  var searchCallback: ((String?) -> ())
  var customFilterCallback: ((FilterData) -> ())
  
  @State private var menuOpen = false
  @State private var showingFilters = false
  @State var compact: Bool = false
  
  @Namespace private var ns
  
  private let mainTriggerSize: Double = 64
  private let actionsSize: Double = 48
  private let itemsSpacing: Double = 20
  private let screenEdgeMargin: Double = 12
  
  var itemsSpacingDownscaled: Double { itemsSpacing - ((mainTriggerSize - actionsSize) / 2) }
  
  @Default(.SubredditFeedDefSettings) var subredditFeedDefSettings
  @Default(.PostLinkDefSettings) var postLinkDefSettings
  
  init(subId: String, filters: [FilterData], selected: String, filterCallback: @escaping ((String) -> ()), searchText: String, searchCallback: @escaping ((String?) -> ()), customFilterCallback: @escaping ((FilterData) -> ())) {
    self.subId = subId
    self.filters = filters
    self.selected = selected
    self.filterCallback = filterCallback
    self.searchText = searchText
    self.searchCallback = searchCallback
    self.customFilterCallback = customFilterCallback
    
    _compact = State(initialValue: subredditFeedDefSettings.compactPerSubreddit[subId] ?? postLinkDefSettings.compactMode.enabled)
  }
  
  func dismiss() {
    if menuOpen {
      Hap.shared.play(intensity: 0.75, sharpness: 0.4)
      //      doThisAfter(0) {
      withAnimation {
        showingFilters = false
      }
      withAnimation(.snappy(extraBounce: 0.3)) {
        menuOpen = false
      }
      
    }
  }
  
  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      FloatingBGBlur(active: menuOpen, dismiss: dismiss).equatable()
      
      HStack(alignment: .bottom, spacing: 0) {
        ZStack(alignment: .bottomTrailing) {
          if !showingFilters, !selected.isEmpty, let selectedFilter = filters.first(where: { $0.id == selected }) {
            FilterButton(filter: selectedFilter, isSelected: true, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, customFilterCallback: customFilterCallback)
              .equatable()
              .matchedGeometryEffect(id: "floating-\(selectedFilter.id)", in: ns, properties: .position)
              .padding(.trailing, itemsSpacingDownscaled)
              .frame(height: mainTriggerSize)
              .padding(.bottom, screenEdgeMargin)
              .transition(.offset(x: 0.01))
          }
          
          let sortedFlairs = filters.filter({ $0.type == "flair" }).sorted(by: {$0.occurences > $1.occurences })
          let customFilters = filters.filter({ $0.type != "flair" })
          if menuOpen {
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 8) {
                
                ForEach(Array(sortedFlairs.enumerated()).reversed(), id: \.element) { i, el in
                  let isSelected = selected == el.id
                  let placeholder = isSelected && !showingFilters
                  let elId = "floating-\(el.id)\(placeholder ? "-placeholder" : "")"
                  FilterButton(filter: el, isSelected: isSelected, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, customFilterCallback: customFilterCallback)
                    .equatable()
                    .matchedGeometryEffect(id: elId, in: ns, properties: .position)
                    .scaleEffect(showingFilters || isSelected ? 1 : 0.01, anchor: .trailing)
                    .opacity((showingFilters || isSelected) && !placeholder ? 1 : 0)
                    .animation(.bouncy.delay(Double(showingFilters && !isSelected ? i + customFilters.count : 0) * 0.125), value: showingFilters)
                    .transition(.offset(x: 0.01))
                    .id(elId)
                }
                
                ForEach(Array(customFilters.enumerated()).reversed(), id: \.element) { i, el in
                  let isSelected = selected == el.id
                  let placeholder = isSelected && !showingFilters
                  let elId = "floating-\(el.id)\(placeholder ? "-placeholder" : "")"
                  
                  FilterButton(filter: el, isSelected: isSelected, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, customFilterCallback: customFilterCallback)
                    .equatable()
                    .matchedGeometryEffect(id: "floating-\(el.id)", in: ns)
                    .scaleEffect(showingFilters || isSelected ? 1 : 0.01, anchor: .trailing)
                    .opacity((showingFilters || isSelected) && !placeholder ? 1 : 0)
                    .animation(.bouncy.delay(Double(showingFilters && !isSelected ? i : 0) * 0.125), value: showingFilters)
                    .transition(.offset(x: 0.01))
                    .id(elId)
                }
              }
              .padding(.trailing, itemsSpacingDownscaled)
              .padding(.leading, 12)
              .frame(height: mainTriggerSize, alignment: .trailing)
              .padding(.top, 16)
              .background(Color.hitbox)
              .contentShape(Rectangle())
            }
            .defaultScrollAnchor(.trailing)
            .scrollClipDisabled()
            .padding(.bottom, screenEdgeMargin)
            .fadeOnEdges(.horizontal, disableSide: .leading)
            .transition(.offset(x: 0.01))
          }
        }
        
        // -
        
        VStack(spacing: itemsSpacingDownscaled) {
          VStack(spacing: itemsSpacing) {
            if menuOpen {
              Image(systemName: "star.fill")
                .fontSize(22, .bold)
                .frame(width: actionsSize, height: actionsSize)
                .foregroundStyle(Color.accentColor)
                .floating()
                .transition(.comeFrom(.bottom, index: 1, total: 2))
              
              Image(systemName: compact ? "doc.text.image" : "doc.plaintext")
                .fontSize(22, .bold)
                .frame(width: actionsSize, height: actionsSize)
                .foregroundColor(Color.accentColor)
                .floating()
                .transition(.comeFrom(.bottom, index: 0, total: 2))
                .onTapGesture {
                  compact = !compact
                  subredditFeedDefSettings.compactPerSubreddit[self.subId] = compact
                }
              
              Image(systemName: "plus")
                .fontSize(22, .bold)
                .frame(width: actionsSize, height: actionsSize)
                .foregroundColor(Color.accentColor)
                .floating()
                .transition(.comeFrom(.bottom, index: 0, total: 2))
                .onTapGesture {
                  customFilterCallback(FilterData())
                }
            }
          }
          
          FloatingMainTrigger(menuOpen: $menuOpen, showingFilters: $showingFilters, dismiss: dismiss, size: mainTriggerSize, actionsSize: actionsSize).equatable()
        }
        .padding([.trailing, .bottom], screenEdgeMargin)
      }
    }
  }
}



extension View {
  func floatingMenu(subId: String, filters: [FilterData], selected: String, filterCallback: @escaping ((String) -> ()), searchText: String, searchCallback: @escaping ((String?) -> ()), customFilterCallback: @escaping ((FilterData) -> ())) -> some View {
    self
      .overlay(FloatingFeedMenu(subId: subId, filters: filters, selected: selected, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, customFilterCallback: customFilterCallback).equatable(), alignment: .bottomTrailing)
  }
}

func createTimer(seconds: Double, callback: @escaping (Int, Int) -> Void) -> Timer {
  let totalLoops = Int(120.0 * seconds)
  var currentLoop = 0
  
  let timer = Timer.scheduledTimer(withTimeInterval: 1.0/120.0, repeats: true) { (timer) in
    callback(currentLoop, totalLoops)
    currentLoop += 1
    if currentLoop >= totalLoops {
      timer.invalidate()
    }
  }
  RunLoop.current.add(timer, forMode: .common)
  
  return timer
}
