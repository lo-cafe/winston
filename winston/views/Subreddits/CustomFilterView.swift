//
//  NewFilterView.swift
//  winston
//
//  Created by Zander Bobronnikov on 12/4/23.
//

import SwiftUI
import NukeUI
import CoreData

struct CustomFilterView: View {
  @Environment(\.useTheme) private var theme
  @Environment(\.dismiss) private var dismiss
  
  var filter: FilterData
  var subId: String
  @Binding var selected: String
  
  @State var draftFilter: FilterData = .init()
  
  func removeFromDefaults() {
    let context = PersistenceController.shared.container.newBackgroundContext()
    let fetchRequest = NSFetchRequest<CachedFilter>(entityName: "CachedFilter")
    fetchRequest.predicate = NSPredicate(format: "subreddit_id == %@ && text == %@ && type == %@", subId, filter.text, filter.type)
      
    context.performAndWait {
      let prevFlairs = (try? context.fetch(fetchRequest)) ?? []
      if let prevFlair = prevFlairs.first {
        context.delete(prevFlair)
      }
      
      try? context.save()
    }
    
    if selected == filter.id {
      selected = "flair:All"
    }
  }
  
  func saveToDefaults() {
    let context = PersistenceController.shared.container.newBackgroundContext()
    let fetchRequest = NSFetchRequest<CachedFilter>(entityName: "CachedFilter")
    fetchRequest.predicate = NSPredicate(format: "subreddit_id == %@ && text == %@ && type == %@", subId, filter.text, filter.type)

    context.performAndWait {
      let prevFlairs = (try? context.fetch(fetchRequest)) ?? []
      if let prevFlair = prevFlairs.first {
        prevFlair.text = draftFilter.text
        prevFlair.type = draftFilter.type
        prevFlair.background_color = draftFilter.background_color
        prevFlair.text_color = draftFilter.text_color
      } else {
        let newFilter = CachedFilter(context: context)
        newFilter.subreddit_id = subId
        newFilter.text = draftFilter.text
        newFilter.type = draftFilter.type
        newFilter.background_color = draftFilter.background_color
        newFilter.text_color = draftFilter.text_color
      }
      
      try? context.save()
    }
  }
  
  
  var body: some View {
    let anyChanges = filter != draftFilter
    let newFilter = filter.id == ""
    
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          Text(newFilter ? "New filter" : "Edit filter").fontSize(24, .semibold)
          
          HStack(alignment: .top, spacing: 8) {
            BigInput(l: "Filter text", t: Binding(get: { draftFilter.text }, set: { draftFilter.text = $0 }), placeholder: "Ex: filter")
            
            BigColorPicker(title: "Color", initialValue: filter.background_color, color:  Binding(get: { ThemeColor(hex: draftFilter.background_color) }, set: { draftFilter.background_color = $0.hex }))
            
          }
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
      }
      .themedListBG(.color(theme.lists.foreground.color))
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel", role: .destructive) {
            dismiss()
          }
        }
        
        if !newFilter {
          ToolbarItem(placement: .topBarTrailing) {
            Button("Delete", role: .destructive) {
              removeFromDefaults()
              dismiss()
            }
            .foregroundColor(.red)
          }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            saveToDefaults()
            dismiss()
          }
          .disabled(!anyChanges)
        }
      }
      .onAppear {
        draftFilter = filter
      }
      .interactiveDismissDisabled(anyChanges)
    }
  }
}

struct BigColorPicker: View {
  var title: String
  var initialValue: String
  @Binding var color: ThemeColor
  var placeholder: String? = nil
    
  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title.uppercased()).fontSize(12, .semibold).frame(minWidth: title.uppercased().width(font: UIFont.systemFont(ofSize: 12, weight: .semibold)), alignment: .leading).padding(.leading, 12).opacity(0.5)
      
      VStack (alignment: .leading) {
        ThemeColorPicker("", $color)
          .overlay(
            Color.clear
              .frame(maxWidth: .infinity)
              .resetter($color, ThemeColor(hex: initialValue))
              .padding(.trailing, 44)
          ).labelsHidden()
      }
      .padding(.vertical, 14)
      .padding(.horizontal, 14)
      .frame(minWidth: title.uppercased().width(font: UIFont.systemFont(ofSize: 12, weight: .semibold)) + 40)
      .background(RR(16, Color("acceptableBlack")))
    }
  }
}
