//
//  FloatingFeedMenu.swift
//  winston
//
//  Created by Igor Marcossi on 16/12/23.
//

import SwiftUI
import Combine


struct FloatingFeedMenu: View, Equatable {
  static func == (lhs: FloatingFeedMenu, rhs: FloatingFeedMenu) -> Bool {
    lhs.filters == rhs.filters && lhs.selected == rhs.selected && lhs.pressingDown == rhs.pressingDown && lhs.toggled == rhs.toggled && lhs.menuOpen == rhs.menuOpen && lhs.disable == rhs.disable
  }
  
  var filters: [FilterData]
  var selected: String
  var filterCallback: ((String) -> ())
  var searchText: String
  var searchCallback: ((String?) -> ())
  
  @GestureState private var pressingDown = false
  @State private var toggleTimer: Timer? = nil
  @State private var vibrationTimer: Timer? = nil
  @State private var toggled = false
  @State private var menuOpen = false
  @State private var disable = false
  @State private var showingFilters = false
  
  @Namespace private var ns
	
	@Environment(\.contentWidth) var contentWidth
  
  private let longPressDuration: Double = 0.275
  
  func dismiss() {
    if menuOpen {
      Hap.shared.play(intensity: 0.75, sharpness: 0.4)
      doThisAfter(0) {
        showingFilters = false
      }
      withAnimation(.snappy(extraBounce: 0.3)) { menuOpen = false }
    }
  }
  
