//
//  FAQPanel.swift
//  winston
//
//  Created by Daniel Inama on 15/08/23.
//

import SwiftUI

struct FAQPanel: View {
  var body: some View {

    VStack{
      List{
        QuestionAnswer(question: "What does the Box Icon do?", answer: "Save posts in the Posts Box to be read later. These will live in Winston and wont be synced to Reddit.", systemImage: "shippingbox")
      }

    }
    .navigationBarTitle("Frequently Asked Questions", displayMode: .inline)
    
  }
}

struct QuestionAnswer: View {
  var question: String
  var answer: String
  var systemImage: String?
  var body: some View {
    VStack{
      HStack{
        if let systemImage {
          Image(systemName: systemImage)
        }
        Text(question)
        Spacer()
      }
      .fontWeight(.bold)
      .font(.system(.headline))
      .padding(.bottom, 5)
      HStack{
        Text(answer)
        Spacer()
      }
    }
  }
}
