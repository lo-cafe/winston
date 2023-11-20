//
//  TagsOptionsCarousel.swift
//  winston
//
//  Created by Igor Marcossi on 09/09/23.
//

import SwiftUI

private struct Option<T: Hashable>: View {
  var option: CarouselTagElement<T>
  @Binding var selected: T
  
  func select() {
    withAnimation(.default) {
      selected = option.value
    }
  }
  
  var body: some View {
    HStack {
      if let icon = option.icon {
        AnyView(icon())
      }
      Text(option.label.capitalized)
        .fontSize(16, .medium)
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 12)
    .foregroundColor(option.active || selected == option.value ? .white : .primary)
    .background(Capsule(style: .continuous).fill(option.active || selected == option.value ? Color.accentColor : .primary.opacity(0.1)))
    .onTapGesture(perform: select)
    .animation(.default, value: selected)
  }
}

struct CarouselTagElement<T: Hashable>: Identifiable {
  let label: String
  var icon: (() -> any View)? = nil
  let value: T
  var active: Bool = false
  var id: String { self.label }
}

struct TagsOptionsCarousel<T: Hashable>: View {
  @Binding var selected: T
  var options: [CarouselTagElement<T>]
  
  init(_ selected: Binding<T>, options: [CarouselTagElement<T>]) {
    self._selected = selected
    self.options = options
  }
  
  init(_ selected: Binding<T>, _ options: [T]) {
    self._selected = selected
    self.options = options.map { CarouselTagElement(label: ($0 as? String) ?? "Label", value: $0) }
  }
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 4) {
        ForEach(options) { opt in
          Option(option: opt, selected: $selected)
        }
      }
      .padding(.horizontal, 16)
    }
  }
}

struct TagsOptions<T: Hashable>: View {
  @Binding var selected: T
  var options: [CarouselTagElement<T>]
  
  init(_ selected: Binding<T>, options: [CarouselTagElement<T>]) {
    self._selected = selected
    self.options = options
  }
  
  init(_ selected: Binding<T>, _ options: [T]) {
    self._selected = selected
    self.options = options.map { CarouselTagElement(label: ($0 as? String) ?? "Label", value: $0) }
  }
  
  var body: some View {
    HStack(spacing: 4) {
      ForEach(options) { opt in
        Option(option: opt, selected: $selected)
      }
    }
  }
}
