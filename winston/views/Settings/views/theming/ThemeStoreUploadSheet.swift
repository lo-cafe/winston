//
//  ThemeStoreUploadSheet.swift
//  winston
//
//  Created by Daniel Inama on 26/09/23.
//

import SwiftUI
import Defaults

struct ThemeStoreUploadSheet: View {
  @Default(.themesPresets) private var themesPresets
  @Environment(\.presentationMode) var presentationMode
  var body: some View {
    NavigationView {
      if themesPresets.isEmpty {
        VStack {
          HStack {
            Text("You don't have any local themes")
          }
        }
      } else {
        List {
          ForEach(themesPresets, id: \.self) { theme in
            LocalUploadThemeItem(theme: theme)
          }
        }
       
    
      }
    }
  }
}


struct LocalUploadThemeItem: View {
  var theme: WinstonTheme
  @State var upload_state: String = "local"
  @EnvironmentObject var themeStore: ThemeStoreAPI
  @State var uploading: Bool = false
  @State var uploadError: Bool = false
  @State var uploadErrorMessage: String = ""
  var body: some View {
    HStack(spacing: 8){
      Group {
        Image(systemName: theme.metadata.icon)
          .fontSize(24)
          .foregroundColor(.white)
      }
      .frame(width: 52, height: 52)
      .background(RR(16, theme.metadata.color.color()))
      VStack(alignment: .leading, spacing: 0) {
        Text(theme.metadata.name)
          .fontSize(16, .semibold)
          .fixedSize(horizontal: true, vertical: false)
        HStack{
          Text("Status:")
            .multilineTextAlignment(.trailing)
          
          Text("\(upload_state.localizedCapitalized)")
            .foregroundColor(upload_state == "accepted" ? .green : upload_state == "denied" ? .red : .primary)
            .multilineTextAlignment(.leading)
          Spacer()
        }
        .fontSize(14, .medium)
        .opacity(0.75)
        .fixedSize(horizontal: true, vertical: false)
        
      }
      Spacer()
      
      if upload_state == "local" {
        Button{
          uploading = true
          Task{
            let uploadresponse = await themeStore.uploadTheme(theme: theme)
            if uploadresponse?.message != "File uploaded successfully" {
              uploadErrorMessage = uploadresponse?.message ?? ""
              uploadError.toggle()
            } else {
              upload_state = "waiting for approval"
            }
            
          }
          uploading = false
        } label: {
          Label("Upload Theme", systemImage: "arrow.up.to.line")
            .labelStyle(.iconOnly)
        }
      }
      
    }
    .alert(isPresented: $uploadError){
      Alert(title: Text("Upload Error"), message: Text(uploadErrorMessage))
    }
    .onAppear{
      Task{
        upload_state = await themeStore.fetchThemeStatus(id: theme.id)?.status ?? "local"
      }
    }
  }
}

#Preview {
  ThemeStoreUploadSheet()
}