  func onTap() {
    dismiss()
  }
  
  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      Rectangle()
        .fill(.bar)
        .ifIOS17({ view in
          if #available(iOS 17.0, *) {
            view
              .frame(width: .screenW * 5, height: (!IPAD ? .screenW * 1.65 : .screenH * 0.75), alignment: .bottomTrailing)
              .mask(
                EllipticalGradient(
                  gradient: .smooth(from: .black, to: .black.opacity(0), curve: .easeIn),
                  center: .bottomTrailing,
                  startRadiusFraction: menuOpen ? 0.5 : 0,
                  endRadiusFraction: menuOpen ? 1 : 0
                )
                .animation(.smooth, value: menuOpen)
              )
          } else {
            view
              .frame(.screenW * 1.5, .bottomTrailing)
              .mask(
                EllipticalGradient(colors: [.black, .black.opacity(0.99), .black.opacity(0.98), .black.opacity(0.96), .black.opacity(0.92), .black.opacity(0.88), .black.opacity(0.85), .black.opacity(menuOpen ? 0.75 : 0.5), .black.opacity(menuOpen ? 0.65 : 0.3), .black.opacity(menuOpen ? 0.5 : 0.1), .black.opacity(menuOpen ? 0.4 : 0), .black.opacity(0)], center: .bottomTrailing, startRadiusFraction: menuOpen ? 0.25 : 0, endRadiusFraction: menuOpen ? 1 : 0)
                  .animation(.smooth, value: menuOpen)
              )
          }
        })
      
        .contentShape(Rectangle())
        .frame(width: contentWidth)
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in dismiss() } )
        .clipped()
        .allowsHitTesting(menuOpen)
      
      HStack(alignment: .bottom, spacing: -8) {
        if !menuOpen, !selected.isEmpty, let selectedFilter = filters.first(where: { $0.id == selected }) {
          FilterButton(filter: selectedFilter, isSelected: true, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback)
            .matchedGeometryEffect(id: "floating-\(selectedFilter.id)", in: ns, properties: .position)
            .padding(.trailing, 20)
            .frame(height: 64)
            .padding(.bottom, 8)
            .transition(.identity)
        }
        
        let sortedFlairs = filters.filter({ $0.type == "flair" }).sorted(by: {$0.occurences > $1.occurences })
        let customFilters = filters.filter({ $0.type != "flair" })
        if menuOpen {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              
              //            FilterButton(filter: FilterData(text: "All", text_color: "000000", background_color: "D5D7D9"), filterFont: theme.postLinks.filterText, opacity: opacity, selected: selected, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback)
              if showingFilters {
                ForEach(Array(customFilters.enumerated()), id: \.element) {
                  let isSelected = selected == $1.id
                  FilterButton(filter: $1, isSelected: isSelected, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback)
                    .matchedGeometryEffect(id: "floating-\($1.id)", in: ns)
                    .transition(isSelected ? .identity : .comeFrom(.trailing, index: sortedFlairs.count + $0, total: customFilters.count + sortedFlairs.count))
                }
                
                ForEach(Array(sortedFlairs.enumerated()), id: \.element) {
                  let isSelected = selected == $1.id
                  FilterButton(filter: $1, isSelected: isSelected, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback)
                    .matchedGeometryEffect(id: "floating-\($1.id)", in: ns, properties: .position)
                    .transition(isSelected ? .identity : .comeFrom(.trailing, index: !menuOpen ? 0 : sortedFlairs.count - $0, total: customFilters.count + sortedFlairs.count, disableEndDelay: true))
                }
              }
              
            }
            .padding(.trailing, 20)
            .padding(.leading, 12)
            .frame(height: 64, alignment: .trailing)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(.clear)
            .contentShape(Rectangle())
          }
          .ifIOS17 { if #available(iOS 17, *) { $0.defaultScrollAnchor(.trailing).scrollClipDisabled() } }
          .fadeOnEdges(.horizontal, disableSide: .leading)
        }
        //          .onDisappear { withAnimation(.snappy(duration: longPressDuration, extraBounce: 0.4)) { showingFilters = false } }
        
        
        VStack(spacing: 12) {
          VStack(spacing: 20) {
            if menuOpen {
              Image(systemName: "star.fill")
                .fontSize(22, .bold)
                .frame(width: 48, height: 48)
                .foregroundStyle(Color.accentColor)
                .floating()
                .transition(.comeFrom(.bottom, index: 1, total: 2))
              
              Image(systemName: "hand.tap.fill")
                .fontSize(22, .bold)
                .frame(width: 48, height: 48)
                .foregroundColor(Color.accentColor)
                .floating()
                .transition(.comeFrom(.bottom, index: 0, total: 2))
            }
          }
          
          Image(systemName: toggled || menuOpen ? "xmark" : "newspaper.fill")
            .ifIOS17({ v in
              if #available(iOS 17, *) { v.contentTransition(.symbolEffect) }
            })
            .transaction { trans in
              trans.animation = .easeInOut(duration: longPressDuration)
            }
            .fontSize(22, .bold)
            .frame(width: 64, height: 64)
            .foregroundColor(menuOpen || toggled ? .pink : Color.accentColor)
            .brightness((toggled || menuOpen ? 0.35 : 0) + (pressingDown ? 0.1 : 0))
            .background(Circle().fill(.white.opacity((toggled || menuOpen ? 0.5 : 0) + (pressingDown ? 0.225 : 0))).blendMode(.overlay))
            .floating()
            .frame(width: 80, height: 80)
            .background(Color(.primaryInverted).opacity(0.01))
            .contentShape(Rectangle())
            .scaleEffect((menuOpen || toggled ? 0.75 : 1) * (pressingDown ? 0.85 : 1))
            .animation(.bouncy(duration: longPressDuration, extraBounce: 0.225), value: pressingDown)
            .highPriorityGesture(
              LongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity)
                .updating($pressingDown) { isPressing, state, trans in
                  trans.isContinuous = true
                  state = isPressing
                }
              , including: disable ? .none : .all
            )
            .simultaneousGesture(
              DragGesture(minimumDistance: 0)
                .onChanged { val in
                  let trans = val.translation
                  if max(abs(trans.width), abs(trans.height)) > 24 {
                    withAnimation(.snappy(duration: 0.2, extraBounce: 0.3)) { toggled = false }
                    disable = true
                    doThisAfter(0) { disable = false }
                    toggleTimer?.invalidate()
                  }
                }
            )
            .simultaneousGesture(TapGesture().onEnded(onTap))
            .frame(width: 64, height: 64)
            .allowsHitTesting(!disable)
            .onChange(of: pressingDown) {
              if $0 {
                if menuOpen { return }
                Hap.shared.updateContinuous(intensity: 0, sharpness: 0)
                Hap.shared.startContinuous()
                vibrationTimer = createTimer(seconds: longPressDuration) { currLoop, totalLoops in
                  let interpolate = interpolatorBuilder([0, CGFloat(totalLoops)], value: CGFloat(currLoop))
                  Hap.shared.updateContinuous(intensity: Float(interpolate([0, 0.45], false)), sharpness: 0)
                }
                toggleTimer = Timer.scheduledTimer(withTimeInterval: longPressDuration, repeats: false) { _ in
                  vibrationTimer?.invalidate()
                  Hap.shared.stopContinuous()
                  Hap.shared.updateContinuous(intensity: 0, sharpness: 0)
                  Hap.shared.play(intensity: 0.95, sharpness: 0.75)
                  withAnimation(.snappy(duration: longPressDuration, extraBounce: 0.4)) {
                    toggled = true
                  }
                }
              } else {
                vibrationTimer?.invalidate()
                Hap.shared.stopContinuous()
                if toggled {
                  Hap.shared.play(intensity: 1, sharpness: 0.95)
                  withAnimation(.snappy(extraBounce: 0.3)) {
                    menuOpen = true
                    toggled = false
                  }
                  doThisAfter(0) {
                    showingFilters = true
                  }
                } else {
                  toggleTimer?.invalidate()
                }
              }
            }
        }
        .padding([.trailing, .bottom], 8)
      }
    }
  }
}



extension View {
  func floatingMenu(filters: [FilterData], selected: String, filterCallback: @escaping ((String) -> ()), searchText: String, searchCallback: @escaping ((String?) -> ())) -> some View {
    self
      .overlay(FloatingFeedMenu(filters: filters, selected: selected, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback).equatable(), alignment: .bottomTrailing)
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
