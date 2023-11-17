//
//  PaletteCreator.swift
//  winston
//
//  Created by Daniel Inama on 23/10/23.
//

import SwiftUI
import Defaults
struct PaletteCreator: View {
  @Default(.customIndentationThemes) var customIndentationThemes
  @State var showingColorPaletteCreator: Bool = false
  @Environment(\.dismiss) var dismiss
  var body: some View {
    NavigationView {
      List {
        Section("My Palettes") {
          ForEach(Array(customIndentationThemes.keys), id: \.self) { key in
            HStack {
              PaletteDisplayItem(palette: customIndentationThemes[key]!, name: key)
              Spacer()
              Button {
                customIndentationThemes.removeValue(forKey: key)
              } label: {
                Label("Delete", systemImage: "trash")
                  .labelStyle(.iconOnly)
                  .foregroundStyle(.red)
              }
            }
          }
        }
      }
      .toolbar {
        ToolbarItem {
          Button {
            showingColorPaletteCreator.toggle()
          } label: {
            Label("Create Theme", systemImage: "plus")
          }
        }
        
        ToolbarItem(placement: .cancellationAction){
          Button {
            dismiss()
          } label: {
            Label("Close", systemImage: "xmark")
              .labelStyle(.titleOnly)
          }
        }
      }
      .navigationTitle("Color Palette Editor")
      .navigationBarTitleDisplayMode(.large)
      .sheet(isPresented: $showingColorPaletteCreator) {
        ColorPaletteAdder()
      }
    }
  }
}
struct ColorPaletteAdder: View {
  @Environment(\.dismiss) var dismiss

  @State var colorsAmountInt: Int = 1
  @State var colorsAmount: [String] = Array(repeating: "#FFFFFF", count: 1)
  @State var name = ""
  @Default(.customIndentationThemes) var customIndentationThemes
  var body: some View {
    NavigationView {
      Form{
        HStack{
          TextField("Name", text: $name)
            .fontWeight(.medium)
            .textFieldStyle(.roundedBorder)
            .padding()
          Spacer()
        }
        Section("Colors"){
          HStack{
            Stepper("Colors in Palette: \(colorsAmountInt)", value: $colorsAmountInt, in: 1...6)
              .padding()
          }
          ForEach(0..<colorsAmount.count, id: \.self) { index in
//            ColorPicker("Color \(index + 1)", selection: UIColor(hex: $colorsAmount[index]))
          }
        }
      }
      .toolbar {
        ToolbarItem {
          Button {
            // Handle Save button action
            if name != "" {
//              customIndentationThemes[name] = colorsAmount
              dismiss()
            }
          } label: {
            Label("Add", systemImage: "square.and.arrow.down")
              .labelStyle(.titleOnly)
          }
          .disabled(name == "")
        }
        
        ToolbarItem(placement: .cancellationAction) {
          Button {
            dismiss()
          } label: {
            Label("Cancel", systemImage: "xmark")
              .labelStyle(.titleOnly)
          }
        }
      }
    }
    .navigationTitle("Create new Palette")
    .onChange(of: colorsAmountInt) { newValue in
      if newValue > colorsAmount.count {
        // Add new Color pickers
        for _ in 0..<(newValue - colorsAmount.count) {
//          colorsAmount.append(.white)
        }
      } else if newValue < colorsAmount.count {
        // Remove extra Color pickers
        colorsAmount.removeLast(colorsAmount.count - newValue)
      }
    }
  }
}

