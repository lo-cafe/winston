//
//  ImageThemePicker.swift
//  winston
//
//  Created by Igor Marcossi on 14/09/23.
//

import SwiftUI
import PhotosUI


struct ImageThemePicker: View {
  
  var label: String
  @Binding var image: String
  @State var uiImage: UIImage?
  
  @State private var selectedItem: PhotosPickerItem? = nil
//  @State private var selectedImageData: Data? = nil
  var body: some View {
    HStack {
      Text(label)
      Spacer()
      Group {
        if let uiImage = loadImage(fileName: image) {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
        } else {
          Circle()
            .fill(.primary.opacity(0.2))
        }
      }
      .frame(width: 28, height: 28)
      .mask(Circle())
      .overlay(
        PhotosPicker(
          selection: $selectedItem,
          matching: .images,
          photoLibrary: .shared()
        ) {
          Rectangle()
            .fill(.clear)
        }
          .onChange(of: selectedItem) { newItem in
            Task {
              // Retrieve selected asset in the form of Data
              if let data = try? await newItem?.loadTransferable(type: Data.self), let uiImg = UIImage(data: data) {
//                selectedImageData = data
                if let imgName = saveImage(image: uiImg) {
                  image = imgName
                }
              }
            }
          }
      )
    }
    .onAppear {
      uiImage = loadImage(fileName: image)
    }
  }
}

